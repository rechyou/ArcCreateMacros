do
    ---@module rech.lib.Iterators
    local this = {}

    ---@param from number
    ---@param to number
    ---@param step number
    ---@param diff number
    function this.range(from, to, step, diff)
        if diff == nil then diff = 1 end
        local f = from
        local count = 0
        return function()
            f = from + step * count
            if f >= to - diff then return nil end
            local t = f + step
            count = count + 1
            if t >= to - diff then
                t = to
            end
            return f, t
        end
    end

    return this
end
