do
    ---@module rech.lib.Chores
    local this = {}
    this.__index = this

    ---@param timing integer
    ---@param xy XY
    ---@param timing integer
    ---@param color integer
    ---@param timingGroup integer
    ---@return LuaChartCommand
    function this.SaveSingleArcTap(timing, xy, color, timingGroup)
        local arc = Event.arc(timing, xy, timing+1, xy, true, color, "s", timingGroup, "none")
        local arctap = Event.arcTap(timing, arc)
        return arc.save() + arctap.save()
    end
    return this
end
