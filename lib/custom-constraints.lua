do
    ---@module rech.lib.CustomConstraints
    local this = {}
    this.__index = this

    ---@param arc LuaArc
    function this.ofArc(arc)
        ---@param arctap LuaArcTap
        return function(arctap)
            if not arctap.is("arctap") then return false end
            return arctap.arc == arc
        end
    end

    function this.ofDuration(duration)
        ---@param e LuaHold|LuaArc
        return function(e)
            if e.is("long") then
                return duration == e.endTiming - e.timing
            end
            return false
        end
    end

    return this
end
