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
    ---@module rech.game.Wordle
    local this = {}
    this.__index = this

    local __MACRO_ID = "rech.game.wordle"
    local __MACRO_DISPLAY_NAME = "Play Wordle"

    ---@type table<number,string>
    local __WORDLIST = require("rech.game.wordle-wordlist")
    local __WORDLIST_SEARCH = table.concat(__WORDLIST, "|")

    ---@class Wordle
    ---Init macro
    ---@param parentId string
    function this.init(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "f6f0", this.activate)
    end

    function this.activate()
        ---@type string
        local word = __WORDLIST[math.random(#__WORDLIST)]:lower()
        -- word = "unity"
        local history = ""
        local guesses = 0
        while true do
            local desc = DialogField.create("history").description().setLabel(history)
            local inputfield = DialogField.create("input")
            inputfield.setLabel("Input")
            inputfield.setTooltip("Input 5 letters")
            inputfield.fieldConstraint.custom(this.checkInput, "Not 5 letters")
            local request = DialogInput.withTitle(__MACRO_DISPLAY_NAME).requestInput({inputfield, desc})
            coroutine.yield()
            ---@type string
            local input = request.result["input"]:lower()
            if input == word then
                notify("You won! the answer is " .. word:upper())
                return
            end
            if this.isInWord(input) then
                guesses = guesses + 1
                local state = this.checkAnswer(input, word)
                local coloredText = this.colorText(state, input)
                history = guesses .. ": " .. input:upper() .. " -> " .. coloredText .. "\n" .. history
                if guesses == 6 then
                    notifyWarn("You didn't get it in 6 tries, the answer is " .. word:upper() .. "\nPrevious guesses:\n" .. history)
                    return
                end
            else
                notifyError(input:upper() .. " is not in the word set!")
            end
        end
    end

    ---@param s string
    function string.table(s)
        local t = {}
        s:gsub(".", function(c) table.insert(t, c) end)
        return t
    end

    ---@param state table
    ---@param input string
    function this.colorText(state, input)
        local out = ""
        local letters = input:upper():table()
        for i = 1, 5 do
            local s = state[i]
            if s == "X" then
                out = out .. string.format("<color=grey>%s</color>", letters[i])
            elseif s == "?" then
                out = out .. string.format("<color=yellow>%s</color>", letters[i])
            elseif s == "O" then
                out = out .. string.format("<color=green>%s</color>", letters[i])
            end
        end
        return out
    end

    function this.isInWord(input)
        local s = __WORDLIST_SEARCH:find(input)
        return s ~= nil
    end

    ---@param input string
    ---@param word string
    function this.checkAnswer(input, word)
        local inputLetters = input:table()
        local wordLetters = word:table()
        local state = {}

        for i = 1, 5 do
            state[i] = "X"
            if inputLetters[i] == wordLetters[i] then
                state[i] = "O"
                inputLetters[i] = nil
                wordLetters[i] = nil
            else
            end
        end
        for i = 1, 5 do
            if wordLetters[i] ~= nil then
                for j = 1, 5 do
                    if inputLetters[j] ~= nil and inputLetters[j] ~= nil then
                        if inputLetters[j] == wordLetters[i] then
                            inputLetters[j] = nil
                            wordLetters[i] = nil
                            state[j] = "?"
                        end
                    end
                end
            end
        end
        return state
    end

    ---@class Wordle
    ---@param value string
    function this.checkInput(value)
        return value:lower():find("%l%l%l%l%l") == 1 and value:len() == 5
    end

    return this
end
