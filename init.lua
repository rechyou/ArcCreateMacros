do
    local __FOLDER_ID = "rech"
    local __FOLDER_ID_GAME = "rech.game"
    local __FOLDER_ID_UTIL = "rech.util"
    local __FOLDER_ID_JQ = "rech.jaycurry"
    addFolderWithIcon(nil, __FOLDER_ID, "ea0b","rech's macro")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_GAME, "ea28","Games")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_UTIL, "e3c9","Misc")
    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_JQ, "e55c","JayCurry")

    ---@type rech.game.BullsAndCows
    local bullsandcows = require("rech.game.bullsandcows")
    bullsandcows.initMacro(__FOLDER_ID_GAME)

    ---@type rech.game.Wordle
    local wordle = require("rech.game.wordle")
    wordle.initMacro(__FOLDER_ID_GAME)

    ---@type rech.util.DrawLine
    local drawline = require("rech.util.drawline")
    drawline.initMacro(__FOLDER_ID_UTIL)

    ---@type rech.util.RemoveArcTapTrace
    local ratt = require("rech.util.remove-arctap-trace")
    ratt.initMacro(__FOLDER_ID_UTIL)

    ---@type rech.util.OptimizeChart
    local optimize = require("rech.util.optimize-chart")
    optimize.initMacro(__FOLDER_ID_UTIL)

    ---@type rech.jaycurry.JayCurry
    local jaycurry = require("rech.jaycurry.init")
    jaycurry.initMacro(__FOLDER_ID_JQ)
end
