do
    ---@module rech.lib.TryImport
    local this = {}

    ---@param modname string
    ---@return any
    function this.import(modname)
        local status, mod = pcall(require, modname)
        if status then return mod end
        notifyWarn("Module didn't load:" .. mod)
    end

    return this
end
