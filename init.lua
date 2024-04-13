do
    local __FOLDER_ID = "rech"
    local __FOLDER_ID_GAME = "rech.game"
    local __FOLDER_ID_EDITING = "rech.editing"
    local __FOLDER_ID_EDITING_SEGMENTATION = "rech.editing.segmentation"
    local __FOLDER_ID_MISC = "rech.misc"
    local __FOLDER_ID_JQ = "rech.jaycurry"
    addFolderWithIcon(nil, __FOLDER_ID, "ea0b","rech's macro")
    do
        addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_EDITING, "e3c9","[Editing]")
        do
            addFolderWithIcon(__FOLDER_ID_EDITING, __FOLDER_ID_EDITING_SEGMENTATION, "e919","[Arc Segmentation]")

            ---@type rech.editing.NarArc
            local narArc = require("rech.editing.segmentation.nar-arcs")
            narArc.initMacro(__FOLDER_ID_EDITING_SEGMENTATION)

            ---@type rech.editing.SquareWaveArc
            local squareWave = require("rech.editing.segmentation.square-wave-arc")
            squareWave.initMacro(__FOLDER_ID_EDITING_SEGMENTATION)

            ---@type rech.editing.MacaroniArc
            local narArc = require("rech.editing.segmentation.macaroni-arcs")
            narArc.initMacro(__FOLDER_ID_EDITING_SEGMENTATION)
        end
        ---@type rech.editing.ArcReverse
        local arcReverse = require("rech.editing.arc-reverse")
        arcReverse.initMacro(__FOLDER_ID_EDITING)

        ---@type rech.editing.DrawLine
        local drawline = require("rech.editing.drawline")
        drawline.initMacro(__FOLDER_ID_EDITING)

        ---@type rech.editing.CutArcOnTiming
        local cutarc = require("rech.editing.cut-arc-on-timing")
        cutarc.initMacro(__FOLDER_ID_EDITING)

        ---@type rech.editing.RemoveArcTapTrace
        local ratt = require("rech.editing.remove-arctap-trace")
        ratt.initMacro(__FOLDER_ID_EDITING)

        ---@type rech.editing.OptimizeChart
        local optimize = require("rech.editing.optimize-chart")
        optimize.initMacro(__FOLDER_ID_EDITING)
    end

    addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_JQ, "e55c","[JayCurry]")
    ---@type rech.jaycurry.JayCurry
    local jaycurry = require("rech.jaycurry.init")
    jaycurry.initMacro(__FOLDER_ID_JQ)

    do
        addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_GAME, "ea28","[Games]")
        ---@type rech.game.BullsAndCows
        local bullsandcows = require("rech.game.bullsandcows")
        bullsandcows.initMacro(__FOLDER_ID_GAME)

        ---@type rech.game.Wordle
        local wordle = require("rech.game.wordle")
        wordle.initMacro(__FOLDER_ID_GAME)
    end

    do
        addFolderWithIcon(__FOLDER_ID, __FOLDER_ID_MISC, "e152","[Misc]")
        ---@type rech.misc.DoNothing
        local optimize = require("rech.misc.do-nothing")
        optimize.initMacro(__FOLDER_ID_MISC)
        ---@type rech.misc.ArcDisconnectCheck
        local optimize = require("rech.misc.arc-disconnect-check")
        optimize.initMacro(__FOLDER_ID_MISC)
    end
end
