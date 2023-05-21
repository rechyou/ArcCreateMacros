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
        addMacroWithIcon(parentId, __MACRO_ID__, "Query", "e1b7", this.queryUI)
        addMacroWithIcon(parentId, __MACRO_ID__ .. ".help", "Syntax Help", "e887", this.helpUI)
        addMacroWithIcon(parentId, __MACRO_ID__ .. ".apihelp", "API Docs", "e873", this.apiHelpUI)
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
        local dialog = Dialog(__MACRO_DIALOG_TITLE .. " - Operation")

    end

    function this.helpUI()
        if Dialog == nil then notifyWarn("rech.dialogs.Dialog failed to load or is not installed!") return end
        local dialog = Dialog(__MACRO_DIALOG_TITLE .. " - Syntax Help")
        local help = Description(require("rech.jaycurry.help"))
        dialog:add(help)
        dialog:open()
    end

    function this.apiHelpUI()
        if Dialog == nil then notifyWarn("rech.dialogs.Dialog failed to load or is not installed!") return end
        local dialog = Dialog(__MACRO_DIALOG_TITLE .. " - API Docs")
        local apihelp = Description(require("rech.jaycurry.apihelp"))
        dialog:add(apihelp)
        dialog:open()
    end

    return this
end
