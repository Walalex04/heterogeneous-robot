local functions_common = {}
local cons = require("constants")


function functions_common.print_topology(currentUID, local_topolgy)
    
    local ids_child = ""
    for _,ids in ipairs(local_topolgy["direct_childs"]) do
        ids_child = ids_child .. ids .. ", "
    end
    local pa_id = local_topolgy["parentId"] or "none"
    local first_txt = "The robot with id: " .. currentUID ..
                    " has the parent id: " .. pa_id ..
                    " and its children are: " .. ids_child .. "\n"

    log(first_txt)
end


--[[
    This is a function that add an element in a list
    but first it check if the element is not in the list
    ]]
function functions_common.add_list(list, element, deleting)
    if(deleting == true) then
        list = {}
        table.insert(list, element)
        return
    end
    --first verify if the element is in the list
    for _, elem in ipairs(list) do
        if(elem == element) then return end
    end

    table.insert(list, element)
end

function functions_common.is_child(list, element)
    for id , elem in ipairs(list) do
        if(elem.UID == element) then return id end
    end
    return -1
end


--[[
    FUNCTINS FOR GRAPH
]]

function functions_common.make_node(value)
    return {
        value = value,
        children = {}
    }
end

function functions_common.add_child(parent, child)
    table.insert(parent.children, child)
end

function functions_common.traverse_graph(node, level)
    if not node then return end

    level = level or 0
    local indentation = string.rep("  ", level)
    
    local robot_id = node.value.id or "UNKNOWN"
    local robot_type = node.value.type or "UNKNOWN"
    local pose = node.value.pose or {x = 0, y = 0, yaw = 0}

    log(string.format("%s- [%s] Type: %s | Pose: (x=%.2f, y=%.2f, yaw=%.2f)", 
        indentation, 
        tostring(robot_id), 
        tostring(robot_type), 
        pose.x or 0, 
        pose.y or 0, 
        pose.yaw or 0
    ))

    if node.children then
        for _, child in ipairs(node.children) do
            functions_common.traverse_graph(child, level + 1)
        end
    end
end

function functions_common.get_sub_tree_by_id(rootNode, target_id)
    if not rootNode then return nil end

    -- 1. Búsqueda iterativa (DFS) para encontrar el nodo objetivo
    local foundNode = nil
    local stack = { rootNode }
    while #stack > 0 do
        local curr = table.remove(stack)
        
        if curr.value and curr.value.id == target_id then
            foundNode = curr
            break
        end

        if curr.children then
            for i = #curr.children, 1, -1 do
                table.insert(stack, curr.children[i])
            end
        end
    end

    if not foundNode then return nil end

    -- 2. Función auxiliar recursiva para duplicar el subárbol encontrado
    local function clone_tree(node)
        -- Copiamos los valores de la pose para evitar referencias compartidas
        local pose_copy = nil
        if node.value and node.value.pose then
            pose_copy = {
                x = node.value.pose.x,
                y = node.value.pose.y,
                z = node.value.pose.z,
                yaw = node.value.pose.yaw
            }
        end

        local newNode = functions_common.make_node({
            id = node.value.id,
            type = node.value.type,
            pose = pose_copy
        })

        if node.children then
            for _, child in ipairs(node.children) do
                local newChild = clone_tree(child)
                functions_common.add_child(newNode, newChild)
            end
        end

        return newNode
    end

    return clone_tree(foundNode)
end

function functions_common.make_target_graph(configData)
    local currentNode = functions_common.make_node({
        id = configData.id,
        type = configData.type,
        pose = configData.pose
    })

    
    if configData.children then
        for _, data_children in ipairs(configData.children) do
            local node_children = functions_common.make_target_graph(data_children)
            functions_common.add_child(currentNode, node_children)
        end
    end
    return currentNode
end


function functions_common.yawTOQuaternion(yaw)
    yaw = yaw or 0
    return {
        x = 0.0,
        y = 0.0,
        z = math.sin(yaw / 2),
        w = math.cos(yaw / 2)
    }
end

function functions_common.gen_tar_local_graph(node, card_max, ids_childs_allowed)
    local target_graph = {
        Av = {
            typei = {}
        },
        Ae = {
            disp = {},
            quat = {}
        },
        card_type = {0, 0, 0}, -- [1] DRONE, [2] BLIMP, [3] QUPA
        card_high = 0
    }


    local tipoAIndice = {
        [cons.TYPE_ROBOT.DRONE or 1] = 1,
        [cons.TYPE_ROBOT.BLIMP or 2] = 2,
        [cons.TYPE_ROBOT.QUPA  or 3] = 3
    }

    if not node or not node.children then
        return target_graph
    end

    for _, hijo in ipairs(node.children) do
        local tipoRobot = hijo.value.type or 1
        local indiceTipo = tipoAIndice[tipoRobot] or 1

        table.insert(ids_childs_allowed, hijo.value.id)
        table.insert(target_graph.Av.typei, tipoRobot)

   
        local pose = hijo.value.pose or {x = 0, y = 0, yaw = 0}
        table.insert(target_graph.Ae.disp, {
            x = pose.x or 0,
            y = pose.y or 0
        })
        table.insert(target_graph.Ae.quat, functions_common.yawTOQuaternion(pose.yaw or 0))
        target_graph.card_type[indiceTipo] = target_graph.card_type[indiceTipo] + 1

 
    end

    -- 4. Cardinalidad total del nivel inferior
    target_graph.card_high = card_max

    return target_graph
end



function functions_common.printLocalTarget(target_graph, node_id)
    node_id = node_id or "Node"
    log("==================================================")
    log(" TARGET LOCAL GRAPH: " .. string.upper(node_id))
    log("==================================================")
    
    if not target_graph or not target_graph.Av or #target_graph.Av.typei == 0 then
        log("  [INFO] Subgraph is empty (no immediate children).")
        log("==================================================\n")
        return
    end

    log(string.format(" Total children (card_high): %d", target_graph.card_high))
    log(string.format(" Cardinality by type [DRONE, BLIMP, QUPA]: [%d, %d, %d]", 
        target_graph.card_type[1] or 0, 
        target_graph.card_type[2] or 0, 
        target_graph.card_type[3] or 0
    ))
    log("--------------------------------------------------")

    local type_str = table.concat(target_graph.Av.typei, ", ")
    log(" Robot types (Av.typei): { " .. type_str .. " }")
    log("--------------------------------------------------")

    log(" Lower level edges (Ae):")
    for i = 1, #target_graph.Ae.disp do
        local d = target_graph.Ae.disp[i]
        local q = target_graph.Ae.quat[i]
        local robot_type = target_graph.Av.typei[i]
        
        log(string.format("  [%2d] Robot Type: %d", i, robot_type))
        log(string.format("       Disp (x, y)  : { x = %8.4f, y = %8.4f }", d.x, d.y))
        log(string.format("       Quat (x,y,z,w): { x = %.1f, y = %.1f, z = %8.4f, w = %8.4f }", 
            q.x, q.y, q.z, q.w))
    end
    log("==================================================\n")
end

function functions_common.a2_encode8(val)
    return val & 0xFF
end

function functions_common.a2_decode8(val)
    val = val & 0xFF
    if (val & 0x80) ~= 0 then
        return val - 256
    end
    return val
end



return functions_common

