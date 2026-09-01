pcall(function() os.setlocale("C", "numeric") end)

package.path = "../../controllers/common/?.lua;" .. package.path
local consts = require("constants")
local funcs_UAV = require("functions_cf")
local funcs_common = require("functions_common")


-----------------------------------------------------------------
---               Local Variables                            ---
-----------------------------------------------------------------

local UID = {
    cf0 = 1,
    cf1 = 2,
    cf2 = 3,
    cf3 = 4,
    cf4 = 6
}

local local_topolgy = {
    parentId = nil,
    direct_childs = {}
}



local ticks = 0
local tick_message = 0
local TYPE_ROBOT = consts.TYPE_ROBOT.DRONE
local ROOT_ID = nil           -- this must be changed later 
                            -- according the priority
local ROBOT_UID = nil

local INTV_MSG = 10   -- each tick will send message

local STATE_ROBOT = consts.STATE_ROBOT.SEARCHING
local ROLE_ROBOT = nil
-- For the moment the pririty will be select according the id
-- i.e the drone cf1 has more priority to be the root than cf2
-- and cf_ has more priority than q_ (qupa robots)


-----------------------------------------------------------------
---             Principal Sequence                            ---
-----------------------------------------------------------------



function init()
    
    ROBOT_UID = UID[robot.id]
    ROOT_ID = ROBOT_UID
    local_topolgy["parentId"] = ROBOT_UID
    log(string.format("Initilizing CF robot %s and its type robot is: %d", ROBOT_UID, TYPE_ROBOT))
    ticks = 0
    funcs_UAV.init_random_walk(robot)
    robot.quadrotor.set_linear_velocity(0.0,0.0,0.0)
    robot.quadrotor.set_rotational_speed(0.0)
    
end



function step()
    ticks = ticks + 1
    tick_message = tick_message + 1
    if(STATE_ROBOT == consts.STATE_ROBOT.SEARCHING) then
        --log(string.format("START RANDOM WALK"))
        funcs_UAV.random_walk(robot)
        -- SEND MSG. It is irrelavant what type of message
        -- will send it
        if(tick_message >= INTV_MSG) then
            tick_message = 0
            --log(string.format("SENDING A MESSAGE FOR BUILD THE TOP"))
            funcs_UAV.send_searching_msg(robot, ROBOT_UID, local_topolgy["parentId"], STATE_ROBOT)
            funcs_UAV.update_topolgy(robot, ROBOT_UID, local_topolgy)
            funcs_common.print_topology(ROBOT_UID, local_topolgy)
            ROLE_ROBOT =  funcs_UAV.detect_role(local_topolgy)

            --log(string.format("The role of the robot %d is %d", ROBOT_UID, ROLE_ROBOT))
            
        end

        

    end
    
end


function reset()
    ticks = 0;
end


function destroy()
    ticks = 0;
end