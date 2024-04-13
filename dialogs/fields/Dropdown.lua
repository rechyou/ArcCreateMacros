do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.dialogs.BaseField
    local BaseField = require("rech.dialogs.fields.BaseField")

    ---@class rech.dialogs.Dropdown : rech.dialogs.BaseField
    ---@field options table
    local this = Class(BaseField)

    ---@param key string
    function this:init(key, ...)
        BaseField.init(self, key)
        self.options = table.pack(...)
        if #self.options == 1 then
            if type(self.options[1]) == "table" then
                self.options = self.options[1]
            end
        end
        self.field.dropdownMenu(table.unpack(self.options))
        return self
    end

    ---@vararg string
    function this:set(...)
        self.options = table.pack(...)
        if #self.options == 1 then
            if type(self.options[1]) == "table" then
                self.options = self.options[1]
                --notify("Setting table as is " .. table.concat(self.options, ","))
            end
        end
        self.field.dropdownMenu(table.unpack(self.options))
        return self
    end

    ---@vararg string
    function this:append(option)
        table.insert(self.options, option)
        self.field.dropdownMenu(table.unpack(self.options))
        return self
    end

    ---@return number
    function this:result_num()
        local result = self:result()
        for i,v in ipairs(self.options) do
            if v == result then
                return i
            end
        end
        return nil
    end

    return this
end
