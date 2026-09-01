package.path = "../../controllers/common/?.lua;" .. package.path

local protocol = require("protocol")
local cons = require("constants")
local func_common = require("functions_common")


local functions_qupa = {}

local rw_counter = 0
local rw_bias = 0.0

function functions_qupa.random_walk(robot)
  local speed = 10.0
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


        if angle_diff > 0 then
            left_speed, right_speed = -speed, speed
        else
            left_speed, right_speed = speed, -speed
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

            rw_counter = rw_counter + 1
            if rw_counter >= 20 then
                rw_counter = 0
                rw_bias = (math.random() - 0.5) * 6.0
            end
            left_speed = speed + rw_bias
            right_speed = speed - rw_bias
        end
    end


    robot.wheels.set_velocity(left_speed, right_speed)
end


----------------------------------------------------------------
----                    Comunication                      ------
----------------------------------------------------------------


function functions_qupa.send_searching_msg(robot, id_robot, root_id, state_robot)
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



function functions_qupa.decode_msg(data)
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



function functions_qupa.update_topolgy(robot, currentUID ,local_topology)
    -- for the qupa the first message that it recive then this is the parent
    -- but later the message from the parent will verify if The robot
    -- is been seen by drone

    local rab = robot.range_and_bearing

    for _, packet in ipairs(rab) do
        local decode_data = functions_qupa.decode_msg(packet["data"])
        if (decode_data["sender_id"] ~= nil and decode_data["sender_id"] ~= 0) then
            -- the first parent who the robot can see then this will be its parent
            if(100 > decode_data["sender_id"]) then
                -- if the id is lower than 100 then the robot is a drone
                local_topology["parentId"] = decode_data["sender_id"]
            end
        end
    end
    
end

return functions_qupa