do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    
    ---@class rech.editing.CutArcOnTiming
    local this = Class()

    local __MACRO_ID = "rech.editing.CutArcOnTiming"
    local __MACRO_DISPLAY_NAME = "Cut arc on timing"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e14e", this.activate)
    end

    function this.activate()
        local result = request.Event(EventSelectionConstraint.arc(), "Select arc to cut")
        local arc = result.arc[1]
        local cutTiming = request.Timing(true, "Select timing")
        local cutpos = arc.positionAt(cutTiming, false)
        local commands = Command.create("Cut arc on timing")
        commands.add(arc.delete())
        local t1, t2 = arc.timing, cutTiming
        commands.add(Event.arc(t1, arc.startXY, t2, cutpos, arc.isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx).save())
        t1, t2 = cutTiming, arc.endTiming
        commands.add(Event.arc(t1, cutpos, t2, arc.endXY, arc.isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx).save())
        commands.commit()
    end

    return this
end
