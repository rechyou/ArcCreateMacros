do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.lib.TryImport
    local import = require("rech.lib.tryimport")
    import = import.import
    ---@type rech.dialogs.Dialog
    local Dialog = import("rech.dialogs.Dialog")
    ---@type rech.dialogs.Description
    local Description = import("rech.dialogs.fields.Description")
    ---@type rech.dialogs.TextField
    local TextField = import("rech.dialogs.fields.TextField")

    ---@module rech.jaycurry.init
    local this = Class()

    local __MACRO_ID__ = "rech.q"
    local __MACRO_DIALOG_TITLE = "JayCurry UI"

    ---@type rech.jaycurry.JayCurry
    local JayCurry = require("rech.jaycurry.JayCurry")
    -- expose query as global function
    q = JayCurry.query

    -- history
    local lastQuery = ""

    function this.initMacro(parentId)

        -- add macro
        addMacroWithIcon(parentId, __MACRO_ID__, "JayCurry", "e55c", this.queryUI)
    end

    function this.queryUI()
        if Dialog == nil then notifyWarn("rech.dialogs.Dialog failed to load or is not installed!") return end
        local dialog = Dialog(__MACRO_DIALOG_TITLE)
        local query = TextField():label("Query")
        query:value(lastQuery)
        dialog:add(query,
            Description("Enter query expression")
        )
        dialog:open()
        lastQuery = query:result()
        local ret = q(query:result())
        ret:select()
    end

    local operations = {}
    operations["Remove selection"] = JayCurry.remove
    operations["Offset arcs"] = JayCurry.offset
    function this.operationUI()
        if Dialog == nil then notifyWarn("rech.dialogs.Dialog failed to load or is not installed!") return end
        local dialog = Dialog(__MACRO_DIALOG_TITLE + " - Operation")

    end

    return this
end
