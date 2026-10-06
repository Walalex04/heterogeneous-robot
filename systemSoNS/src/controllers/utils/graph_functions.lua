local graph_functions = {}


--- Function that allow make a node for graph strcture
---@param node_value Node Node content
---@return table Node Structure
function graph_functions.make_node(node_value)
    return {
        value = node_value,
        children = {}
    }
end

--- Function that allow store the node children
---@param parent Node Parent node
---@param child Node Node child
function graph_functions.add_child(parent, child)
    table.insert(parent.children, child)
end


--- Function that transform a one table to graph Structure
---@param configData Table Structure for graph
---@return Node The brain node
function graph_functions.make_target_graph(configData)
    local currentNode = graph_functions.make_node({
        id = configData.id,
        type = configData.type,
        pose = configData.pose
    })

    
    if configData.children then
        for _, data_children in ipairs(configData.children) do
            local node_children = graph_functions.make_target_graph(data_children)
            graph_functions.add_child(currentNode, node_children)
        end
    end
    return currentNode
end



return graph_functions