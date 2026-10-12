

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

    robot.wheels.set_velocity(0.0,0.0)
    
end



function step()
    
end


function reset()

end


function destroy()
 
end