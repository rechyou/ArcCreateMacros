do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    
    ---@class rech.util.SquareWave
    local this = Class()

    local __MACRO_ID = "rech.util.SquareWave"
    local __MACRO_DISPLAY_NAME = "Square wave"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e14e", this.activate)
    end

    function this.activate()
        local result = request.Event(EventSelectionConstraint.arc(), "Select first arc (1)")
        local arc1 = result.arc[1]
        local result = request.Event(EventSelectionConstraint.arc(), "Select second arc (2)")
        local arc2 = result.arc[1]
        if arc1.timing ~= arc2.timing or arc1.endTiming ~= arc2.endTiming then
            notifyError("Arc timing or end timing does not match!")
            return
        end
        local commands = Command.create("Square wave arc")
        commands.add(arc1.delete())
        commands.add(arc2.delete())
        local step =  Context.beatLengthAt(arc1.timing, arc1.timingGroup) / Context.beatlineDensity / 2
        local flag = true
        for t1 = arc1.timing, arc1.endTiming, step do
            local t2 = t1 + step
            if t2 > arc1.endTiming then t2 = arc1.endTiming end
            if flag then
                commands = commands + Event.arc(t1, arc1.positionAt(t1), t1, arc2.positionAt(t1), arc1.isTrace, arc1.color, arc1.type, arc1.timingGroup, arc1.sfx).save()
                commands = commands + Event.arc(t1, arc2.positionAt(t1), t2, arc2.positionAt(t2), arc1.isTrace, arc1.color, arc1.type, arc1.timingGroup, arc1.sfx).save()
            else
                commands = commands + Event.arc(t1, arc2.positionAt(t1), t1, arc1.positionAt(t1), arc1.isTrace, arc1.color, arc1.type, arc1.timingGroup, arc1.sfx).save()
                commands = commands + Event.arc(t1, arc1.positionAt(t1), t2, arc1.positionAt(t2), arc1.isTrace, arc1.color, arc1.type, arc1.timingGroup, arc1.sfx).save()
            end
            flag = not flag
        end

        commands.commit()
    end

    return this
end
