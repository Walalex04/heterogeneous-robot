pcall(function() os.setlocale("C", "numeric") end)

package.path = "../../controllers/common/?.lua;" .. package.path

local consts = require("constants")
local funcs_qupa = require("functions_q")
local funcs_common = require("functions_common")
local func_beh_brain = require("SoSNAlg.brain_behavior")

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




local childs = {}
local ids_childs_allowed = {}
local parent = {}
local allow_qupa_child = {}
local target_subgraph = {
    Av = {
        typei = {} -- types robots
    }, -- attributes associated to V

    Ae = {
        disp = {},      -- target relative displacement
        quat = {}       -- target relative quaternion
    },
    card_type = 0,     -- target cardinality (drone, qupa)
    card_high = 0    
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
    --local_topolgy["parentId"] = ROBOT_UID

    robot.ROBOT_UID = UID[robot.id]
    robot.ROBOT_TYPE = consts.TYPE_ROBOT.QUPA
    robot.ROBOT_RANK = UID[robot.id] -- we can change this

    robot.SoNS_ROOT_ID = UID[robot.id] -- this must be update when it can communicate
    robot.SoNS_ROOT_RANK = UID[robot.id] 
    robot.SoSN_ROOT_ID_OLD = UID[robot.id]
    robot.T_OLD = 0

    -- all robot start as BRAIN
    target_subgraph = func_beh_brain.target_graph

    

    log(string.format("Initilizing QUPA robot %s and its type robot is: %d", robot.ROBOT_UID , robot.ROBOT_TYPE))


    ticks = 0
    robot.wheels.set_velocity(0.0,0.0)
end



function step()
    ticks = ticks + 1
    if(robot.SoNS_ROOT_ID == robot.ROBOT_UID) then
        func_beh_brain.dynamic_behavior(robot, ticks)
        --funcs_qupa.random_walk(robot)
        func_beh_brain.sending_msg_recruiment(robot, childs, target_subgraph["card_type"], ticks, target_subgraph)
        
        func_beh_brain.recruitment(robot, ticks, childs, target_subgraph, ids_childs_allowed, parent, allow_qupa_child)
    end
end


function reset()

end


function destroy()
 
end