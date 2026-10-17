package.path = "../../controllers/utils/?.lua;" .. package.path

local Robot = require("Robot")   -- only for enums
local Graph_functions = require("graph_functions")
local BrainRobot = {}


BrainRobot.Init_graph_target = {
    id = 0,
    pose = {x = 0, y = 0, yaw = 0},
    children = {
        {
            id = 11,
            type = Robot.TypeRobot.DRONE,
            pose = {x = 0.75, y = 0, yaw = 0},
            children = {
                { id = 111, type = Robot.TypeRobot.QUPA, pose = {x = 1.5, y = 0.5, yaw = 0} },
                { id = 112, type = Robot.TypeRobot.QUPA, pose = {x = 1.0245, y = 0.1545, yaw = 0} },
                { id = 113, type = Robot.TypeRobot.QUPA, pose = {x = 1.2061, y = -0.4045, yaw = 0} },
                { id = 114, type = Robot.TypeRobot.QUPA, pose = {x = 1.7939, y = -0.4045, yaw = 0} },
                { id = 115, type = Robot.TypeRobot.QUPA, pose = {x = 1.9755, y = 0.1545, yaw = 0} },
            }
        },
        {
            id = 12,
            type = Robot.TypeRobot.DRONE,
            pose = {x = -0.75, y = 0, yaw = 0},
            children = {
                { id = 121, type = Robot.TypeRobot.QUPA, pose = {x = -1.5, y = 0.5, yaw = 0} },
                { id = 122, type = Robot.TypeRobot.QUPA, pose = {x = -1.0245, y = 0.1545, yaw = 0} },
                { id = 123, type = Robot.TypeRobot.QUPA, pose = {x = -1.2061, y = -0.4045, yaw = 0} },
                { id = 124, type = Robot.TypeRobot.QUPA, pose = {x = -1.7939, y = -0.4045, yaw = 0} },
                { id = 125, type = Robot.TypeRobot.QUPA, pose = {x = -1.9755, y = 0.1545, yaw = 0} },
            }
        }
    }
}




--- Function that update the target according the obstacle or other
---@param Node The principal node 
function BrainRobot.updateTargetGraph()
    return Graph_functions.make_target_graph(BrainRobot.Init_graph_target)
end

return BrainRobot