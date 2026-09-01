pcall(function() os.setlocale("C", "numeric") end)

package.path = "../../controllers/common/?.lua;" .. package.path

local consts = require("constants")
local funcs_qupa = require("functions_q")
local funcs_common = require("functions_common")


----------------------------------------------------------------
----                    CONSTANTS                         ------
----------------------------------------------------------------

local UID = {
    q101 = 101,
    q102 = 102,
    q103 = 103,
    q104 = 104,
    q105 = 105,
    q106 = 106,
    q107 = 107,
    q108 = 108,
    q109 = 109,
    q110 = 110
}



local local_topolgy = {
    parentId = nil,
    direct_childs = {}
}


local ticks = 0
local tick_message = 0
local TYPE_ROBOT = consts.TYPE_ROBOT.QUPA
local ROOT_ID = nil           -- this must be changed later 
                            -- according the priority
local ROBOT_UID = nil

local INTV_MSG = 10   -- each tick will send message

local STATE_ROBOT = consts.STATE_ROBOT.SEARCHING
local ROLE_ROBOT = nil


-----------------------------------------------------------------
---             Principal Sequence                            ---
-----------------------------------------------------------------



function init()
    ROBOT_UID = UID[robot.id]
    ROOT_ID = ROBOT_UID
    local_topolgy["parentId"] = ROBOT_UID
    log(string.format("Initilizing QUPA robot %s and its type robot is: %d", ROBOT_UID, TYPE_ROBOT))
    ticks = 0
    robot.wheels.set_velocity(0.0,0.0)
end



function step()
    ticks = ticks + 1
    tick_message = tick_message + 1
    if(STATE_ROBOT == consts.STATE_ROBOT.SEARCHING) then
        funcs_qupa.random_walk(robot)
        if(tick_message >= INTV_MSG) then
            tick_message = 0
            --log(string.format("SENDING A MESSAGE FOR BUILD THE TOP QUPA"))
            funcs_qupa.send_searching_msg(robot, ROBOT_UID, local_topolgy["parentId"], STATE_ROBOT)
            funcs_qupa.update_topolgy(robot, ROBOT_UID, local_topolgy)
            funcs_common.print_topology(ROBOT_UID, local_topolgy)
        end
    end
end


function reset()

end


function destroy()
 
end