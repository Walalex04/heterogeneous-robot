local protocol = require("Protocol")


local Robot = {}


--------------------------------------------------
---                    ENUMS
-------------------------------------------------


--- Enum for state of graph
---@enum Robot.StateCarGraph
Robot.StateCarGraph = {
    -- The local system is recruimenting
    RECRUIMENT  = 1,
    -- The local system was ready but now is updating 
    UPDATING    = 2,
    -- The local system is ready for instructions
    READY       = 3 
}

--- Enum Communication for coordinate recruiment
---@enum Robot.StateComRobot
Robot.StateComRobot = {
    -- The recruiment is waiting for child's response
    WAITING         = 1,
    -- The recruiment was accept
    READY           = 2,
    -- The robot was recruiment but it is neccesary send te graph
    UPDATING_GRAPH  = 3
}

--- Enum Communication for coordinate recruiment
---@enum Robot.TypeRobot
Robot.TypeRobot = {
    -- TYPE QUPA ROBOT
    QUPA        = 1,
    --TYPE DRONE ROBOT
    DRONE       = 2,
    -- TYPE BLIMP ROBOT
    BLIMP       = 3 
}

-----------------------------------------------------
---             Variables
-----------------------------------------------------

--- Table of physic parameters
---@type {robotID: integer, robotRANK: integer}
Robot.RobotPhyParam = {
    robotID = 0,
    robotRANK = 0,
    robotType = 0
}

--- The interface between argos and lua
---@type {robotID: integer, robotRANK: integer}
Robot.IntRobot = {}


--- Matriz parents of current robot
---@type [RobotPhyParam.robotID, Robot.StateConRobot]
Robot.ParentRobot = {}

--- Target Graph
---@type [graph]
Robot.TargetGraph = {}


--- MSG to send
---@type [integer(64)]
Robot.MsgToSend = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}   -- 64 BYTES


--- Pointer to msg recruiment 
---@type Table
Robot.MSGReceiveRecruimente = protocol.rec_msg_recruiment 

--- Pointer to msg response 
---@type Table
Robot.MSGReceiveResponse = protocol.rec_msg_response 

--- Pointer to stack message 
---@type Table
Robot.StackMsg = protocol.stack_msg

--- To initilize the variables of robot
--- NOTE:IT IS IMPORTANTE INTACE BEFORE Robot.RobotPhyParam
---@param robot Table Interface robot for argos 
function Robot.init(robot)
    --Initilize variables associate to robot model
    robot.SoSNRootID    = Robot.RobotPhyParam.robotID -- all initilize as root 
    robot.SoSNRootRank  = Robot.RobotPhyParam.robotRANk
    robot.SoSNLastID    = Robot.RobotPhyParam.robotID
    robot.RobotID       = Robot.RobotPhyParam.robotID
    robot.RobotRank     = Robot.RobotPhyParam.robotRANk
    robot.RobotType     = Robot.RobotPhyParam.robotType
    robot.StateCarGraph = Robot.StateCarGraph.RECRUIMENT
    robot.ChildsRobot   = Robot.ChildsRobot
    robot.ParentRobot   = Robot.ParentRobot
    robot.DownCard      = 0;
    robot.DownHighCard  = 0;
    robot.TargetGraph   = Robot.TargetGraph;

    Robot.IntRobot = robot -- assign the pointer
end
--- Function that allow modify the target graph correctly
--- @param graph The current graph
function Robot.set_target_graph(graph)
    Robot.TargetGraph = graph
    Robot.IntRobot.TargetGraph = Robot.TargetGraph
end


--- Function data update the parameters of parent 
---@param Integer The parent robot of Id
function Robot.update_parent(parentId)
    Robot.IntRobot.SoSNRootID = parentId
    Robot.IntRobot.SoSNRootRank = parentId
end


