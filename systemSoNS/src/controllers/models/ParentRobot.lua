local Robot = require("Robot")
local Brain = require("BrainRobot")
local Protocol = require("Protocol") --- only for enums


local ParentRobot = {}


ParentRobot.Robot   = Robot   --pointer of method
ParentRobot.Brain   = Brain   -- all robot start as brain
                            -- later this object point to nil


--- Variable that associate the target childs
--- but when the system is not associate
--- later must be syncronize with ChildsRobot
ParentRobot.Target_childs  = {} 


--- Matriz childs of current robot
---@type [RobotPhyParam.robotID, Robot.StateConRobot, integer]
ParentRobot.ChildsRobot = {}


--- Function that allow initilize the instance
---@param robot Table Interface between argos and lua
function ParentRobot.init(robot)
    
    ParentRobot.Robot.init(robot)
    -- initilize the target graph (all robot as brain)
    ParentRobot.Robot.set_target_graph(ParentRobot.Brain.updateTargetGraph())
    ParentRobot.get_child_target_graph()
    --robot.target_childs = ParentRobot.Target_childs   --only for debug
    --log("there are " .. #ParentRobot.Target_childs .. " targets child")
end

--- Function that get the target of principals childs
function ParentRobot.get_child_target_graph()
    for i, node in ipairs(ParentRobot.Robot.TargetGraph.children) do
        table.insert(ParentRobot.Target_childs, node.value)
    end
end


--- Function that get the target of principals childs
function ParentRobot.admit_child()
    local msgs = ParentRobot.Robot.MSGReceiveResponse;
    --[[
        TO DO :
        RECORRER LA LISTA DE MENSAJES QUE SE RECIBIERON DE LOS HIJOS
        IGNORAR LOS REJECTED POR QUE NO APORTAR NADA MAS QUE INFORMACION ACTUAL
        DE LOS QUE ACEPTARON AGREGAR LOS MEJORES RANKEADOS (USUALMENTE LOS MENSAJES SE ORDEN YA DE ESA FORMA)
        Y LOS QUE QUEDEN Y QUE HAYAN ACEPTADO AL PADRE ENTONCES SE DEBEN ENVIAR UN MENSAJE DE DESPARENTAR
    ]]
    --ParentRobot.Robot.IntRobot.childs_request = msgs;
    ParentRobot.Robot.IntRobot.stack_request = ParentRobot.Robot.StackMsg
    for id, value in pairs(msgs) do 
        for idmsg, type in pairs(ParentRobot.Robot.StackMsg) do 
            if(idmsg == value.msg.header.packet_id and type == Protocol.TypeMsg.RRECRUIMENT_MSG) then 
                if(value.msg.payload.response == Protocol.ResponseMsg.ACCEPT) then
                --log(string.format("The robot %i receive an accept response from robot %i",
                --            ParentRobot.Robot.RobotPhyParam.robotID, id))
                    if((not ParentRobot._is_child(id)) and (#ParentRobot.ChildsRobot < #ParentRobot.Target_childs)) then 
                        log(string.format("The robot %i will add %i as its child",
                                        ParentRobot.Robot.RobotPhyParam.robotID, id))
                        table.insert(ParentRobot.ChildsRobot, {id, Robot.StateComRobot.UPDATING_GRAPH})
                        ParentRobot.Robot.IntRobot.current_childs = ParentRobot.ChildsRobot
                    elseif(#ParentRobot.ChildsRobot >= #ParentRobot.Target_childs) then 
                        log(string.format("The robot %i will send an unlike msg to %i",
                                        ParentRobot.Robot.RobotPhyParam.robotID, id))
                        ParentRobot.Robot.make_unlike_msg(id)
                    end
                end
            end
        end
        
    end
end


-----------------------------------------------------
----        Helper functions
-----------------------------------------------------

--- function that verify if one robot is a child 
---@param RobotId Integer The id that will use for verification
---@return Bool if it is a child
function ParentRobot._is_child(RobotId)
    for i, list in ipairs(ParentRobot.ChildsRobot) do 
        if list[1] == RobotId then 
            return true
        end 
    end

    return false
end

return ParentRobot