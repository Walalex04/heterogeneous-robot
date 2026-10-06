pcall(function() os.setlocale("C", "numeric") end)
package.path = "../../controllers/common/?.lua;" .. package.path

local cons = require("constants")
local protocol = require("protocol")
local fc_common = require("functions_common")


local brain_behavior = {}

brain_behavior.STATE_BRAIN = {
    TARGET_DONE = 1,
    TARGET_TODO = 2
}

brain_behavior.global_graph = {
    id = 0,
    pose = {x = 0, y = 0, yaw = 0},
    children = {
        {
            id = 11,
            type = cons.TYPE_ROBOT.DRONE,
            pose = {x = 0.75, y = 0, yaw = 0},
            children = {
                { id = 31, type = cons.TYPE_ROBOT.QUPA, pose = {x = 1.5, y = 0.5, yaw = 0} },
                { id = 32, type = cons.TYPE_ROBOT.QUPA, pose = {x = 1.0245, y = 0.1545, yaw = 0} },
                { id = 33, type = cons.TYPE_ROBOT.QUPA, pose = {x = 1.2061, y = -0.4045, yaw = 0} },
                { id = 34, type = cons.TYPE_ROBOT.QUPA, pose = {x = 1.7939, y = -0.4045, yaw = 0} },
                { id = 35, type = cons.TYPE_ROBOT.QUPA, pose = {x = 1.9755, y = 0.1545, yaw = 0} },
            }
        },
        {
            id = 12,
            type = cons.TYPE_ROBOT.DRONE,
            pose = {x = -0.75, y = 0, yaw = 0},
            children = {
                { id = 31, type = cons.TYPE_ROBOT.QUPA, pose = {x = -1.5, y = 0.5, yaw = 0} },
                { id = 32, type = cons.TYPE_ROBOT.QUPA, pose = {x = -1.0245, y = 0.1545, yaw = 0} },
                { id = 33, type = cons.TYPE_ROBOT.QUPA, pose = {x = -1.2061, y = -0.4045, yaw = 0} },
                { id = 34, type = cons.TYPE_ROBOT.QUPA, pose = {x = -1.7939, y = -0.4045, yaw = 0} },
                { id = 35, type = cons.TYPE_ROBOT.QUPA, pose = {x = -1.9755, y = 0.1545, yaw = 0} },
            }
        }
    }
}

brain_behavior.target_graph = {
    Av = {
        typei = {1,1,3,3,3,3,3,3,3,3,3,3} -- types robots
    }, -- attributes associated to V

    Ae = {
        disp = {
            -- for drones
            {x = 1.5, y = 0},
            {x = -1.5, y = 0},

            -- for qupas
            {x = 1.5, y = 0.5},
            {x = 1.0245, y = 0.1545},
            {x = 1.2061, y = -0.4045},
            {x = 1.7939, y = -0.4045},
            {x = 1.9755, y = 0.1545},

            {x = -1.5, y = 0.5},
            {x = -1.9755, y = 0.1545},
            {x = -1.7939, y = -0.4045},
            {x = -1.2061, y = -0.4045},
            {x = -1.0245, y = 0.1545},

        },      -- target relative displacement
        quat = {
            
            -- for drones
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},

            -- for qupas

            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},

            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},
            {x = 0.0, y = 0.0, z = 0.0, w = 1.0},

        }       -- target relative quaternion
    },
    card_type = {2,0,0},     -- target cardinality (drone, blimp, qupa)
    card_high = 2    
}   


