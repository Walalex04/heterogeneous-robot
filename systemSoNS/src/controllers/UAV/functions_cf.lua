package.path = "../../controllers/common/?.lua;" .. package.path

local protocol = require("protocol")


local functions_UAV = {}

----------------------------------------------
---            Random Walk               -----
-----------------------------------------------

function functions_UAV.init_random_walk(robot)
    robot.rw_state = "FORWARD"  
    robot.rw_timer = 0         
    robot.rw_duration = 30     
    robot.rw_target_speed = 0.2 
    robot.rw_turn_speed = 0.0 
    robot.arena_limit = 3.0
end

function functions_UAV.random_walk(robot)
    local pos_x = robot.positioning.position.x
    local pos_y = robot.positioning.position.y
    local q     = robot.positioning.orientation
    local yaw   = math.atan2(2 * ((q.w or 1) * (q.z or 0) + (q.x or 0) * (q.y or 0)), 
                           1 - 2 * ((q.y or 0)^2 + (q.z or 0)^2))

    local is_out_of_bounds = (math.abs(pos_x) >= robot.arena_limit) or 
                             (math.abs(pos_y) >= robot.arena_limit)

    if is_out_of_bounds then
        local target_angle = math.atan2(-pos_y, -pos_x)
        local angle_diff   = target_angle - yaw

        while angle_diff > math.pi do angle_diff = angle_diff - 2 * math.pi end
        while angle_diff < -math.pi do angle_diff = angle_diff + 2 * math.pi end

        if math.abs(angle_diff) > 0.2 then
            local turn_speed = (angle_diff > 0) and 0.6 or -0.6
            robot.quadrotor.set_linear_velocity(0.0, 0.0, 0.0)
            robot.quadrotor.set_rotational_speed(turn_speed)
        else
            robot.rw_state = "FORWARD"
            robot.rw_timer = 0
            robot.rw_duration = math.random(50, 100)
            robot.quadrotor.set_linear_velocity(robot.rw_target_speed, 0.0, 0.0)
            robot.quadrotor.set_rotational_speed(0.0)
        end
        return
    end

    robot.rw_timer = robot.rw_timer + 1

    if robot.rw_timer >= robot.rw_duration then
        robot.rw_timer = 0
        
        if robot.rw_state == "FORWARD" then
            robot.rw_state = "TURN"
            robot.rw_duration = math.random(10, 30)
            local sign = (math.random() > 0.5) and 1 or -1
            robot.rw_turn_speed = sign * (0.3 + math.random() * 0.5)
        else
            robot.rw_state = "FORWARD"
            robot.rw_duration = math.random(40, 100)
        end
    end

    if robot.rw_state == "FORWARD" then
        robot.quadrotor.set_linear_velocity(robot.rw_target_speed, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(0.0)
    elseif robot.rw_state == "TURN" then
        robot.quadrotor.set_linear_velocity(0.0, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(robot.rw_turn_speed)
    end
end


-------------------------------------------------------
-----         Comunication functions           --------
-------------------------------------------------------

function functions_UAV.send_searching_msg(robot, id_robot, root_id, state_robot)
    local fields = {
        sender_id = id_robot,
        seq_counter = 0,
        timestamp = 0,
        root_id = root_id,
        parent_id = root_id,
        state = state_robot
    }

    local packet = protocol.build_packet(fields, protocol.TYPE_MESSAGE.UP)  -- the type message is irrelevant
    robot.range_and_bearing.set_data(packet)
end

function functions_UAV.decode_msg(data)
    if type(data) ~= "table" or #data < protocol.PACKET_SIZE then
      return {valid = false, error = "packet too short"}
    end

    --- TODO: IT MUST BE FINISH THE ALL DECODE FOR ALL MSG 

    local decoded = {
        sender_id = data[protocol.BYTE_SENDUP.SENDER_ID],
        root_id = data[protocol.BYTE_SENDUP.SEQ_COUNTER],
        parent_id = data[protocol.BYTE_SENDUP.PARENT_ID],
        state = data[protocol.BYTE_SENDUP.STATE]
    }

    return decoded
end

function functions_UAV.update_topolgy(robot, currentUID, local_topolgy)
    local rab = robot.range_and_bearing
    if not rab then return end

    for _,packet in ipairs(rab) do 
        
        local decode_data = functions_UAV.decode_msg(packet["data"])
        if (decode_data["sender_id"] ~= nil and decode_data["sender_id"] ~= 0) then 
            log(string.format("The robot %d has a connection with %d", currentUID, decode_data["sender_id"]))
            --verifying if the robot does not has a leader
            if(decode_data["sender_id"] == decode_data["parent_id"]) then
                -- it does not has a parent
                
                --verifying what has more priviligies
                if(currentUID < decode_data["sender_id"]) then
                    -- it mean the current robot has more privilige 
                    local_topolgy["parent_id"] = currentUID
                    if(decode_data["sender_id"] < 10) then
                        -- the robot detect is drone
                        table.insert(local_topolgy["direct_childs"], decode_data["sender_id"])

                        -- TODO :
                        -- IF WE USE QUPAS WITHOUT APRILTAG
                        -- THEN WE MUST ADD MORE CODE FOR ADDING
                        -- IN THE TOPOLGY
                    end
                else
                    local_topolgy["parent_id"] = decode_data["sender_id"]
                end
            elseif (decode_data["parent_id"] == currentUID) then
                log("There is a robot that I am its parent")
                if(decode_data["sender_id"] < 10) then
                    table.insert(local_topolgy["direct_childs"], decode_data["sender_id"])
                end
            else
                -- if the robot find other robot with a parent
                -- and the current robot does not has a parent
                -- also if the parent of the other robot is greater than
                -- id of the current robot then it assign the parent
                if(local_topolgy["parent_id"] == nil and
                    decode_data["parent_id"] < currentUID) then 
                    local_topolgy["parent_id"] = decode_data["sender_id"]
                end
            end
        end
    end
end

return functions_UAV

