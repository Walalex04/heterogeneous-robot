local functions_common = {}



function functions_common.print_topology(currentUID, local_topolgy)
    
    local ids_child = ""
    for _,ids in ipairs(local_topolgy["direct_childs"]) do
        ids_child = ids_child .. ids .. ", "
    end
    local pa_id = local_topolgy["parent_id"] or "none"
    local first_txt = "The robot with id: " .. currentUID ..
                    " has the parent id: " .. pa_id ..
                    " and its children are: " .. ids_child .. "\n"

    log(first_txt)
end


return functions_common 