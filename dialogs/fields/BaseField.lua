do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@class rech.dialogs.BaseField
    local this = Class()
    this.__index = this

    ---@class rech.dialogs.BaseField
    ---@field private field DialogField
    ---@field private parent MacroRequest
    ---@field public key string
    local this__inst = {}

    ---@param key string
    function this:init(key)
        if key == nil then
            local randstr = require("rech.lib.randomstring")
            key = randstr()
        end
        self.key = key
        self.field = DialogField.create(key)
        self.parent = nil
        return self
    end

    ---@param value string
    ---@return rech.dialogs.BaseField
    function this:value(value)
        if value == nil then return self.field.defaultValue end
        self.field.defaultTo(value)
        return self
    end

    ---@param value string
    ---@return rech.dialogs.BaseField
    function this:placeholder(value)
        if value == nil then return self.field.hint end
        self.field.setHint(value)
        return self
    end

    ---@param value string
    ---@return rech.dialogs.BaseField
    function this:label(value)
        if value == nil then return self.field.label end
        self.field.setLabel(value)
        return self
    end

    ---@param value string
    ---@return rech.dialogs.BaseField
    function this:tooltip(value)
        if value == nil then return self.field.tooltip end
        self.field.setTooltip(value)
        return self
    end

    ---@return string
    function this:result()
        return self.parent.result[self.field.key]
    end

    ---@param request MacroRequest
    function this:setParent(request)
        self.parent = request
    end

    function this:getField()
        return self.field
    end

    return this
end
