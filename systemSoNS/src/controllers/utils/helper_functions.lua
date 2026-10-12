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
    local int_val = math.floor((val or 0) * 100)
    
    -- Convertir número negativo a complemento a dos de 16 bits
    if int_val < 0 then
        int_val = int_val + 65536
    end
    
    local msb = math.floor(int_val / 256) % 256
    local lsb = int_val % 256
    return msb, lsb
end


function Helpers.combine_bytes(msb, lsb)
    -- Unir MSB y LSB en un valor de 16 bits sin signo
    local val = (msb * 256) + lsb
    -- Convertir a complemento a 2 (rango con signo de 16 bits: -32768 a 32767)
    if val >= 32768 then
        val = val - 65536
    end
    return val/100.0
end

function Helpers.exist_id(id_buscado, array)
    for i = 1, #array do
        if array[i].id == id_buscado then
            return true -- Encontrado
        end
    end
    return false -- No se encontró en todo el array
end

return Helpers