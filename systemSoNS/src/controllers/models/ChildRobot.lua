package.path = "../../controllers/utils/?.lua;" .. package.path

local Robot = require("Robot")
local protocol = require("Protocol")   --only for enums
local Helpers = require("helper_functions")
local graph_fn = require("graph_functions")
local ChildRobot = {}

ChildRobot.Robot = Robot



--- parent Id robot
---@type Integer
ChildRobot.ParentRobot = nil

--- Function that relatinship elements of  
--- principal robot (all point to the same objetc)
---@param Robot Table The principal object
function ChildRobot.init(Robot)
    ChildRobot.Robot = Robot
end 



--- Function that allow responde the recruiments msg
function ChildRobot.response_recruiment()
    local msgs = ChildRobot.Robot.MSGReceiveRecruimente;
    
    for id, value in pairs(msgs) do
        --log(string.format("The robot %i has a new message recruiment of %i and the ChildRobot.ParentRobot is", 
        --            ChildRobot.Robot.RobotPhyParam.robotID, id, ChildRobot.ParentRobot))

        if(ChildRobot.ParentRobot == nil) then 
            -- it mean that the current robot does not has parent
            --log(string.format("The robot %i has a new parent %i and it id packet is %i", 
            --        ChildRobot.Robot.RobotPhyParam.robotID, id, value.msg.header.packet_id))
            --log(string.format("The robobt %i accept to be child of %i and this has id packet of %i", 
            --                ChildRobot.Robot.RobotPhyParam.robotID, id, value.msg.header.packet_id))
            ChildRobot.ParentRobot = id
            ChildRobot.Robot.ParentRobot = ChildRobot.ParentRobot
            ChildRobot.Robot.update_parent(ChildRobot.ParentRobot)
            ChildRobot.Robot.make_response_msg(ChildRobot.ParentRobot, value.msg.header.packet_id, protocol.ResponseMsg.ACCEPT)
            ChildRobot.Robot.set_target_graph(nil)
            
        elseif (ChildRobot.ParentRobot > id and id ~= ChildRobot.Robot.IntRobot.SoSNLastID) then  -- when the robot recieve  
                                                                        -- a recruiment from a parent 
                                                                        -- with better rank 
            log(string.format("The robot %i recieve a recruiment from %i and it is better than the current" ..
                        "-The id of the parent is %i and the other has a SoSN",
                    ChildRobot.Robot.RobotPhyParam.robotID, id, ChildRobot.ParentRobot))
            --[[
                TODO: Enviar un mensaje de unlike para asociarse con el que tiene mejor rank
                Se debe ocupar la misma funcion ya creada en protocol y en Robot 
                pero se debe crear las funciones que manejan el receptorm, en este caso el padre
                asimismo luego de esa prueba los hijos deberan borrar su target y esperar a que el padre 
                le envie el nuevo target
            ]]
            ChildRobot.Robot.make_unlike_msg(ChildRobot.ParentRobot)
            ChildRobot.ParentRobot = id
            ChildRobot.Robot.update_parent(ChildRobot.ParentRobot)
            ChildRobot.Robot.make_response_msg(ChildRobot.ParentRobot, value.msg.header.packet_id, protocol.ResponseMsg.ACCEPT)
            ChildRobot.Robot.set_target_graph(nil)
        elseif (ChildRobot.ParentRobot ~= id) then
            --log(string.format("The robobt %i reject to be child of %i", 
            --                ChildRobot.Robot.RobotPhyParam.robotID, id))
            ChildRobot.Robot.make_response_msg(id, value.msg.header.packet_id, protocol.ResponseMsg.REJECTED)
        end 

        ChildRobot.Robot.MSGReceiveRecruimente[id] = nil
    end
end


--- Function that allow responde the unlike msg
function ChildRobot.respond_unlike_msg()
    
    local msgs =  ChildRobot.Robot.MSGReceiveUnlike
    
    for id, value in pairs(ChildRobot.Robot.MSGReceiveUnlike) do
        if(ChildRobot.ParentRobot ~= nil) then 
            --log(string.format("the robot %i we delete its parent", Robot.RobotPhyParam.robotID))
            ChildRobot.unlike_child(id)
            ChildRobot.Robot.MSGReceiveUnlike[id] = nil
        end 
    end

end

