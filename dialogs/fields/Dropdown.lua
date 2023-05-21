do
    ---@type rech.Class
    local Class = require "rech.Class"
    ---@type rech.dialogs.BaseField
    local BaseField = require "rech.dialogs.fields.BaseField"

    ---@class rech.dialogs.Dropdown : rech.dialogs.BaseField
    local this = Class(BaseField)

    ---@param key string
    function this:init(key, ...)
        BaseField.init(self, key)
        self.options = table.pack(...)
        self.field.dropdownMenu(self.options)
        return self
    end

    ---@vararg string
    function this:set(...)
        self.options = table.pack(...)
        self.field.dropdownMenu(self.options)
        return self
    end

    ---@vararg string
    function this.append(...)
        self.options = table.pack(...)
        self.field.dropdownMenu(self.options)
        return self
    end

    return this
end
