package.path = "../../controllers/utils/?.lua;" .. package.path


local protocol = require("Protocol")
local Helpers = require("helper_functions")

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

--- Pointer to msh unlike
---@type Table
Robot.MSGReceiveUnlike = protocol.rec_msg_unlike 


--- Pointer to msh unlike from child
---@type Table
Robot.MSGReceiveUnlikeChild = protocol.rec_msg_unlike_child

--- Pointer to msg target
---@type Table
Robot.MSGReceiveTargetGraph = protocol.rec_msg_targetGraph

Robot.MSGReceiveCMDtarget = protocol.rec_msg_command

--- Pointer to stack message 
---@type Table
Robot.StackMsg = protocol.stack_msg

--- Pointer to sreruiment sent message
---@type Table
Robot.MSGSendRecruiment = protocol.msg_recruiment

--- Pointer to sreruiment sent command
---@type Table
Robot.MSGSendCommand = protocol.msg_command

Robot.absolute_pos = nil

Robot.protocol = protocol

--- Variable that associate the target childs
--- but when the system is not associate
--- later must be syncronize with ChildsRobot
Robot.Target_childs  = {} 

--- Matriz childs of current robot
---@type [RobotPhyParam.robotID, Robot.StateConRobot, integer]
Robot.ChildsRobot = {}


Robot.quant_target_child_drone = 0
Robot.quant_target_child_qupa = 0
Robot.quant_target_child_blimp = 0


Robot.quant_current_child_drone = 0
Robot.quant_current_child_qupa = 0
Robot.quant_current_child_blimp = 0



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

--- Function that get the target of principals childs
function Robot.get_child_target_graph()
    Robot.Target_childs = {}
    Robot.quant_target_child_drone = 0
    Robot.quant_target_child_qupa = 0
    Robot.quant_target_child_blimp = 0
    for i, node in ipairs(Robot.TargetGraph.children) do
        table.insert(Robot.Target_childs, node.value)
        if(node.value.type == Robot.TypeRobot.DRONE) then
            Robot.quant_target_child_drone = 
                Robot.quant_target_child_drone + 1
        elseif (node.value.type == Robot.TypeRobot.QUPA) then
            Robot.quant_target_child_qupa = 
                Robot.quant_target_child_qupa + 1
        elseif (node.value.type == Robot.TypeRobot.BLIMP) then
            Robot.quant_target_child_blimp = 
                Robot.quant_target_child_blimp + 1
        end
    end

    log(string.format("There are %d target children (Drone: %d, Qupa: %d, Blimp: %d)", 
    #Robot.Target_childs,
    Robot.quant_target_child_drone,
    Robot.quant_target_child_qupa,
    Robot.quant_target_child_blimp
))
end


--- Function data update the parameters of parent 
---@param Integer The parent robot of Id
function Robot.update_parent(parentId)
    log(string.format("The parent Id of function is %i", parentId or 0))
    --if(parentId ~= Robot.IntRobot.SoSNRootID) then
        Robot.IntRobot.SoSNLastID = Robot.IntRobot.SoSNRootID
        Robot.IntRobot.SoSNLastRootRank  = Robot.IntRobot.SoSNRootRank
        Robot.IntRobot.SoSNRootID = parentId or Robot.IntRobot.RobotID
        Robot.IntRobot.SoSNRootRank = parentId or Robot.IntRobot.RobotID
    --end
    
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
    if(protocol.msg_recruiment.QUANT_MSG > 0) then
        -- there are a exiting message
        return
    end
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


--- The function allow 
function Robot.make_unlike_msg(recipent_id)
    log(string.format("The robot id %i is sent a unlike message to %i",
            Robot.RobotPhyParam.robotID, recipent_id))
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


--- The function allow 
function Robot.make_command_msg(recipent_id, x, y, z, yaw)
    --log(string.format("The robot id %i is sent a command message to %i (x,y,z,yaw) = (%.2f,%.2f,%.2f,%.2f)",
    --        Robot.RobotPhyParam.robotID, recipent_id, x, y, z, yaw))
            
    math.randomseed(os.time() + Robot.IntRobot.RobotID * 10)
    local id_msg = math.random(0, 255)

    -- Procesar coordenadas y yaw usando tu función de ayuda para MSB y LSB (con soporte para negativos)
    local x1, x2     = Helpers.process_axis(x)
    local y1, y2     = Helpers.process_axis(y)
    local z1, z2     = Helpers.process_axis(z)
    local yaw1, yaw2 = Helpers.process_axis(yaw)
    --log(string.format("yaw1: %.4f yaw2: %.4f", yaw1, yaw2))
    protocol.build_command_msg({
        sender_id     = Robot.IntRobot.RobotID,
        type_msg      = protocol.TypeMsg.COMMAND_MSG, -- o el tipo correspondiente
        packet_id     = id_msg,
        quant_packets = 1,
        index_packet  = 1,
        target_id     = recipent_id,
        
        tar_pos_x_1   = x1,
        tar_pos_x_2   = x2,
        tar_pos_y_1   = y1,
        tar_pos_y_2   = y2,
        tar_pos_z_1   = z1,
        tar_pos_z_2   = z2,
        tar_yaw_1     = yaw1,
        tar_yaw_2     = yaw2,
    })
end


--- The functoin manage the message type that
--- the robot recive and later it manages te msg
---@param robot Table Interface robot for argos 
function Robot.senseEnvRB()
    -- this will clasify the msg
    local rab = Robot.IntRobot.range_and_bearing
    for _,packet in ipairs(rab) do 
        local range = packet.range
        local hor_bearing = packet.horizontal_bearing 
        local ver_bearing = packet.vertical_bearing 
        
        
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

        elseif (typeMsg == protocol.TypeMsg.UNLIKE_MSG) and 
                (destinatary == Robot.RobotPhyParam.robotID) then
            --log("entry to decode unlike msg from the robot %i to %i",packet["data"][1]   ,Robot.RobotPhyParam.robotID)
            if(packet["data"][1] > Robot.RobotPhyParam.robotID) then
                --from child
                protocol.decode_unlike_msg_fchild(packet["data"])
            else 
                --from parent
                protocol.decode_unlike_msg(packet["data"])
            end
            

        elseif (typeMsg == protocol.TypeMsg.TARGET_GRAPH_MSG) and 
            (destinatary == Robot.RobotPhyParam.robotID)  then
            protocol.decode_target_msg(packet["data"])

        elseif (typeMsg == protocol.TypeMsg.COMMAND_MSG) and 
            (destinatary == Robot.RobotPhyParam.robotID)  then 

            protocol.decode_command_msg(packet["data"], range, hor_bearing, ver_bearing)

            ---- TODO: HACER UNA FUNCION QUE RECOJA LA INORMACION DEL STACK Y APLIQUE LOS COMANDOS 

        end

    end
end




return Robot