--- Delete a parant of the the list
---@param ParentId Integer Parent ID
function ChildRobot.unlike_child(ParentId)
    --verify if the parent is the same 
    --log(string.format("The current parent id is %i", ChildRobot.ParentRobot ))
    if(ParentId == ChildRobot.ParentRobot ) then
        ChildRobot.ParentRobot = nil              
        ChildRobot.Robot.update_parent(ChildRobot.ParentRobot)
        --log("The robot %i has no parent", ChildRobot.Robot.RobotPhyParam.robotID)
        ChildRobot.Robot.MSGReceiveUnlike[ParentId] = {}
    end
end 


--- funtion that recieve the data and make the target 
function ChildRobot.receive_target()
    local bool = false
    if(#Robot.MSGReceiveTargetGraph == 0) then return bool end
    
    for sender_id, content in pairs(Robot.MSGReceiveTargetGraph) do
        for packet_id, data in pairs(content) do
            if(data.is_complete) then 
                --log(string.format("The robot %i recived a complete message from %i and there are %i packets"
                --    , Robot.RobotPhyParam.robotID, data.msg[1].header.sender_id, #data.msg))
                ChildRobot.Robot.set_target_graph(ChildRobot.build_target_graph_from_msg(sender_id, packet_id, data))
                Robot.get_child_target_graph()
                bool = true
                Robot.MSGReceiveTargetGraph[sender_id][packet_id] = nil
            end
        end
    end

    return bool
end
--- Function that generates the target graph from received multi-packet messages
--- @param sender_id number The sender robot ID
--- @param packet_id number The packet ID session
--- @param target_entry table The entry containing the packet messages list (`target_entry.msg`)
--- @return table|nil The root brain node configured for the graph
function ChildRobot.build_target_graph_from_msg(sender_id, packet_id, target_entry)
    if not target_entry or not target_entry.msg then
        return nil
    end

    -- Helper to decode 16-bit signed values from MSB and LSB
    local function decode_axis(msb, lsb)
        local val = ((msb or 0) * 256) + (lsb or 0)
        if val >= 32768 then
            val = val - 65536
        end
        return val / 1000.0
    end

    -- Helper to decode 16-bit unsigned ID
    local function decode_id(msb, lsb)
        return ((msb or 0) * 256) + (lsb or 0)
    end

    local nodes_map = {}

    -- 1. Recorrer todos los paquetes recibidos en la lista `data.msg`
    for _, packet in ipairs(target_entry.msg) do
        local p = packet.payload

        -- Procesar Child 1
        if p.id_child_1_1 and (p.id_child_1_1 > 0 or p.id_child_2_1 > 0) then
            local id = decode_id(p.id_child_1_1, p.id_child_2_1)
            nodes_map[id] = {
                id = id,
                type = p.type_child_1,
                pose = {
                    x   = decode_axis(p.pos_x1_child_1, p.pos_x2_child_1),
                    y   = decode_axis(p.pos_y1_child_1, p.pos_y2_child_1),
                    z   = decode_axis(p.pos_z1_child_1, p.pos_z2_child_1),
                    yaw = decode_axis(p.yaw_1_child_1,  p.yaw_2_child_1)
                },
                children = {}
            }
        end

        -- Procesar Child 2
        if p.id_child_1_2 and (p.id_child_1_2 > 0 or p.id_child_2_2 > 0) then
            local id = decode_id(p.id_child_1_2, p.id_child_2_2)
            nodes_map[id] = {
                id = id,
                type = p.type_child_2,
                pose = {
                    x   = decode_axis(p.pos_x1_child_2, p.pos_x2_child_2),
                    y   = decode_axis(p.pos_y1_child_2, p.pos_y2_child_2),
                    z   = decode_axis(p.pos_z1_child_2, p.pos_z2_child_2),
                    yaw = decode_axis(p.yaw_1_child_2,  p.yaw_2_child_2)
                },
                children = {}
            }
        end
    end

    -- 2. Construir la jerarquía utilizando la relación matemática del ID (ej: 124 -> padre 12)
    local root_children = {}
    for id, node in pairs(nodes_map) do
        local parent_id = math.floor(id / 10)
        if nodes_map[parent_id] then
            table.insert(nodes_map[parent_id].children, node)
        else
            -- Si no tiene padre en el mapa, es hijo directo del nodo principal (Brain)
            table.insert(root_children, node)
        end
    end

    -- 3. Crear el nodo propio (Brain) con los datos del propio robot y pose en 0, pasando solo los hijos
    local brain_config = {
        id = sender_id,
        type = 0, -- Ajusta el tipo de tu robot actual si lo requieres
        pose = { x = 0, y = 0, z = 0, yaw = 0 },
        children = root_children
    }

    -- 4. Generar el grafo final usando tu función
    return graph_fn.make_target_graph(brain_config)
end
function ChildRobot.apply_commands(type)
    local cmd_data = Robot.MSGReceiveCMDtarget[ChildRobot.ParentRobot]
        
        if not cmd_data or not cmd_data.is_complete then 
            return 
        end

        local msg = cmd_data.msg
        local payload = msg.payload

        -- 2. Decodificar los valores de los bytes (MSB y LSB) con complemento a 2
        local target_x = Helpers.combine_bytes(payload.tar_pos_x_1, payload.tar_pos_x_2) *1000
        local target_y = Helpers.combine_bytes(payload.tar_pos_y_1, payload.tar_pos_y_2) *1000
        local target_z = Helpers.combine_bytes(payload.tar_pos_z_1, payload.tar_pos_z_2) *1000
        local target_yaw = 2 * (Helpers.combine_bytes(payload.tar_yaw_1, payload.tar_yaw_2))

        -- 3. Obtener orientación actual (el bearing / orientation ya opera en radianes)
        local current_yaw = Robot.IntRobot.positioning.orientation.z
        
        -- 4. Rotación del objetivo usando la diferencia de ángulos
        local delta_yaw = target_yaw - current_yaw
        local cos_d = math.cos(delta_yaw)
        local sin_d = math.sin(delta_yaw)

        local target_x_rot = target_x * cos_d - target_y * sin_d
        local target_y_rot = target_x * sin_d + target_y * cos_d

        -- 5. Posiciones relativas del sensor (escaladas a metros)
        local sense_x = cmd_data.x_rel 
        local sense_y = cmd_data.y_rel 
        local sense_z = cmd_data.z_rel 

        -- 6. Cálculo del Error Proporcional
        local error_x = sense_x + target_x_rot
        local error_y = sense_y + target_y_rot
        local error_z = (2 * sense_z) + target_z 
        
        -- Error de yaw normalizado al rango [-pi, pi]
        local error_yaw = -current_yaw + target_yaw
    
    -- 1. Verificar de forma segura que el mensaje exista y esté completo
    if(type == Robot.TypeRobot.QUPA)then  
        local error_yaw_deg = -current_yaw + target_yaw
        local error_yaw = error_yaw_deg * math.pi / 180.0

        local Kp_v = 10
        local Kp_w = 17
        local Kp_yaw = 5.0
        local max_v = 100

        local error_dist = math.sqrt(error_x * error_x + error_y * error_y)
        local error_heading = math.atan2(error_y, error_x)

        local v_linear = Kp_v * error_dist
        if v_linear > max_v then
            v_linear = max_v
        end

        v_linear = v_linear * math.cos(error_heading)
        if v_linear < 0 then
            v_linear = 0
        end

        local v_angular = (Kp_w * error_heading) + (Kp_yaw * error_yaw)

        local left_speed = v_linear - v_angular
        local right_speed = v_linear + v_angular

        Robot.IntRobot.wheels.set_velocity(left_speed, right_speed)
    else
        
        --error_yaw = (error_yaw + math.pi) % (2 * math.pi) - math.pi

        -- 7. Log detallado para depuración clara en una sola línea
        --log(string.format(
        --    "[CMD] Target(%.2f, %.2f) | Sense(%.2f, %.2f) | Err(X:%.2f, Y:%.2f, Z:%.2f) | YawErr:%.2f",
        --    target_x_rot, target_y_rot, 
        --    sense_x, sense_y, 
        --    error_x, error_y, error_z, 
        --    error_yaw
        --))

        -- 8. Ganancias Proporcionales y Límites
        local K_pos = 0.0002
        local K_yaw = 0.75


        local MAX_VEL_TRANSLACIONAL = 8
        local MAX_VEL_ROTACIONAL   = 3.0

        local function clamp(val, limit)
            if val > limit then return limit end
            if val < -limit then return -limit end
            return val
        end

        -- 9. Cálculo de velocidades por control proporcional
        local vx = clamp(K_pos * error_x, MAX_VEL_TRANSLACIONAL)
        local vy = clamp(K_pos * error_y, MAX_VEL_TRANSLACIONAL)
        local vz = clamp(K_pos * error_z, MAX_VEL_TRANSLACIONAL)
        local w_z = clamp(K_yaw * error_yaw, MAX_VEL_ROTACIONAL)
        
        -- 10. Enviar comandos al quadrotor
        Robot.IntRobot.quadrotor.set_linear_velocity(vx, vy, vz)
        Robot.IntRobot.quadrotor.set_rotational_speed(w_z)

    end
end

return ChildRobot