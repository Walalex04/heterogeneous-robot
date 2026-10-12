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



BrainRobot.Init_graph_target_ex1 = {
    id = 0,
    pose = {x = 0, y = 0, yaw = 0},
    children = {
                { id = 11, type = Robot.TypeRobot.QUPA, pose = {x = 1.0, y = 0.0, yaw = 0} },
                { id = 12, type = Robot.TypeRobot.QUPA, pose = {x = 0.5, y = 0.866, yaw = 0} },
                { id = 13, type = Robot.TypeRobot.QUPA, pose = {x = -0.5, y = 0.866, yaw = 0} },
                { id = 14, type = Robot.TypeRobot.QUPA, pose = {x = -1.0, y = 0.0, yaw = 0} },
                { id = 15, type = Robot.TypeRobot.QUPA, pose = {x = -0.5, y = -0.866, yaw = 0} },
    }
}


BrainRobot.Init_graph_target_ex2 = {
    id = 0,
    pose = {x = 0, y = 0, yaw = 0},
    children = {
        {
            id = 11,
            type = Robot.TypeRobot.DRONE,
            pose = {x = 1.0, y = 0.0, yaw = 0},
            children = {}
        },
        {
            id = 12,
            type = Robot.TypeRobot.DRONE,
            pose = {x = 0.5, y = 0.866, yaw = 0},
            children = {}
        },
        {
            id = 13,
            type = Robot.TypeRobot.DRONE,
            pose = {x = -0.5, y = 0.866, yaw = 0},
            children = {}
        },
        {
            id = 14,
            type = Robot.TypeRobot.DRONE,
            pose = {x = -1.0, y = 0.0, yaw = 0},
            children = {}
        },
        {
            id = 15,
            type = Robot.TypeRobot.DRONE,
            pose = {x = -0.5, y = -0.866, yaw = 0},
            children = {}
        }
    }
}

--- Function that update the target according the obstacle or other
---@param Node The principal node 
function BrainRobot.updateTargetGraph()
    return Graph_functions.make_target_graph(BrainRobot.Init_graph_target)
end


function BrainRobot.updateTargetGraph_withpose(new_poses)
    for i, child in ipairs(BrainRobot.Init_graph_target_ex1.children) do
        if new_poses[i] then
            child.pose.x = new_poses[i].x
            child.pose.y = new_poses[i].y
            child.pose.yaw = new_poses[i].yaw or child.pose.yaw
        end
    end
    return Graph_functions.make_target_graph(BrainRobot.Init_graph_target_ex2)
end
return BrainRobot