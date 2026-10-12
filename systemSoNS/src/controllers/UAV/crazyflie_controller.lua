pcall(function() os.setlocale("C", "numeric") end)
package.path = "../../controllers/models/?.lua;" .. package.path
package.path = "../../controllers/utils/?.lua;" .. package.path
local ParentRobot = require("ParentRobot")
local ChildRobot  = require("ChildRobot")
local Helpers = require("helper_functions")
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
    cf4 = 5,
    cf5 = 6,
    cf6 = 7,
    cf7 = 8

}

-- initilize physic variables
ParentRobot.Robot.RobotPhyParam.robotID     = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotRANk   = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotType   = ParentRobot.Robot.TypeRobot.DRONE

local apriltag_array = {}


---------------------------------------------------------------
-----            Function own crazyflie
--------------------------------------------------------------

function update_apriltags()
    apriltag_array = {}
    
    if robot.apriltag then
        for i = 1, #robot.apriltag do
            local tag = robot.apriltag[i]
            table.insert(apriltag_array, {
                id = tag.id,
                angle = tag.angle,
                distance = tag.distance,
                x = tag.x,
                yaw = tag.yaw
            })
        end
    end
    
end

local state = "FORWARD" -- Estados: "FORWARD", "TURNING", "ESCAPE"
local ticks_counter = 0
local current_turn_dir = 1
-----------------------------------------------------------------
----          Function para Ruta Fija y Giros Suaves (Crazyflie)
----------------------------------------------------------------

function fixed_path_logic()

    -- ESTADO 1: GIRANDO (Giros suaves y controlados usando 0.1)
    if state == "TURNING" then
        robot.quadrotor.set_linear_velocity(0.0, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(current_turn_dir * 0.1) -- Giro suave basado en 0.1
        ticks_counter = ticks_counter - 1
        
        if ticks_counter <= 0 then
            -- Al terminar el giro, pasa al estado de avance recto (escape/reingreso)
            state = "ESCAPE"
            ticks_counter = 40 -- Ticks que avanza recto para reingresar al área segura
        end
        return
    end

    -- ESTADO 2: ESCAPANDO (Avanza de forma estable y constante usando 0.1)
    if state == "ESCAPE" then
        robot.quadrotor.set_linear_velocity(0.1, 0.0, 0.0) -- Avance constante a 0.1
        robot.quadrotor.set_rotational_speed(0.0)
        ticks_counter = ticks_counter - 1
        
        if ticks_counter <= 0 then
            -- Retorna al patrullaje normal
            state = "FORWARD"
        end
        return
    end

    -- ESTADO 3: FORWARD (Patrullaje de ruta fija y control de límites)
    local x_pos = 0.0
    local y_pos = 0.0
    if robot.positioning and robot.positioning.position then
        x_pos = robot.positioning.position.x
        y_pos = robot.positioning.position.y
    end
    
    -- Verificación de los límites de la arena (-1.5 a 1.5)
    local out_of_bounds = (x_pos > 1.5 or x_pos < -1.5 or y_pos > 1.5 or y_pos < -1.5)

    if out_of_bounds then
        state = "TURNING"
        ticks_counter = 50 -- Duración del giro suave
        current_turn_dir = (math.random() > 0.5) and 1 or -1
        
        robot.quadrotor.set_linear_velocity(0.0, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(current_turn_dir * 0.1)
    else
        -- Ruta fija: Avance lineal constante y suave utilizando el valor base de 0.1
        robot.quadrotor.set_linear_velocity(0.1, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(0.0)
    end
end


function crazyflie_approach_behavior()
    if not ParentRobot or not ParentRobot.Brain or type(ParentRobot.Brain.updateTargetGraph) ~= "function" then
        return
    end

    local tag_detected = false
    local tag_x = 0.0
    local tag_y = 0.0

    if robot.apriltag and #robot.apriltag > 0 then
        for i = 1, #robot.apriltag do
            if robot.apriltag[i].id == 106 then
                tag_detected = true
                tag_x = robot.apriltag[i].x
                tag_y = robot.apriltag[i].y
                break
            end
        end
    end

    if tag_detected then
        if math.abs(tag_x) < 0.15 and math.abs(tag_y) < 0.15 then
            robot.quadrotor.set_linear_velocity(0.0, 0.0, 0.0)
            robot.quadrotor.set_rotational_speed(0.0)
        else
            local drone_pos = robot.positioning.position
            local target_center_x = drone_pos.x + tag_x
            local target_center_y = drone_pos.y + tag_y

            local new_formation = {
                { x = target_center_x + 0.0, y = target_center_y + 0.0,   yaw = 0 },
                { x = target_center_x + 0.1, y = target_center_y + 0.1,   yaw = 0 },
                { x = target_center_x + 0.1, y = target_center_y - 0.1,   yaw = 0 },
                { x = target_center_x - 0.1, y = target_center_y + 0.1,   yaw = 0 },
                { x = target_center_x - 0.1, y = target_center_y - 0.1,   yaw = 0 }
            }
            ParentRobot.Brain.updateTargetGraph(new_formation)
            ParentRobot.get_child_target_graph()
            robot.quadrotor.set_linear_velocity(0.08, 0.0, 0.0)
            robot.quadrotor.set_rotational_speed(0.0)
        end
    else
        robot.quadrotor.set_linear_velocity(0.1, 0.0, 0.0)
        robot.quadrotor.set_rotational_speed(0.0)
    end
end


function verify_com_qupa_child()
    if(ParentRobot.Robot.ChildsRobot == nil) then return end
    for i, child in pairs(ParentRobot.Robot.ChildsRobot) do
        if(child[1] > 99 and child[1] < 199) then 
            if(not Helpers.exist_id(child[1], apriltag_array)) then
                ParentRobot.unlike_child(child[1])
            end
        end
    end

end
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
    update_apriltags()
    --verify_com_qupa_child()

    -- Response and process message
    ChildRobot.response_recruiment()
    if(ChildRobot.ParentRobot ~= nil) then
        ParentRobot.Brain = nil
    end

    ChildRobot.respond_unlike_msg() -- when parent send a unlike msg
    ParentRobot.response_unlike()   -- when child want unlike

    -- Accept child it is neccesary
    ParentRobot.admit_child(false,apriltag_array)
    
    if(ChildRobot.receive_target()) then -- receive the target when there are message
        ParentRobot.Robot.get_child_target_graph() -- udpate the new target only if there is a new change
    end 
    
    ParentRobot.request_recruiment() -- the method verify if it
    ParentRobot.making_topology_msg();

    ChildRobot.apply_commands()
    if(ParentRobot.Brain ~= nil) then 
        --robot.quadrotor.set_rotational_speed(0.05)  
        --fixed_path_logic()
        --crazyflie_approach_behavior()
    end


    ParentRobot.Robot.sendData();



end


function reset()
    ticks = 0;
end


function destroy()
    ticks = 0;
end