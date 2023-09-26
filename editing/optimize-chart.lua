do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.CheckboxField
    local CheckboxField = require("rech.dialogs.fields.CheckboxField")
    
    ---@class rech.editing.OptimizeChart
    local this = Class()

    ---@type rech.jaycurry.JayCurry
    local jq = require("rech.jaycurry.JayCurry")

    local __MACRO_ID = "rech.editing.OptimizeChart"
    local __MACRO_DISPLAY_NAME = "Optimize chart"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e663", this.activate)
    end

    ---@param batch LuaChartCommand
    local function optimize(batch, optimizeSFX)
        ---@type rech.jaycurry.JayCurry
        local q = jq.query("arc")
        for _, v in ipairs(q.events.arc) do
            if v.sfx == "none" and optimizeSFX then
                v.sfx = ""
            end
            if v.startX ~= v.endX and v.startY == v.endY then
                v.type = v.type:sub(0, 2)
            end
            if v.startXY == v.endXY then
                v.type = "s"
            end
            if (v.type == "si" or v.type == "so")
            and (v.startX == v.endX and v.startY ~= v.endY) then
                v.type = "s"
            end
            batch.add(v.save())
        end
    end

    function this.activate()
        local dialog = Dialog(__MACRO_DISPLAY_NAME)
        local optimizeSFXCheckbox = CheckboxField()
        optimizeSFXCheckbox:label("Optimize\nSFX field")
        dialog:add(optimizeSFXCheckbox)
        dialog:open()
        local batch = Command.create(string.format("%s (%s)", __MACRO_DISPLAY_NAME, __MACRO_ID))
        optimize(batch, optimizeSFXCheckbox:result())
        batch.commit()
    end

    return this
end