--- The function helps to send data through R&B 
--- Ang manage the msg that will be send    
function Robot.sendData()
    -- It is possible that we need a function
    -- to handle the messages to be sent.
    -- Remember: only one message will be sent per tick.

    
    Robot.MsgToSend = protocol.select_type_msg()
    Robot.IntRobot.range_and_bearing.set_data(Robot.MsgToSend)
end


--- The function allow make a recruiment message
function Robot.make_recruiment_msg()
    math.randomseed(os.time() + Robot.IntRobot.RobotID *10)
    local id_msg = math.random(0, 255)
    protocol.stack_msg[id_msg] = protocol.TypeMsg.RRECRUIMENT_MSG
    protocol.build_recruitment_packet({
        sender_id       = Robot.IntRobot.RobotID,
        type_msg        = protocol.TypeMsg.RRECRUIMENT_MSG,
        packet_id       = id_msg,   -- for this context it is irrelevant
        quant_packets    = 1,
        index_packet    = 1,
        target_id       = 0, -- boardcast
        sosn_rank       = Robot.IntRobot.SoSNRootRank
    })
end


--- The function allow make a recruiment message
function Robot.make_response_msg(recipent_id, id_msg, response)
    --log(string.format("The robot %i is sent a message of response %i to %i",
    --    Robot.IntRobot.RobotID, response, recipent_id))
    protocol.build_response_msg({
        sender_id       = Robot.IntRobot.RobotID,
        type_msg        = protocol.TypeMsg.RESPONSE_MSG,
        packet_id       = id_msg,   -- for this context it is irrelevant
        quant_packets   = 1,
        index_packet    = 1,
        target_id       = recipent_id,
        response        = response
    })
end

--[[
TODO:
    La funcion ya funciona correctamente ahora es necesario que la contraparte
    recepte el mensaje y desaocie al padre, no es necesario que reponsa el 
    mensaje, debera ser de la misma forma a que se ha venido haciendo 
    se debera recibir el mensaje, procesarlo y almacenarlo en la variable
    y comprobar que este sea diferente de vacio para lanzar el metodo que 
    desaociara al padre, considere que este metodo debera ser usado cuando 
    el propio hijo querra desasociarce (ahora el "padre" lo desasocia) 
]]
--- The function allow 
function Robot.make_unlike_msg(recipent_id)
    math.randomseed(os.time() + Robot.IntRobot.RobotID *10)
    local id_msg = math.random(0, 255)
    protocol.build_unlike_msg({
        sender_id       = Robot.IntRobot.RobotID,
        type_msg        = protocol.TypeMsg.UNLIKE_MSG,
        packet_id       = id_msg,   -- for this context it is irrelevant
        quant_packets   = 1,
        index_packet    = 1,
        target_id       = recipent_id,
    })
end


--- The functoin manage the message type that
--- the robot recive and later it manages te msg
---@param robot Table Interface robot for argos 
function Robot.senseEnvRB()
    -- this will clasify the msg
    local rab = Robot.IntRobot.range_and_bearing
    for _,packet in ipairs(rab) do 
        local typeMsg = packet["data"][2] -- position for the type msg (all msg must be get)
        local destinatary = packet["data"][6]  
        -- classify the msg for later to process
        if(typeMsg == protocol.TypeMsg.RRECRUIMENT_MSG)then  
            -- decode data
            --log(string.format("the robot %i recieve a " .. 
            --    " recruiment msg from robot %i", Robot.RobotPhyParam.robotID, packet["data"][1]))
            protocol.decode_recruitment_packet(packet["data"], Robot.IntRobot.SoSNRootRank, Robot.IntRobot.SoSNLastID)
            Robot.IntRobot.data_recruiment = protocol.rec_msg_recruiment
        elseif((typeMsg == protocol.TypeMsg.RESPONSE_MSG) and
                (destinatary == Robot.RobotPhyParam.robotID)) then
            --log(string.format("the robot %i recieve a " .. 
            --    " response msg from robot %i", Robot.RobotPhyParam.robotID, packet["data"][1]))
            protocol.decode_response_msg(packet["data"])
        end

    end
end




return Robot