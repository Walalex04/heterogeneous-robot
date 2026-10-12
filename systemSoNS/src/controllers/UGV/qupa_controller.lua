--[[pcall(function() os.setlocale("C", "numeric") end)

package.path = "../../controllers/common/?.lua;" .. package.path

local consts = require("constants")
local funcs_qupa = require("functions_q")
local funcs_common = require("functions_common")
local func_beh_brain = require("SoSNAlg.brain_behavior")
]]

pcall(function() os.setlocale("C", "numeric") end)
package.path = "../../controllers/models/?.lua;" .. package.path

local ParentRobot = require("ParentRobot")
local ChildRobot  = require("ChildRobot")


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



--[[
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


]]

local ticks = 0
ParentRobot.Robot.RobotPhyParam.robotID     = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotRANk   = UID[robot.id]
ParentRobot.Robot.RobotPhyParam.robotType   = ParentRobot.Robot.TypeRobot.QUPA

local state = "FORWARD" -- Estados posibles: "FORWARD", "TURNING", "ESCAPE"
local ticks_counter = 0
local current_turn_dir = 1
-----------------------------------------------------------------
----          Function own qupa
----------------------------------------------------------------

function random_walk_logic()

    -- ESTADO 1: GIRANDO (Más tiempo para asegurar una rotación completa de ~180°)
    if state == "TURNING" then
        robot.wheels.set_velocity(-current_turn_dir * 6.0, current_turn_dir * 6.0)
        ticks_counter = ticks_counter - 1
        
        if ticks_counter <= 0 then
            -- Al terminar el giro, pasa obligatoriamente al estado de escape (avanzar recto)
            state = "ESCAPE"
            ticks_counter = 30 -- Ticks que avanzará recto para alejarse de la pared/límite
        end
        return
    end

    -- ESTADO 2: ESCAPANDO (Avanza recto sí o sí para reingresar al área segura)
    if state == "ESCAPE" then
        robot.wheels.set_velocity(10.0, 10.0)
        ticks_counter = ticks_counter - 1
        
        if ticks_counter <= 0 then
            -- Regresa al comportamiento normal de Random Walk
            state = "FORWARD"
        end
        return
    end

    -- ESTADO 3: FORWARD (Comportamiento normal / Búsqueda de eventos)
    
    -- 1. Revisar sensores IR (umbral 0.06)
    local obstacle_detected = false
    if robot.proximity then
        for i = 1, #robot.proximity do
            if robot.proximity[i].value > 0.06 then
                obstacle_detected = true
                break
            end
        end
    end

    -- 2. Revisar límites en X y Y (-3.1 a 3.1)
    local x_pos = 0.0
    local y_pos = 0.0
    if robot.positioning and robot.positioning.position then
        x_pos = robot.positioning.position.x
        y_pos = robot.positioning.position.y
    end
    
    local out_of_bounds = (x_pos > 3.1 or x_pos < -3.1 or y_pos > 3.1 or y_pos < -3.1)

    -- 3. Si hay obstáculo o sale del límite, inicia el proceso de giro y escape
    if obstacle_detected or out_of_bounds then
        state = "TURNING"
        -- Aumentado a 40-60 ticks para garantizar un giro completo de 180°
        ticks_counter = math.random(160, 180) 
        current_turn_dir = (math.random() > 0.5) and 1 or -1
        
        robot.wheels.set_velocity(-current_turn_dir * 6.0, current_turn_dir * 6.0)
    else
        -- Marcha normal (Random Walk recto con ligeras variaciones)
        if math.random() < 0.05 then
            robot.wheels.set_velocity(7.0, 10.0)
        else
            robot.wheels.set_velocity(10.0, 10.0)
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


    
    robot.wheels.set_velocity(0.0,0.0)

    ]]
    ticks = 0
    ParentRobot.init(robot) -- initilize all variables
    ChildRobot.init(ParentRobot.Robot)  -- relationship the same object
    ParentRobot.Robot.set_target_graph(nil) --all qupa init like child
    ParentRobot.Brain = nil
    robot.wheels.set_velocity(0.0,0.0)
    
end



function step()
    ticks = ticks + 1

    -- sense data
    ParentRobot.Robot.senseEnvRB()
    ChildRobot.response_recruiment()

    ChildRobot.respond_unlike_msg() -- when parent send a unlike msg
    ParentRobot.response_unlike()   -- when child want unlike


    --ParentRobot.request_recruiment() -- the method verify if it -- for the moment is not necessary for qupa
    --ParentRobot.making_topology_msg();

    
    --random_walk_logic()
    --ChildRobot.apply_commands(ChildRobot.Robot.TypeRobot.QUPA)
    ParentRobot.Robot.sendData();
end


function reset()

end


function destroy()
 
end