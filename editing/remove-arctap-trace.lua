do
    ---@module rech.editing.RemoveArcTapTrace
    local this = {}
    this.__index = this

    local __MACRO_ID = "rech.editing.removearctaptrace"
    local __MACRO_DISPLAY_NAME = "Remove ArcTap trace"

    ---@type rech.lib.Request
    local request = require("rech.lib.request")

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
        local traces = request.CurrentSelection(EventSelectionConstraint.trace()).arc
        local command = Command.create(__MACRO_DISPLAY_NAME)
        for _, trace in ipairs(traces) do
            local arctaps = request.Query(
                EventSelectionConstraint.create()
                .arcTap()
                .fromTiming(trace.timing)
                .toTiming(trace.endTiming)
                .custom(CustomConstraints.ofArc(trace), "")
            ).arctap

            command.add(trace.delete())
            for i,arctap in ipairs(arctaps) do
                local t = arctap.timing
                local c = Chores.SaveSingleArcTap(t, trace.positionAt(t, true), trace.color, trace.timingGroup)
                command.add(c)
            end
        end
        command.commit()
    end

    ---@param arc LuaArc
    function this.ofArc(arc)
        ---@param arctap LuaArcTap
        return function(arctap)
            return arctap.arc.instance == arc.instance
        end
    end

    return this
end
