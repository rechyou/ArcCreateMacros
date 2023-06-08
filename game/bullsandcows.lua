--[[
ISC License

Copyright 2023 recharge-sp

Permission to use, copy, modify, and/or distribute this software 
for any purpose with or without fee is hereby granted, provided that 
the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE 
FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES 
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN 
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR 
IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

do
    ---@type rech.dialogs.Dialog
    local Dialog = require("rech.dialogs.Dialog")
    ---@type rech.dialogs.Description
    local Description = require("rech.dialogs.fields.Description")
    ---@type rech.dialogs.TextField
    local TextField = require("rech.dialogs.fields.TextField")

    ---@module rech.game.BullsAndCows
    local this = {}
    this.__index = this

    local __MACRO_ID = "rech.game.bullsandcows"
    local __MACRO_DISPLAY_NAME = "Play 1A2B/Bulls and Cows"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "eb8d", this.activate)
    end

    function this.activate()
        local history = ""
        local rand = math.random(0, 10000)
        local digits = string.format("%04d", rand)
        local guesses = 0
        local desc = Description()
        local input = TextField():label("Input"):placeholder("1234"):tooltip("Input 4 digit numbers")
        while true do
            desc:label(history)
            local dialog = Dialog()
            dialog:add(input,desc)
            dialog:open()
            ---@type string
            local input = input:result()
            if input == "" then
                notify("Quit game")
                return
            end
            if input == digits then
                notify("You won!, the answer is " .. digits)
                return
            end
            guesses = guesses + 1
            history = guesses .. ": " .. input .. " -> " .. this.check1a2b(this.toCharTable(input), this.toCharTable(digits)) .. "\n" .. history
        end
    end

    ---@param value string
    function this.toCharTable(value)
        local t = {}
        value:gsub(".", function(c) table.insert(t, c) end)
        return t
    end

    ---@param input string
    ---@param answer string
    function this.check1a2b(input, answer)
        local a = 0
        local b = 0
        for i = 1, 4 do
            if input[i] == answer[i] then
                a = a + 1
                input[i] = nil
                answer[i] = nil
            end
        end
        for i = 1, 4 do
            for j = 1, 4 do
                if input[j] ~= nil and answer[i] ~= nil then
                    if input[j] == answer[i] then
                        b = b + 1
                        input[j] = nil
                    end
                end
            end
        end
        return string.format("%dA%dB", a, b)
    end

    ---@param value string
    function this.checkInput(value)
        return value:find("%d%d%d%d") == 1 and value:len() == 4
    end

    return this
end
