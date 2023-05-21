do
    local __FOLDER_ID = "rech"
    local __FOLDER_ID_GAME = "rech.game"
    local __FOLDER_ID_UTIL = "rech.util"
    local __FOLDER_ID_JQ = "rech.jaycurry"
    addFolderWithIcon(nil, __FOLDER_ID, "ea0b","rech's macro")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_GAME, "ea28","Games")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_UTIL, "e3c9","Misc")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_JQ, "e55c","JayCurry")

    ---@type BullAndCows
    local bullsandcows = require("rech.game.bullsandcows")
    bullsandcows.init(__FOLDER_ID_GAME)

    ---@type Wordle
    local wordle = require("rech.game.wordle")
    wordle.init(__FOLDER_ID_GAME)

    ---@type DrawLine
    local drawline = require("rech.util.drawline")
    drawline.init(__FOLDER_ID_UTIL)

    ---@type RemoveArcTapTrace
    local ratt = require("rech.util.remove-arctap-trace")
    ratt.init(__FOLDER_ID_UTIL)

    ---@type rech.jaycurry.JayCurry
    local jaycurry = require("rech.jaycurry.init")
    jaycurry.initMacro(__FOLDER_ID_JQ)
end
