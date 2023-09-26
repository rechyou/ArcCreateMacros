do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.Request
    local request = require("rech.lib.request")
    
    ---@class rech.editing.ArcReverse
    local this = Class()

    local __MACRO_ID = "rech.editing.ArcReverse"
    local __MACRO_DISPLAY_NAME = "Reverse arc position"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e8d4", this.activate)
    end

    function this.activate()
        local result = request.CurrentSelection(EventSelectionConstraint.arc())
        local arcs = result.arc
        if #arcs == 0 then
            notifyWarn("No arc selected.")
            return
        end
        local commands = Command.create(string.format("%s (%s)", __MACRO_DISPLAY_NAME, __MACRO_ID))
        for _,arc in ipairs(arcs) do
            local xy1, xy2 = arc.startXY, arc.endXY
            arc.startXY = xy2
            arc.endXY = xy1
            commands.add(arc.save())
        end

        commands.commit()
    end

    return this
end
