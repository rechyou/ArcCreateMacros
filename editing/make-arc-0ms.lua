do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    
    ---@class rech.editing.MakeArc0ms
    local this = Class()

    local __MACRO_ID = "rech.editing.MakeArc0ms"
    local __MACRO_DISPLAY_NAME = "Make arc 0ms"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "eba7", this.activate)
    end

    function this.activate()
        local result = request.CurrentSelection(EventSelectionConstraint.arc())
        local arcs = result.arc
        local commands = Command.create(__MACRO_DISPLAY_NAME)
        for _,arc in ipairs(arcs) do
            arc.endTiming = arc.timing
            commands.add(arc.save())
        end

        commands.commit()
    end

    return this
end
