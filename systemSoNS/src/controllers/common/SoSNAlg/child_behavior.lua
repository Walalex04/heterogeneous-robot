pcall(function() os.setlocale("C", "numeric") end)
package.path = "../../controllers/common/?.lua;" .. package.path

local cons = require("constants")
local protocol = require("protocol")
local fc_common = require("functions_common")



local child_behavior = {}



function child_behavior.recruitment(robot, ticks, childs, graph, ids_childs_allowed, childs_qupa)
    
    local rab = robot.range_and_bearing
    for _,packet in ipairs(rab) do 
        local decode_data = protocol.decode_msg(packet["data"])
        --log(string.format("the typ msg of the robot is %s", decode_data["typ_msg"]))
        if(decode_data["type_robot"] == cons.TYPE_ROBOT.DRONE and (decode_data["typ_msg"] == 0))  then 
            --verify if the robot belong other graph
            if(decode_data["sender_id"] == decode_data["sosn_rank"]) then 
                if(robot.ROBOT_UID < decode_data["sender_id"]) then 
                    -- the current robot has more priviligies
                    -- add in the list of child
                    --log(string.format("robot from %d is view to %d", robot.ROBOT_UID, decode_data["sender_id"]))
                   
                    child_behavior.recruitment_drone(robot, decode_data, childs, graph, ids_childs_allowed)

                else
                    -- the current robot is lower rank   
                    -- we must wait for recruiment of the higher rank 
                    --log(string.format("entra response id %d, state recruiment: %d, ", decode_data["response_id"], decode_data["state_recruiment"] ))
                    if((decode_data["response_id"] == robot.ROBOT_UID) and
                        decode_data["state_recruiment"] == cons.STATE_RECRUITMENT.AWAITING)then
                        -- we must be accept
                        robot.SoNS_ROOT_ID = decode_data["sender_id"] -- this must be update when it can communicate
                        robot.SoNS_ROOT_RANK =  decode_data["sosn_rank"]
                        --robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
                        --log(string.format("the robot %d was change states", robot.ROBOT_UID))

                        -- if the robot has children then send to message
                        ids_childs_allowed = {}
                        robot.CARD_DRONE = 0
                        robot.CARD_QUPA = 0

                    elseif ((decode_data["response_id"] == robot.ROBOT_UID) and
                        decode_data["state_recruiment"] == cons.STATE_RECRUITMENT.REJECTED) then
                        robot.SoSN_ROOT_ID_OLD = decode_data["sender_id"]
                    end
                end
            elseif (robot.SoNS_ROOT_RANK <= decode_data["sosn_rank"]) then
                child_behavior.recruitment_drone(robot, decode_data, childs, graph, ids_childs_allowed)
            end
        elseif decode_data["type_robot"] == cons.TYPE_ROBOT.QUPA and (decode_data["typ_msg"] == 0) then
            if(decode_data["sender_id"] == decode_data["sosn_rank"] and (robot.ROBOT_TYPE == cons.TYPE_ROBOT.DRONE)) then 
                -- the robot does not have a parent  
                -- One drone always recruiment to qupa   
                child_behavior.recruitment_qupa(robot, decode_data, childs, graph, ids_childs_allowed, childs_qupa)
            end
        elseif decode_data["typ_msg"] == 1 and (robot.STATE ~= cons.STATE_ROBOT.COMP_GRAPH) then
            -- this only when try to send me a graph
            robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
            --log(string.format("the robot %d was change states", robot.ROBOT_UID))
        end
    end
end


