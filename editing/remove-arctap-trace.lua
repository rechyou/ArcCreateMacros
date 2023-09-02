do
    ---@module rech.editing.RemoveArcTapTrace
    local this = {}
    this.__index = this

    local __MACRO_ID = "rech.editing.removearctaptrace"
    local __MACRO_DISPLAY_NAME = "Remove ArcTap trace..."

    ---@type rech.jaycurry.JayCurry
    local JayCurry = require("rech.jaycurry.JayCurry")

    ---@type rech.lib.CustomConstraints
    local CustomConstraints = require("rech.lib.custom-constraints")

    ---@type rech.lib.Chores
    local Chores = require("rech.lib.chores")

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e3bc", this.activate)
    end

    function this.activate()
        local arcEvents = JayCurry.query("arc:sel")
        local arctapEvents = JayCurry.query("arc:sel:arctap")
        local command = Command.create(string.format("%s (%s)", __MACRO_DISPLAY_NAME, __MACRO_ID))
        for _,arctap in ipairs(arctapEvents.events.arctap) do
            local trace = arctap.arc
            local t = arctap.timing
            command.add(arctap.delete())
            local arc, arctap = Chores.SaveSingleArcTap(t, trace.positionAt(t, true), trace.color, trace.timingGroup)
            command.add(arc)
            command.add(arctap)
        end
        for _,arc in ipairs(arcEvents.events.arc) do
            command.add(arc.delete())
        end
        command.commit()
    end

    return this
end
