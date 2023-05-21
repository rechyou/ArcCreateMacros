do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@class rech.dialogs.Dialog
    local Dialog = Class()

    ---@class rech.dialogs.Dialog
    ---@field private dialog DialogInput
    ---@field private dialogFields table<number, DialogField>
    ---@field private fields table<number, rech.dialogs.BaseField>
    Dialog__inst = {}

    ---@param constraint string
    function Dialog:init(title)
        self.title = title
        self.fields = {}
        self.dialogFields = {}
        return self
    end

    ---@param field rech.dialogs.BaseField
    function Dialog:add(...)
        self.fields = table.pack(...)
        for _,field in ipairs({...}) do
            self.dialogFields[#self.dialogFields+1] = field:getField()
        end
        return self
    end

    ---Open dialog
    function Dialog:open()
        local dialog = DialogInput.withTitle(self.title)
        local req = dialog.requestInput(self.dialogFields)
        for _,v in ipairs(self.fields) do
            v:setParent(req)
        end
        coroutine.yield()
    end
    return Dialog
end
