do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.dialogs.BaseField
    local BaseField = require("rech.dialogs.fields.BaseField")

    ---@param description string
    ---@class rech.dialogs.Description : rech.dialogs.BaseField
    local this = Class(BaseField)

    ---@param description string
    function this:init(description)
        BaseField.init(self, nil)
        self.field.description(description)
        return self
    end

    ---@return nil
    function this:result()
        return nil
    end

    return this
end
