do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.TextField
    local TextField = require("rech.dialogs.fields.TextField")
    ---@type rech.dialogs.CheckboxField
    local CheckboxField = require("rech.dialogs.fields.CheckboxField")
    ---@type rech.lib.Iterators
    local iterators = require("rech.lib.iterators")
    
    ---@class rech.editing.MacaroniArc
    local this = Class()

    local __MACRO_ID = "rech.editing.MacaroniArc"
    local __MACRO_DISPLAY_NAME = "Macaroni arc"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "ec20", this.activate)
    end

    function this.activate()
        local result = request.CurrentSelection(EventSelectionConstraint.arc())
        if #result.arc == 0 then
            notifyWarn("No arc has been selected.")
            return
        end
        local dialog = Dialog(__MACRO_DISPLAY_NAME)
        local percentField = TextField()
        percentField:is_number("Input a number")
        :placeholder(0.5)
        :label("Arc percent")
        :value(0.5)
        local addAlternateCheckbox = CheckboxField()
        addAlternateCheckbox:label("Add void or \nsolid segment")
        dialog:add(percentField, addAlternateCheckbox)
        dialog:open()
        local percent = tonumber(percentField:result())
        local addAlternate = addAlternateCheckbox:result()
        if percent >= 1 then
            percent = 1
            addAlternate = false
        end
        local commands = Command.create(string.format("%s (%s)", __MACRO_DISPLAY_NAME, __MACRO_ID))
        for _,arc in ipairs(result.arc) do
            commands.add(arc.delete())
            local fromTiming = arc.timing
            local toTiming = arc.endTiming
            local timingGroup = arc.timingGroup
            local step =  Context.beatLengthAt(fromTiming, timingGroup) / Context.beatlineDensity 
            local isTrace = arc.isTrace
            for t1, t2 in iterators.range(fromTiming, toTiming, step) do
                local t = t1 + (t2 - t1) * percent
                t1 = math.floor(t1)
                t = math.floor(t)
                t2 = math.floor(t2)
                if t1 ~= t then
                    commands = commands + Event.arc(t1, arc.positionAt(t1), t, arc.positionAt(t), isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx).save()
                end
                if addAlternate and t ~= t2 then
                    commands = commands + Event.arc(t, arc.positionAt(t), t2, arc.positionAt(t2), not isTrace, arc.color, arc.type, arc.timingGroup, arc.sfx).save()
                end
            end
        end
        commands.commit()
    end

    return this
end
