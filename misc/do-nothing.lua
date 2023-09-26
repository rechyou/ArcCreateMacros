do
    ---@type rech.Class
    local Class = require("rech.Class")

    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.TextField
    local TextField = require("rech.dialogs.fields.TextField")

    ---@class rech.misc.DoNothing
    local this = Class()

    local __MACRO_ID = "rech.editing.DoNothing"
    local __MACRO_DISPLAY_NAME = "Do nothing"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "ea5c", this.activate)
    end


    function this.activate()
        local dialog = Dialog("How many useless commands you want to pump in")
        local count = TextField():is_number("Please enter a number."):label("Count")
        dialog:add(count)
        dialog:open()
        for i=1, tonumber(count:result()) do
            local nothing = Command.create("Do nothing")
            nothing.commit()
        end
    end
    return this
end
