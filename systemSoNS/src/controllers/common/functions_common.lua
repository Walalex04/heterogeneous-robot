local functions_common = {}



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

return functions_common 