do
    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.Dropdown
    local Dropdown = require("rech.dialogs.fields.Dropdown")
    ---@module rech.util.DrawLine
    local this = {}
    this.__index = this

    local __MACRO_ID = "rech.util.drawline"
    local __MACRO_DISPLAY_NAME = "Draw arc by clicking"
    local __MACRO_DIALOG_TITLE = "Draw arc configuration"

    ---@type rech.lib.Request
    local request = require("rech.lib.request")


    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "ebbb", this.activate)
    end

    function this.activate()
        local timing = request.Timing(true, "Select timing")
        local pos1 = request.VerticalPosition(timing, "Select starting position")
        if Context.currentTiming == timing then
            Context.currentTiming = timing-1
        end
        while true do
            local pos2 = request.VerticalPosition(timing, "Select next position or cancel")
            local event = Event.arc(timing, pos1, timing, pos2, Context.currentIsTraceMode, Context.currentArcColor,  "s", Context.currentTimingGroup, "none")
            event.save().commit()
            pos1 = pos2
        end
    end
    return this
end
