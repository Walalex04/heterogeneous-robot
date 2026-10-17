local Helpers = {}

function Helpers.deepCopy(orig)
    if type(orig) ~= 'table' then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        copy[Helpers.deepCopy(k)] = Helpers.deepCopy(v)
    end
    return setmetatable(copy, getmetatable(orig))
end


function Helpers.process_axis(val)
    local int_val = math.floor((val or 0) * 1000)
    
    -- Convertir número negativo a complemento a dos de 16 bits
    if int_val < 0 then
        int_val = int_val + 65536
    end
    
    local msb = math.floor(int_val / 256) % 256
    local lsb = int_val % 256
    return msb, lsb
end

return Helpers