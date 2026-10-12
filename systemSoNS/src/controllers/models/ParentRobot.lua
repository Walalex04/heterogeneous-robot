package.path = "../../controllers/utils/?.lua;" .. package.path
local Robot = require("Robot")
local Brain = require("BrainRobot")
local Protocol = require("Protocol") --- only for enums
local Helpers = require("helper_functions")

local ParentRobot = {}


ParentRobot.Robot   = Robot   --pointer of method
ParentRobot.Brain   = Brain   -- all robot start as brain
                            -- later this object point to nil




--- Function that allow initilize the instance
---@param robot Table Interface between argos and lua
function ParentRobot.init(robot)
    
    ParentRobot.Robot.init(robot)
    -- initilize the target graph (all robot as brain)
    ParentRobot.Robot.set_target_graph(ParentRobot.Brain.updateTargetGraph())
    Robot.get_child_target_graph()

    --robot.target_childs = Robot.Target_childs   --only for debug
    --log("there are " .. #Robot.Target_childs .. " targets child")
    
end


function ParentRobot.request_recruiment()
    --verify if is neccesary send a recruiement msg
    robot.targetchild = Robot.Target_childs
    if(#Robot.ChildsRobot < #Robot.Target_childs) then
        --log(string.format("The robot %i has not the enough quantity of childs" ..
        --             "o it will send recruiment message", ParentRobot.Robot.RobotPhyParam.robotID))
        ParentRobot.Robot.make_recruiment_msg()
    elseif (#Robot.ChildsRobot == #Robot.Target_childs) then
       -- deleting all message 
       
        ParentRobot.Robot.MSGSendRecruiment.QUANT_MSG = 0
        ParentRobot.Robot.MSGSendRecruiment.INDEX_MSG = 0
        ParentRobot.Robot.MSGSendRecruiment.MSG = {}
    end
end




--- Function that get the target of principals childs
function ParentRobot.admit_child(is_crazyflie, list_qupa)
    local msgs = ParentRobot.Robot.MSGReceiveResponse

    --ParentRobot.Robot.IntRobot.childs_request = msgs;
    ParentRobot.Robot.IntRobot.stack_request = ParentRobot.Robot.StackMsg
    for id, val in pairs(msgs) do 
        local value = val
        for idmsg, type in pairs(ParentRobot.Robot.StackMsg) do 
            if(idmsg == value.msg.header.packet_id and type == Protocol.TypeMsg.RRECRUIMENT_MSG) then 
                if(value.msg.payload.response == Protocol.ResponseMsg.ACCEPT) then
                --log(string.format("The robot %i receive an accept response from robot %i",
                --            ParentRobot.Robot.RobotPhyParam.robotID, id))
                    if((not ParentRobot._is_child(id)) and (#Robot.ChildsRobot < #Robot.Target_childs)) then 
                        
                        if(id < 99 and (Robot.quant_current_child_drone < Robot.quant_target_child_drone)) then
                            --  is a drone
                            log(string.format("The robot %i will add the drone %i as its child",
                                        ParentRobot.Robot.RobotPhyParam.robotID, id))
                            table.insert(Robot.ChildsRobot, {id, Robot.StateComRobot.UPDATING_GRAPH})
                            ParentRobot.Robot.IntRobot.current_childs = Robot.ChildsRobot
                            Robot.quant_current_child_drone = 
                                Robot.quant_current_child_drone + 1
                        elseif(id > 99 and id < 199 and (Robot.quant_current_child_qupa < Robot.quant_target_child_qupa)) then
                            ParentRobot.add_qupa(id, is_crazyflie, list_qupa)
                            Robot.quant_current_child_qupa = 
                                Robot.quant_current_child_qupa + 1
                        end
                        
                    elseif(#Robot.ChildsRobot >= #Robot.Target_childs)  and ((not ParentRobot._is_child(id)) ) then 
                        log(string.format("The robot %i will send an unlike msg to %i",
                                        ParentRobot.Robot.RobotPhyParam.robotID, id))
                        ParentRobot.Robot.make_unlike_msg(id)
                    end
                    
                end
            end
        end

        ParentRobot.Robot.MSGReceiveResponse[id] = nil
    end

end


function ParentRobot.add_qupa(id, is_crazyflie, list_qupa)
    -- it neccesary verify if there is in stack
    if(is_crazyflie) then
        -- it neccesary verify if there is in stack
        if(Helpers.exist_id(id, list_qupa))then 
            log(string.format("The robot %i will add the qupa %i as its child",
            ParentRobot.Robot.RobotPhyParam.robotID, id))
            table.insert(Robot.ChildsRobot, {id, Robot.StateComRobot.UPDATING_GRAPH})
                ParentRobot.Robot.IntRobot.current_childs = Robot.ChildsRobot
        else
            log(string.format("The parent robot %i perceives the qupa %i, but cannot add it as a child because it is not visible by the camera",
            ParentRobot.Robot.RobotPhyParam.robotID, id))
            -- TODO: ESTO GENERA UN PROBLEMA, PORQ CUANDO SE ENVIE 
            -- EL MENSAJE PARA QUE EL HIJO SE DESVINCULE
            -- ENTONCES YA NO PODRA SER ACEPTAO DE NUEVO
            -- POR LO QUE SE DEBE CREAR OTRO METODO DE COMUNICACION
            -- QUE PERMITA AGREGARLO AUQNUE HAYA SIDO RECHAZO
            ParentRobot.Robot.make_unlike_msg(id)
        end
    else
        log(string.format("The robot %i will add the qupa %i as its child",
        ParentRobot.Robot.RobotPhyParam.robotID, id))
        table.insert(Robot.ChildsRobot, {id, Robot.StateComRobot.UPDATING_GRAPH})
            ParentRobot.Robot.IntRobot.current_childs = Robot.ChildsRobot
    end 
end

--- Funcion that proccess all unliek message
function ParentRobot.response_unlike()
    local msgs =  ParentRobot.Robot.MSGReceiveUnlikeChild
      for id, value in pairs(msgs) do
        log(string.format("--------the robot %i has sent a unlink message", id))
        if(ParentRobot._is_child(id)) then
            ParentRobot.unlike_child(id)
        end
        ParentRobot.Robot.MSGReceiveUnlikeChild[id] = nil
    end
end

--- Delete a child of the list
function ParentRobot.unlike_child(id)
    for i, value in ipairs(Robot.ChildsRobot) do
        if(id == value[1]) then
            log(string.format("The robot %i unliking the child %i",
                ParentRobot.Robot.RobotPhyParam.robotID, value[1]))
            Robot.ChildsRobot[i] = nil
            ParentRobot.Robot.IntRobot.current_childs = Robot.ChildsRobot
            if(id < 99) then
                Robot.quant_current_child_drone = 
                                Robot.quant_current_child_drone - 1
            elseif id < 199 and id > 99 then
                Robot.quant_current_child_qupa = 
                        Robot.quant_current_child_qupa - 1
            end
        end
    end
end


--- trasnform from graph to array, and help to send the message
---@param list_of_child Table
---@param target_graph_child Table
function ParentRobot.make_array_message(list_of_child, target_graph_child)
    local children = {}
    for i, child in pairs(target_graph_child) do
        --log(child.value.id)
        children.id = child.value.id
        children.x = child.value.pose.x 
        children.y = child.value.pose.y 
        children.yaw = child.value.pose.yaw
        children.type = child.value.type
        --log(children.id)
        table.insert(list_of_child, children)
        children = {}
        if(#child.children ~= 0) then 
            ParentRobot.make_array_message(list_of_child, child.children)
        end
    end
    
end

--- Generate the fragments of messages and call a protocol function for saving on stack 
---@param id_child Integer
---@param array_childs Table
function ParentRobot.generating_graph_message(id_child, array_childs)
    local num_elements = #array_childs
    local field = {}
    local quant_packages = 0
    math.randomseed(os.time() + Robot.IntRobot.RobotID *10)
    local id_msg = math.random(0, 255)

    field.sender_id = Robot.RobotPhyParam.robotID
    field.type_msg = Protocol.TypeMsg.TARGET_GRAPH_MSG
    field.packet_id = id_msg
    field.index_packet = 0
    field.quant_packets = (num_elements +1)// 2
    field.target_id = id_child

    for i = 1, num_elements, 2 do 
        local id = array_childs[i].id
        
        field.level_child_1 = #tostring(id)         
        field.type_child_1 = array_childs[i].type
        field.id_child_1_1 = math.floor(id / 256) % 256 --MSB
        field.id_child_2_1 = id % 256                   --LSB
        field.pos_x1_child_1, field.pos_x2_child_1 = Helpers.process_axis(array_childs[i].x)
        field.pos_y1_child_1, field.pos_y2_child_1 = Helpers.process_axis(array_childs[i].y)
        field.pos_z1_child_1, field.pos_z2_child_1 = Helpers.process_axis(array_childs[i].z)
        field.yaw_1_child_1,  field.yaw_2_child_1  = Helpers.process_axis(array_childs[i].yaw)
        if array_childs[i+1] ~= nil then
            
            local id2 = array_childs[i + 1].id or 0
            --log(string.format("the id 2 is %i", id2))
            field.level_child_2 = #tostring(id2)
            field.type_child_2  = array_childs[i + 1].type or 0
            field.id_child_1_2  = math.floor(id2 / 256) % 256 -- MSB
            field.id_child_2_2  = id2 % 256                   -- LSB
            field.pos_x1_child_2, field.pos_x2_child_2 = Helpers.process_axis(array_childs[i + 1].x)
            field.pos_y1_child_2, field.pos_y2_child_2 = Helpers.process_axis(array_childs[i + 1].y)
            field.pos_z1_child_2, field.pos_z2_child_2 = Helpers.process_axis(array_childs[i + 1].z)
            field.yaw_1_child_2,  field.yaw_2_child_2  = Helpers.process_axis(array_childs[i + 1].yaw)
        end
        field.index_packet = field.index_packet + 1;
        Protocol.build_target_msg(field)
       
    end

end



--- function that relationship the children with target, this  
--- allow send target graph and commands
function ParentRobot.making_topology_msg()
    if((#Robot.ChildsRobot ~= #Robot.Target_childs) or (Robot.TargetGraph == nil)) then return end
    if(Robot.MSGSendCommand.QUANT_MSG ~= 0 or Robot.MSGSendCommand.INDEX_MSG ~= 0) then return end
    local graph_childrens = Robot.TargetGraph.children;
    local list_of_children = {}
    local children = {}

    --every old msg must be delete
    Robot.MSGSendCommand.QUANT_MSG = 0
    Robot.MSGSendCommand.INDEX_MSG = 0
    Robot.MSGSendCommand.MSG = {}

    for i, values in pairs(graph_childrens) do
        
        if(Robot.ChildsRobot[i][2] == Robot.StateComRobot.UPDATING_GRAPH) then 
            --log(string.format("We will the target graph of%i the index correspond to %i", i, Robot.ChildsRobot[i][1]))
            -- principal childs  
            -- the rest of the child
            ParentRobot.make_array_message(list_of_children, values.children)
            ParentRobot.generating_graph_message(Robot.ChildsRobot[i][1], list_of_children)

            Robot.ChildsRobot[i][2] = Robot.StateComRobot.READY
            ParentRobot.Robot.IntRobot.array_child_targ = list_of_children
            
        elseif(Robot.ChildsRobot[i][2] == Robot.StateComRobot.READY) then
            -- we will send the commands 
            local yaw = Robot.IntRobot.positioning.orientation.z 
            --log(string.format("the parent will sent %.2f", yaw))
            ParentRobot.Robot.make_command_msg(Robot.ChildsRobot[i][1], 
                values.value.pose.x,values.value.pose.y,0,yaw)

        end
        list_of_children = {}
    end 

    
    
end

-----------------------------------------------------
----        Helper functions
-----------------------------------------------------

--- function that verify if one robot is a child 
---@param RobotId Integer The id that will use for verification
---@return Bool if it is a child
function ParentRobot._is_child(RobotId)
    for i, list in ipairs(Robot.ChildsRobot) do 
        if list[1] == RobotId then 
            return true
        end 
    end

    return false
end


function ParentRobot.need_child()
    local need = (Robot.quant_target_child_drone - Robot.quant_current_child_drone > 0) or
                      (Robot.quant_target_child_qupa - Robot.quant_current_child_qupa > 0) or
                      (Robot.quant_target_child_blimp - Robot.quant_current_child_blimp > 0)

    return need
    
end

return ParentRobot