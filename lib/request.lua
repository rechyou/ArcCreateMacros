do
    RSelectionResult = {}
    ---@type LuaTap[]
    RSelectionResult.tap = nil
    ---@type LuaHold[]
    RSelectionResult.hold = nil
    ---@type LuaArc[]
    RSelectionResult.arc = nil
    ---@type LuaArcTap[]
    RSelectionResult.arctap = nil
    ---@type LuaTiming[]
    RSelectionResult.timing = nil
    ---@type LuaCamera[]
    RSelectionResult.camera = nil
    ---@type LuaScenecontrol[]
    RSelectionResult.scenecontrol = nil
    ---@type LuaChartEvent[]
    RSelectionResult.all = nil

    ---@module rech.lib.Request
    local this = {}
    this.__index = this

    ---@param constraint EventSelectionConstraint
    ---@param notification string
    ---@return RSelectionResult
    function this.Event(constraint, notification)
        local req = EventSelectionInput.requestSingleEvent(constraint, notification)
        coroutine.yield()
        ---@type RSelectionResult
        local result = {}
        result.all = req.resultCombined
        result.tap = req.result["tap"]
        result.hold = req.result["hold"]
        result.arc = req.result["arc"]
        result.arctap = req.result["arctap"]
        result.timing = req.result["timing"]
        result.camera = req.result["camera"]
        result.scenecontrol = req.result["scenecontrol"]
        return result
    end

    ---@param constraint EventSelectionConstraint
    ---@param notification string
    ---@return RSelectionResult
    function this.Events(constraint, notification)
        local req = EventSelectionInput.requestEvents(constraint, notification)
        coroutine.yield()
        ---@type RSelectionResult
        local result = {}
        result.all = req.resultCombined
        result.tap = req.result["tap"]
        result.hold = req.result["hold"]
        result.arc = req.result["arc"]
        result.arctap = req.result["arctap"]
        result.timing = req.result["timing"]
        result.camera = req.result["camera"]
        result.scenecontrol = req.result["scenecontrol"]
        return result
    end

    ---@param constraint EventSelectionConstraint
    ---@return RSelectionResult
    function this.CurrentSelection(constraint)
        local req = Event.getCurrentSelection(constraint)
        -- coroutine.yield()
        ---@type RSelectionResult
        local result = {}
        result.all = req.resultCombined
        result.tap = req.result["tap"]
        result.hold = req.result["hold"]
        result.arc = req.result["arc"]
        result.arctap = req.result["arctap"]
        result.timing = req.result["timing"]
        result.camera = req.result["camera"]
        result.scenecontrol = req.result["scenecontrol"]
        return result
    end

    ---@param constraint EventSelectionConstraint
    ---@return RSelectionResult
    function this.Query(constraint)
        local queryResult = Event.query(constraint)
        coroutine.yield()
        ---@type RSelectionResult
        local result = {}
        result.tap = queryResult["tap"]
        result.hold = queryResult["hold"]
        result.arc = queryResult["arc"]
        result.arctap = queryResult["arctap"]
        result.timing = queryResult["timing"]
        result.camera = queryResult["camera"]
        result.scenecontrol = queryResult["scenecontrol"]
        result.all = queryResult.resultCombined
        return result
    end

    ---@param notification string
    ---@return number
    function this.TrackLane(notification)
        local req = TrackInput.requestLane(notification)
        coroutine.yield()
        return req.result["lane"]
    end

    ---@param timing integer
    ---@param notification string
    ---@return XY
    function this.VerticalPosition(timing, notification)
        local req = TrackInput.requestPosition(timing, notification)
        coroutine.yield()
        return req.result["xy"]
    end

    ---@param showVertical boolean
    ---@param notification string
    ---@return number
    function this.Timing(showVertical, notification)
        local req = TrackInput.requestTiming(showVertical, notification)
        coroutine.yield()
        return req.result["timing"]
    end

    return this
end
