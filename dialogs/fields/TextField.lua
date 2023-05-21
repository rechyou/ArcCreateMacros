do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.dialogs.BaseField
    local BaseField = require("rech.dialogs.fields.BaseField")

    ---@class rech.dialogs.TextField : rech.dialogs.BaseField
    local this = Class(BaseField)

    ---@param key string
    function this:init(key)
        BaseField.init(self, key)
        return self
    end

    ---Match text with lua pattern language
    ---@param value string
    ---@return FieldConstraint
    function this:pattern(value, message)
        if value == nil then return self.field.label end
        self.field.fieldConstraint.custom(function(input)
            return input:match(value) ~= nil
        end, message)
        return self
    end

    function this:constraint()
    end

    return this
end
