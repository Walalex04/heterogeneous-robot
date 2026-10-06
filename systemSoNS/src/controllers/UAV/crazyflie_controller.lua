pcall(function() os.setlocale("C", "numeric") end)
package.path = "../../controllers/models/?.lua;" .. package.path

local ParentRobot = require("ParentRobot")
local ChildRobot  = require("ChildRobot")
--[[

local consts = require("constants")
local funcs_UAV = require("functions_cf")
local funcs_common = require("functions_common")
local func_beh_brain = require("SoSNAlg.brain_behavior")
local func_beh_child = require("SoSNAlg.child_behavior")

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

]]
--[[
    i.e 
    if the robot has id equal to 100 
    the the Av[typei] = { 100 = typerobot}
    and Ae[disp] = {100 = {x = , y = }} and go on
]]
-- childs { UID = , STATE = [awaiting or acceptec or INTILIZING], ID_GRAPH}

--[[
local ids_childs_allowed = {}
local childs = {}
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
    card_type = {0,0,0},     -- target cardinality (drone, qupa)
    card_high = 0    
}
 local target_tree = {}

local ticks = 0
local tick_message = 0


local INTV_MSG = 10   -- each tick will send message

local STATE_ROBOT = consts.STATE_ROBOT.SEARCHING

local ROLE_ROBOT = nil
-- For the moment the pririty will be select according the id
-- i.e the drone cf1 has more priority to be the root than cf2
-- and cf_ has more priority than q_ (qupa robots)

]]


local ticks = 0


local UID = {
    cf0 = 1,
    cf1 = 2,
    cf2 = 3,
    cf3 = 4,
    cf4 = 6
}

-- initilize physic variables
ParentRobot.Robot.RobotPhyParam.robotID     = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotRANk   = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotType   = ParentRobot.Robot.TypeRobot.DRONE

-----------------------------------------------------------------
---             Principal Sequence                            ---
-----------------------------------------------------------------


function init()
    
    --[[
    ROBOT_UID = UID[robot.id]
    ROOT_ID = ROBOT_UID
    local_topolgy["parentId"] = ROBOT_UID
    log(string.format("Initilizing CF robot %s and its type" ..
                 "robot is: %d", ROBOT_UID, consts.TYPE_ROBOT.DRONE))
    ticks = 0

    -- making personalized variables
    robot.ROBOT_UID = UID[robot.id]
    robot.ROBOT_TYPE = consts.TYPE_ROBOT.DRONE
    robot.ROBOT_RANK = UID[robot.id] -- we can change this

    robot.SoNS_ROOT_ID = UID[robot.id] -- this must be update when it can communicate
    robot.SoNS_ROOT_RANK = UID[robot.id] 
    robot.SoSN_ROOT_ID_OLD = UID[robot.id]
    robot.T_OLD = 0

    robot.STATE = consts.STATE_ROBOT.SEARCHING
    robot.CARD_DRONE = 0
    robot.CARD_QUPA = 0
    -- all robot start as BRAIN

    log(string.format("The variables of the robot %d was configured ", robot.ROBOT_UID))

    --log(string.format("GENERATING GRAPH TARGET FOR ROBOT %d", robot.ROBOT_UID))
    target_tree = funcs_common.make_target_graph(func_beh_brain.global_graph)  -- the data strcuture
    target_subgraph = funcs_common.gen_tar_local_graph(target_tree, 3, ids_childs_allowed)


    log(ids_childs_allowed[1])
    --log(target_tree.children[1].id)


    funcs_common.traverse_graph(target_tree)

    funcs_common.printLocalTarget(target_subgraph, 0)
    

    funcs_UAV.init_random_walk(robot)
    robot.quadrotor.set_linear_velocity(0.0,0.0,0.0)
    robot.quadrotor.set_rotational_speed(0.0)
    ]]

    ParentRobot.init(robot) -- initilize all variables
    ChildRobot.init(ParentRobot.Robot)  -- relationship the same object
    robot.quadrotor.set_linear_velocity(0.0,0.0,0.0)
    robot.quadrotor.set_rotational_speed(0.0)
end



function step()
    ticks = ticks + 1

    -- sense data
    ParentRobot.Robot.senseEnvRB()

    -- Response and process message
    ChildRobot.response_recruiment()

    -- Accept child it is neccesary
    ParentRobot.admit_child()

    --verify if is neccesary send a recruiement msg
    if(#ParentRobot.ChildsRobot < #ParentRobot.Target_childs) then
        --log(string.format("The robot %i has not the enough quantity of childs" ..
        --             "o it will send recruiment message", ParentRobot.Robot.RobotPhyParam.robotID))
        ParentRobot.Robot.make_recruiment_msg()
    end
    
    ParentRobot.Robot.sendData();
    --[[
    tick_message = tick_message + 1

    allow_qupa_child = funcs_UAV.detect_apriltag(robot)
    --log(#allow_qupa_child)

    for robot_id, data in pairs(childs) do
        log(string.format("The role of the robot %d is %d", data.UID, data.STATE))
    end

    if(robot.SoNS_ROOT_ID ==  UID[robot.id])then 
        -- brain
        --log(string.format("the root id is %d", robot.ROBOT_UID))
        
        func_beh_brain.dynamic_behavior(robot, ticks)
        
        func_beh_brain.sending_msg_recruiment(robot, childs, target_subgraph["card_type"], ticks, target_subgraph)
        
        func_beh_brain.recruitment(robot, ticks, childs, target_subgraph, ids_childs_allowed, parent, allow_qupa_child)
       
    else
        --child
        func_beh_child.recruitment(robot, ticks, childs, target_subgraph, ids_childs_allowed, allow_qupa_child)
        func_beh_child.sending_msg_recruiment(robot, childs, target_subgraph["card_type"], ticks, parent)
        func_beh_child.recept_msg_graph(robot,target_tree, target_subgraph, ids_childs_allowed)        
        func_beh_child.recept_instructions(robot, parent)
    end
    --log(string.format("** la velocidad REAL del robot %d es vx = %.4f vy = %.4f vz = %.4f", robot.ROBOT_UID, robot.qua))
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
    ]]
end


function reset()
    ticks = 0;
end


function destroy()
    ticks = 0;
end