function brain_behavior.recruitment(robot, ticks, childs, graph, ids_childs_allowed, parent, childs_qupa)
    

    local rab = robot.range_and_bearing
    for _,packet in ipairs(rab) do 
        local decode_data = protocol.decode_msg(packet["data"])
        
        if(decode_data["type_robot"] == cons.TYPE_ROBOT.DRONE and (decode_data["typ_msg"] == 0)) then 
            --verify if the robot belong other graph
            if(decode_data["sender_id"] == decode_data["sosn_rank"]) then 
                if(robot.ROBOT_UID < decode_data["sender_id"]) then 
                    -- the current robot has more priviligies
                    -- add in the list of child
                    --log(string.format("robot from %d is view to %d", robot.ROBOT_UID, decode_data["sender_id"]))
                   
                    brain_behavior.recruitment_drone(robot, decode_data, childs, graph, ids_childs_allowed)

                else
                    -- the current robot is lower rank   
                    -- we must wait for recruiment of the higher rank 
                    --log(string.format("entra response id %d, state recruiment: %d, ", decode_data["response_id"], decode_data["state_recruiment"] ))
                    if((decode_data["response_id"] == robot.ROBOT_UID) and
                        decode_data["state_recruiment"] == cons.STATE_RECRUITMENT.AWAITING)then
                        -- we must be accept
                        robot.SoNS_ROOT_ID = decode_data["sender_id"] -- this must be update when it can communicate
                        robot.SoNS_ROOT_RANK =  decode_data["sosn_rank"]
                        
                        table.insert(parent, {UID = decode_data["sender_id"], STATE=cons.STATE_RECRUITMENT.INTILIZING})                  
                        --robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
                        --log(string.format("the robot %d was change states", robot.ROBOT_UID))

                    elseif ((decode_data["response_id"] == robot.ROBOT_UID) and
                        decode_data["state_recruiment"] == cons.STATE_RECRUITMENT.REJECTED) then
                        robot.SoSN_ROOT_ID_OLD = decode_data["sender_id"]
                    end
                end
            elseif (robot.SoNS_ROOT_RANK <= decode_data["sosn_rank"]) then
                brain_behavior.recruitment_drone(robot, decode_data, childs, graph, ids_childs_allowed)
                
            end
        elseif decode_data["type_robot"] == cons.TYPE_ROBOT.QUPA and (decode_data["typ_msg"] == 0) then
            --log("see to qupa")
            if(decode_data["sender_id"] == decode_data["sosn_rank"] and (robot.ROBOT_TYPE == cons.TYPE_ROBOT.DRONE)) then 
                -- the robot does not have a parent  
                -- One drone always recruiment to qupa   

                brain_behavior.recruitment_qupa(robot, decode_data, childs, graph, ids_childs_allowed, childs_qupa)

            end

        elseif decode_data["typ_msg"] == 2 then
        
            local new_decode = protocol.decode_resp_rec_target_msg(packet["data"])
                    
            for _, child in ipairs(childs) do
                --log(string.format("the id %d is compared with %d and this has a response of %d", child.UID , new_decode["sender_id"], new_decode["response"]))
                if(child.UID == new_decode["sender_id"] and
                    (new_decode["response"] == 1)) then
                    child.STATE = cons.STATE_RECRUITMENT.ACCEPTED

                    --log(string.format("the robot %d was established as accept", child.UID))
                end
            end
            
        end
    end
end


