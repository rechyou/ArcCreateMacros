do
    local function randomstring()
        return string.format("%x",math.random(2^15,2^16))
    end
    return randomstring
end
