do
    ---@module rech.lib.Pico
    local pico = {}
    pico.__index = pico
    local default_identifier = {
        ["table"] = "@",
        ["tablevalue"] = "=",
        ["string"] = "$",
        ["number"] = "#",
        ["boolean"] = "?",
        ["true"] = "+",
        ["false"] = "-",
        ["nil"] = "!",
        ["escape"] = "^",
        ["separator"] = "|"
    }
    local identifier = {}
    local identifier_rev = {} 

    function pico.set_identifier(i)
        identifier = i
        identifier_rev = {}
        for k, v in pairs(identifier) do
            identifier_rev[v] = k
        end
    end
    pico.set_identifier(default_identifier)
    
    ---@class Pico
    function pico.serialize(value, file)
        local sep, esc = identifier["separator"], identifier["escape"]
        local vtype = type(value)
        if vtype == "table" then
            file:write(identifier[vtype])
            for k,v in pairs(value) do
                file:write(identifier["tablevalue"], sep)
                pico.serialize(k, file)
                pico.serialize(v, file)
            end
            file:write(identifier[vtype], sep)
        elseif vtype == "boolean" then
            if value then
                file:write(identifier[vtype], identifier["true"], sep)
            else
                file:write(identifier[vtype], identifier["false"], sep)
            end
        elseif vtype == "number" then
            file:write(identifier[vtype], pico.strescape(tostring(value), sep, esc), sep)
        elseif vtype == "string" then
            file:write(identifier[vtype], pico.strescape(value, sep, esc), sep)
        elseif vtype == "nil" then
            file:write(identifier[vtype], sep)
        end
    end

    function pico.strescape(s, sep, esc)
        return s:gsub(sep, esc .. sep)
    end

    function pico.readstring(file, sep, esc)
        local s = ""
        while true do
            local c = file:read(1)
            if c == nil then return s end
            if c == sep then return s end
            if c == esc then
                local orig = file:read(1)
                if orig ~= nil then s = s .. orig end
            else
            s = s .. c
            end
        end
    end

    function pico.deserialize(file)
        local sep, esc = identifier["separator"], identifier["escape"]
        while true do
            local value = file:read(1)
            local vtype = identifier_rev[value]
            if vtype == "table" then
            local t = {}
            while true do
                value = pico.readstring(file, sep, esc)
                if value == identifier["table"] then
                return t
                end -- end of table
                if value == identifier["tablevalue"] then
                local k, v = pico.deserialize(file), pico.deserialize(file)
                t[k] = v
                else
                error("Read error of table at " .. file:seek("cur") .. ", found " .. value)
                end
            end
            return t
            elseif vtype == "tablevalue" then
                return pico.deserialize(file), pico.deserialize(file)
            elseif vtype == "boolean" then
                local bool = pico.readstring(file, sep, esc)
                if identifier["true"] == bool then return true end
                if identifier["false"] == bool then return false end
                error("Invalid boolean on:" .. value)
            elseif vtype == "number" then
                local s = pico.readstring(file, sep, esc)
                local n = tonumber(s)
                if n ~= nil then return n end
                error("Invalid number on:" .. value)
            elseif vtype == "string" then
                return pico.readstring(file, sep, esc)
            elseif vtype == "nil" then
                return nil
            end
            error("Invalid type on:" .. value)
        end
    end
    return pico
end
