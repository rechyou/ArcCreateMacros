do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    ---@type rech.jaycurry.JayCurry
    local JayCurry = require("rech.jaycurry.JayCurry")
    
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
        local arcs = JayCurry.query("arc:sel")
        if #arcs.events.arc == 0 then
            notifyWarn("Select at least one arc or traces!")
            return
        end
        local cutTiming = request.Timing(true, "Select timing")
        local commands = Command.create(string.format("%s (%s)", __MACRO_DISPLAY_NAME, __MACRO_ID))
        for _,arc in ipairs(arcs.events.arc) do
            commands.add(arc.delete())
            local cutpos = arc.positionAt(cutTiming, false)

            local t1, t2 = arc.timing, cutTiming
            local arc1 = Event.arc(t1, arc.startXY, t2, cutpos, arc.isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx)
            commands.add(arc1.save())
            t1, t2 = cutTiming, arc.endTiming
            local arc2 = Event.arc(t1, cutpos, t2, arc.endXY, arc.isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx)
            commands.add(arc2.save())

            Event.setSelection({arc})
            local arctaps = JayCurry.query("arc:sel:arctap")
            for _,arctap in ipairs(arctaps.events.arctap) do
                commands.add(arctap.delete())
                arctap = arctap.copy()
                if arctap.timing <= cutTiming then
                    arctap.arc = arc1
                else
                    arctap.arc = arc2
                end
                commands.add(arctap.save())
            end
        end
        commands.commit()
    end

    return this
end
