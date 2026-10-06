local Robot = require("Robot")
local protocol = require("Protocol")   --only for enums

local ChildRobot = {}

ChildRobot.Robot = Robot



--- parent Id robot
---@type Integer
ChildRobot.ParentRobot = nil

--- Function that relatinship elements of  
--- principal robot (all point to the same objetc)
---@param Robot Table The principal object
function ChildRobot.init(Robot)
    ChildRobot.Robot = Robot
end 



--- Function that allow responde the recruiments msg
function ChildRobot.response_recruiment()
    local msgs = ChildRobot.Robot.MSGReceiveRecruimente;
    for id, value in pairs(msgs) do
        --log(string.format("The robot %i has a new message recruiment of %i", 
        --            ChildRobot.Robot.RobotPhyParam.robotID, id))

        if(ChildRobot.ParentRobot == nil) then 
            -- it mean that the current robot does not has parent
            --log(string.format("The robot %i has a new parent %i and it id packet is %i", 
            --        ChildRobot.Robot.RobotPhyParam.robotID, id, value.msg.header.packet_id))
            --log(string.format("The robobt %i accept to be child of %i and this has id packet of %i", 
            --                ChildRobot.Robot.RobotPhyParam.robotID, id, value.msg.header.packet_id))
            ChildRobot.ParentRobot = id
            ChildRobot.Robot.update_parent(ChildRobot.ParentRobot)
            ChildRobot.Robot.make_response_msg(ChildRobot.ParentRobot, value.msg.header.packet_id, protocol.ResponseMsg.ACCEPT)
        elseif (ChildRobot.ParentRobot ~= id) then
            --log(string.format("The robobt %i reject to be child of %i", 
            --                ChildRobot.Robot.RobotPhyParam.robotID, id))
            ChildRobot.Robot.make_response_msg(id, value.msg.header.packet_id, protocol.ResponseMsg.REJECTED)
        end 
    end
end

return ChildRobot