function child_behavior.recruitment_drone(robot, decode_data, childs, graph, childs_allowed)

    --verify if we need more childs 
   
    --log(childs_allowed[1])
    if(graph.card_type[1] == 0 or robot.STATE == cons.STATE_ROBOT.COMP_GRAPH) then
        robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
        return
    end

    local id = fc_common.is_child(childs, decode_data["sender_id"])
    --log(#childs_allowed)
    --log("the robot id 1")
    if(id ~= -1) then
        --local id_child_allowed = childs_allowed
        --log(childs[id]["UID"])
        --log(string.format("sosn_rank: %s, ROBOT_UID: %s, childs[%s].STATE: %s, STATE_RECRUITMENT.AWAITING: %s", tostring(decode_data["sosn_rank"]), tostring(robot.ROBOT_UID), tostring(id), tostring(childs[id].STATE), tostring(cons.STATE_RECRUITMENT.AWAITING)))
        if((decode_data["sosn_rank"] == robot.ROBOT_UID) and
            (childs[id].STATE == cons.STATE_RECRUITMENT.AWAITING)
            )then

            --log(childs_allowed[1])
            --log(string.format("we accept to robot %d from root %d and it is in a %d state", decode_data["sender_id"], robot.ROBOT_UID, cons.STATE_RECRUITMENT.INTILIZING))
            
            --log(string.format("the robot id graph is %s",childs_allowed[1] ))
                
            childs[id] = {UID = decode_data["sender_id"], STATE = cons.STATE_RECRUITMENT.INTILIZING, ID_GRAPH=childs_allowed[1]}
            table.remove(childs_allowed, 1)
            --graph.card_type[1] = graph.card_type[1] - 1
            robot.CARD_DRONE = robot.CARD_DRONE + 1
        
        end
        
    else
        table.insert(childs, {UID = decode_data["sender_id"], STATE = cons.STATE_RECRUITMENT.AWAITING})
        --log(childs[1]["UID"])
    end
end

function child_behavior.recruitment_qupa(robot, decode_data, childs, graph, childs_allowed, list_qupa)
    --log(string.format("the robot id %d has card type for qupa %d", robot.ROBOT_UID, graph.card_type[3]))
    ---if(graph.card_type[3] == 0 or robot.STATE == cons.STATE_ROBOT.COMP_GRAPH) then
    --    log(string.format("it is not neccesary qupa robots for robot with id %d", robot.ROBOT_UID))
    --    robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
    --    return
    --end

end


function child_behavior.sending_msg_recruiment(robot, childs, cardinality, ticks, parent)
    local card_total = cardinality[1] + cardinality[2] + cardinality[3] + 1
    
    local mod_car = ticks % card_total;
    mod_car = mod_car + 1

    local fields = {}
    local packet = {}
    if((#childs - mod_car) >=  0) then
        
        if(childs[mod_car].STATE == cons.STATE_RECRUITMENT.AWAITING)then
            --log(string.format("we are sending a recruiment for %d that is a state of %d", childs[mod_car]["UID"], childs[mod_car]["STATE"]))
            
            fields = {
                sender_id = robot.ROBOT_UID,
                seq_counter = 0,
                sosn_rank = robot.SoNS_ROOT_RANK,
                cardinality = cardinality[0],
                type_robot = robot.ROBOT_TYPE,
                response_id = childs[mod_car].UID,
                state_recruiment = 3
            }
            packet = protocol.recruitment_msg(fields) 
        elseif(childs[mod_car].STATE == cons.STATE_RECRUITMENT.INTILIZING)then
            -- send the topology for the child
            --log(string.format("the robot id %d will sent the graph of %s to the robot %d", robot.ROBOT_UID, childs[mod_car].ID_GRAPH, childs[mod_car].UID))
             
            fields = {
                sender_id = robot.ROBOT_UID,
                typ_msg = 1,

                destinity = childs[mod_car].UID,
                id_graph1 = childs[mod_car].ID_GRAPH
            }
            packet = protocol.send_topology_msg(fields) 
        end
    else
        --log(string.format("the robot %d has the state %d", robot.ROBOT_UID, robot.STATE))
        if(parent[1].STATE == cons.STATE_RECRUITMENT.INTILIZING and
            (robot.STATE == cons.STATE_ROBOT.COMP_GRAPH)) then 

            --log(string.format("the child %d send a response for topology", robot.ROBOT_UID))
            fields = {
                sender_id = robot.ROBOT_UID,
                typ_msg = 2,
                response = 1
            }
            parent[1].STATE = cons.STATE_RECRUITMENT.ACCEPTED
            robot.STATE = cons.STATE_ROBOT.SEARCHING
            packet = protocol.resp_rec_target_msg(fields)

          
        else     
            fields = {
            sender_id = robot.ROBOT_UID,
            seq_counter = 0,
            sosn_rank = robot.SoNS_ROOT_RANK,
            cardinality = cardinality[0],
            type_robot = robot.ROBOT_TYPE,
            response_id = 0,
            state_recruiment = 0
            }
            packet = protocol.recruitment_msg(fields) 
        end
    end

    
    robot.range_and_bearing.set_data(packet)
    
end


function child_behavior.recept_msg_graph(robot,current_tree, local_target_graph, child_allowed)
    local rab = robot.range_and_bearing
    for _,packet in ipairs(rab) do 
        local decode_data = protocol.decode_send_topology_msg(packet["data"])
        --log(decode_data["sender_id"] .. "-----" .. decode_data["type_msg"] .. "-----" .. decode_data["destinity"] )
        if((decode_data["sender_id"] == robot.SoNS_ROOT_RANK) and
          (decode_data["typ_msg"] == 1) and
          (decode_data["destinity"] == robot.ROBOT_UID)) then 
            
            local my_id_graph = decode_data["id_graph1"]
            current_tree = fc_common.get_sub_tree_by_id(current_tree, my_id_graph)
            local_target_graph = fc_common.gen_tar_local_graph(current_tree, 5, child_allowed)

            --log(string.format("THE ROBOT ID %d ------------------", robot.ROBOT_UID))
            fc_common.traverse_graph(current_tree)
            fc_common.printLocalTarget(local_target_graph, my_id_graph)
        end
    end
end

function child_behavior.recept_instructions(robot, parent)
    local rab = robot.range_and_bearing

    for _,packet in ipairs(rab) do 
        local decode_data = protocol.decode_send_instructions_msg(packet["data"])
        if(decode_data["typ_msg"] == 4 and decode_data["destinity"] == robot.ROBOT_UID) then 
            local range = packet.range
            local hor_bearing = packet.horizontal_bearing 
            local ver_bearing = packet.vertical_bearing   

            local x = range * math.abs(math.cos(ver_bearing)) * math.cos(hor_bearing)
            local y = range * math.abs(math.cos(ver_bearing)) * math.sin(hor_bearing)
            local z = range * math.sin(ver_bearing)

            --log(string.format("the range %d is %.4f", robot.ROBOT_UID, range))

            local q = robot.positioning.orientation

            local q_padre = {
                w = fc_common.a2_decode8(decode_data["tar_q_1"]),
                x = fc_common.a2_decode8(decode_data["tar_q_2"]),
                y = fc_common.a2_decode8(decode_data["tar_q_3"]),
                z = fc_common.a2_decode8(decode_data["tar_q_4"])
            }

            local target_padre = {
                x = fc_common.a2_decode8(decode_data["tar_pos_x"]),
                y = fc_common.a2_decode8(decode_data["tar_pos_y"]),
                z = fc_common.a2_decode8(decode_data["tar_pos_z"])
            }

            local error_x = x + target_padre.x
            local error_y = y + target_padre.y
            local error_z = z + target_padre.z
            
            local K_pos = 0.001
            local K_yaw = 0.5


            local MAX_VEL_TRANSLACIONAL = 10
            local MAX_VEL_ROTACIONAL   = 1.0 

            local function clamp(val, limit)
                if val > limit then return limit end
                if val < -limit then return -limit end
                return val
            end

            local vx = clamp(K_pos * error_x, MAX_VEL_TRANSLACIONAL)
            local vy = clamp(K_pos * error_y, MAX_VEL_TRANSLACIONAL)
            local vz = clamp(K_pos * error_z, MAX_VEL_TRANSLACIONAL)

            --[[
            if(robot.ROBOT_UID == 3) then
                log("--------------------------------------------------------------------------------")
                log(string.format("La posicion en el robot %d es x = %.4f y = %.4f y el target es x = %.4f  y = %.4f", robot.ROBOT_UID, x, y, target_padre.x, target_padre.y))
                log(string.format("El error en x = %.4f y = %.4f z = %.4f", error_x, error_y, error_z))
                log(string.format("la velocidad es vx = %.4f vy = %.4f vz = %.4f", vx, vy, vz))

                log("*****")

                log(string.format("El range del robot es %.4f el hor_bear %.4f y el ver_bear %.4f", range, hor_bearing, ver_bearing))
            end
            ]]

            local w_z = clamp(K_yaw * 0, MAX_VEL_ROTACIONAL)

            robot.quadrotor.set_linear_velocity(vx, vy, vz)
            --robot.quadrotor.set_rotational_speed(w_z)

        end


    end
end

return child_behavior
