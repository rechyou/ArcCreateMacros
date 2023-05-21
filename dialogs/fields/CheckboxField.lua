do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.dialogs.BaseField
    local BaseField = require("rech.dialogs.fields.BaseField")

    ---@class rech.dialogs.CheckboxField : rech.dialogs.BaseField
    local this = Class(BaseField)

    ---@param key string
    function this:init(key)
        BaseField.init(self, key)
        self.field.checkbox()
        return self
    end

    ---@return boolean
    function this:result()
        return self.parent.result[self.field.key]
    end
    return this
end
