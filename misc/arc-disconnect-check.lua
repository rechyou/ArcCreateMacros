do
    ---@type rech.Class
    local Class = require("rech.Class")

    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.TextField
    local TextField = require("rech.dialogs.fields.TextField")
    ---@type rech.jaycurry.JayCurry
    local JC = require("rech.jaycurry.JayCurry")

    ---@class rech.misc.ArcDisconnectCheck
    local this = Class()

    local __MACRO_ID = "rech.misc.ArcDisconnectCheck"
    local __MACRO_DISPLAY_NAME = "Check disconnected arc"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "eaf5", this.activate)
    end


    function this.activate()
        local dialog = Dialog(__MACRO_DISPLAY_NAME)
        local threshold = TextField():is_number("Please enter a number."):label("Threshold(ms)"):value("1")
        dialog:add(threshold)
        dialog:open()
        local query = JC.query("arc")
        local found = false
        for a,arc1 in pairs(query.events.arc) do
            local nearArcs = Event.query(EventSelectionConstraint.arc().fromTiming(arc1.endTiming).toTiming(arc1.endTiming+threshold:result()))
            for b,arc2 in pairs(nearArcs.arc) do
                if this.check(a, b, arc1, arc2, tonumber(threshold:result())) then
                    found = true
                    break
                end
            end
        end
        if found then
            notifyWarn("Disconnected arc found, navigating to the arc timing")
        else
            notify("Good! there are no disconnected arc left!")
        end
        
    end

    ---@param a number
    ---@param b number
    ---@param arc1 LuaArc
    ---@param arc2 LuaArc
    ---@param threshold number
    function this.check(a, b, arc1, arc2, threshold)
        if a == b then return false end
        if arc1.isVoid ~= arc2.isVoid then return false end
        if arc1.endX ~= arc2.startX or arc1.endY ~= arc2.startY then
            return false
        end
        local dt = arc2.timing - arc1.endTiming
        if dt == 0 then return false end
        if dt <= threshold then 
            Context.currentTiming = arc1.endTiming-30
            return true
        end

    end

    return this
end