function brain_behavior.recruitment_drone(robot, decode_data, childs, graph, childs_allowed)

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
        --log(childs_allowed[1])
        --log("the id is " .. id .. " and its state is " .. childs[id].STATE)
        --log(string.format("sosn_rank: %s, ROBOT_UID: %s, childs[%s].STATE: %s, STATE_RECRUITMENT.AWAITING: %s", tostring(decode_data["sosn_rank"]), tostring(robot.ROBOT_UID), tostring(id), tostring(childs[id].STATE), tostring(cons.STATE_RECRUITMENT.AWAITING)))
        if((decode_data["sosn_rank"] == robot.ROBOT_UID) and
            (childs[id].STATE == cons.STATE_RECRUITMENT.AWAITING)
            )then

            --log(string.format("into for child id %d", childs[id].UID))
            --log(#childs)

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


function brain_behavior.recruitment_qupa(robot, decode_data, childs, graph, childs_allowed, list_qupa)
    --log(string.format("the robot id %d has card type for qupa %d", robot.ROBOT_UID, graph.card_type[3]))
    ---if(graph.card_type[3] == 0 or robot.STATE == cons.STATE_ROBOT.COMP_GRAPH) then
    --    log(string.format("it is not neccesary qupa robots for robot with id %d", robot.ROBOT_UID))
    --    robot.STATE = cons.STATE_ROBOT.COMP_GRAPH
    --    return
    --end
end

function brain_behavior.sending_msg_recruiment(robot, childs, cardinality, ticks, target_graph)
    local card_total = cardinality[1] + cardinality[2] + cardinality[3]
    
    local mod_car = ticks % card_total;
    mod_car = mod_car + 1

    local fields = {}
    local packet = {}
    if((#childs - mod_car) >=  0) then
        log(string.format("Send id %d with state %d", childs[mod_car].UID, childs[mod_car].STATE))
        if(childs[mod_car].STATE == cons.STATE_RECRUITMENT.AWAITING)then
            --log(string.format("we are sending a recruiment for %d that is a state of %d", childs[mod_car]["UID"], childs[mod_car]["STATE"]))
            
            fields = {
                sender_id = robot.ROBOT_UID,
                typ_msg = 0,
                sosn_rank = robot.SoNS_ROOT_RANK,
                cardinality = cardinality[0],
                type_robot = robot.ROBOT_TYPE,
                response_id = childs[mod_car].UID,
                state_recruiment = 3
            }
            packet = protocol.recruitment_msg(fields) 
        elseif(childs[mod_car].STATE == cons.STATE_RECRUITMENT.INTILIZING)then
            -- send the topology for the child
            log(string.format("the robot id %d will sent the graph of %s to the robot %d", robot.ROBOT_UID, childs[mod_car].ID_GRAPH, childs[mod_car].UID))
            
            fields = {
                sender_id = robot.ROBOT_UID,
                typ_msg = 1,

                destinity = childs[mod_car].UID,
                id_graph1 = childs[mod_car].ID_GRAPH
            }
            packet = protocol.send_topology_msg(fields) 
        elseif childs[mod_car].STATE == cons.STATE_RECRUITMENT.ACCEPTED then
            --log(string.format("se esta enviando para el robot %d", childs[mod_car].UID))
            packet = brain_behavior.send_mov_child(robot, childs[mod_car], target_graph)

        else
            fields = {
            sender_id = robot.ROBOT_UID,
            typ_msg = 0,
            sosn_rank = robot.SoNS_ROOT_RANK,
            cardinality = cardinality[0],
            type_robot = robot.ROBOT_TYPE,
            response_id = 0,
            state_recruiment = 0
        }
        packet = protocol.recruitment_msg(fields) 
        end
    
    else
        
        fields = {
            sender_id = robot.ROBOT_UID,
            typ_msg = 0,
            sosn_rank = robot.SoNS_ROOT_RANK,
            cardinality = cardinality[0],
            type_robot = robot.ROBOT_TYPE,
            response_id = 0,
            state_recruiment = 0
        }
        packet = protocol.recruitment_msg(fields) 
    end

    --log(#packet)

    robot.range_and_bearing.set_data(packet)
    
end


function brain_behavior.send_mov_child(robot, child, target_graph)
    local field = {}

    local id = child.ID_GRAPH % 10
    local type_robot = child.ID_GRAPH // 10
            
    local pos = target_graph.Ae.disp[id]
    local orientation = robot.positioning.orientation

    field = {
        sender_id = robot.ROBOT_UID,
        typ_msg = 4,
        destinity = child.UID,

        tar_pos_x = fc_common.a2_encode8(pos.x * 100),
        tar_pos_y = fc_common.a2_encode8(pos.y * 100),
        tar_pos_z = 0,  -- the same for both robots

        tar_q_1 = fc_common.a2_encode8(orientation.w),
        tar_q_2 = fc_common.a2_encode8(orientation.x),
        tar_q_3 = fc_common.a2_encode8(orientation.y),
        tar_q_4 = fc_common.a2_encode8(orientation.z)
    }

    local packet = protocol.send_instructions_msg(field)
    return packet
end


function brain_behavior.dynamic_behavior(robot, ticks)

    -- for drone the movement follows a circular path
    
    if(robot.ROBOT_TYPE == cons.TYPE_ROBOT.DRONE) then
        local CIRCLE_RADIUS = 1
        local CIRCLE_SPEED = 0.002

        local vx = -CIRCLE_RADIUS * CIRCLE_SPEED * math.sin(CIRCLE_SPEED * ticks)
        local vy =  CIRCLE_RADIUS * CIRCLE_SPEED * math.cos(CIRCLE_SPEED * ticks)

        robot.quadrotor.set_linear_velocity(vx, vy, 0.0)
        robot.quadrotor.set_rotational_speed(0.0)
    elseif robot.ROBOT_TYPE == cons.TYPE_ROBOT.QUPA then
        --robot.wheels.set_velocity(0.0, 0.0)
        local speed = 30.0
        local threshold = 0.1
        local pos = robot.positioning.position
        local x, y = pos.x, pos.y
        local left_speed, right_speed
        if x > 3.0 or x < -3.0 or y > 3.0 or y < -3.0 then
            local target_angle = math.atan2(-y, -x)
            local q = robot.positioning.orientation
            local current_angle = math.atan2(2.0 * (q.w * q.z + q.x * q.y), 1.0 - 2.0 * (q.y * q.y + q.z * q.z))
            local angle_diff = target_angle - current_angle
            while angle_diff > math.pi do angle_diff = angle_diff - 2.0 * math.pi end
            while angle_diff < -math.pi do angle_diff = angle_diff + 2.0 * math.pi end
            if math.abs(angle_diff) > 0.1 then
                if angle_diff > 0 then
                    left_speed, right_speed = -speed, speed
                else
                    left_speed, right_speed = speed, -speed
                end
            else
                left_speed, right_speed = speed, speed
            end
        else
            local repulse_y = 0.0
            local max_prox = 0.0
            for i = 1, #robot.proximity do
                local val = robot.proximity[i].value
                local angle = robot.proximity[i].angle
                if val > max_prox then
                    max_prox = val
                end
                repulse_y = repulse_y + val * math.sin(angle)
            end
            if max_prox > threshold then
                if repulse_y > 0 then
                    left_speed, right_speed = speed, -speed
                else
                    left_speed, right_speed = -speed, speed
                end
            else
                local rw_bias = 0
                if ticks % 20 == 0 then
                    rw_bias = (math.random() - 0.5) * 6.0
                end
                left_speed = speed + rw_bias
                right_speed = speed - rw_bias
            end
        end
        robot.wheels.set_velocity(left_speed, right_speed)
    end

    -- for qupa is a random walk
end


--[[
    when the robot recruiment other, the parent
    send to child a message with topology 

    for this the robot must be in INTILIZING state
]]



return brain_behavior