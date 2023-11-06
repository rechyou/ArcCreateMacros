do
    ---@type rech.Class
    local Class = require("rech.Class")
    ---@type rech.jaycurry.Filter
    local Filter = require("rech.jaycurry.Filter")

    ---@class rech.jaycurry.JayCurry
    local this = Class()

    ---@field private events table<string,LuaChartEvent[]>
    ---@field private events.all LuaChartEvent
    ---@field private events.tap LuaTap
    ---@field private events.hold LuaHold
    ---@field private events.arc LuaArc
    ---@field private events.arctap LuaArcTap
    ---@field private events.timing LuaTiming
    ---@field private events.camera LuaCamera
    ---@field private events.scenecontrol LuaScenecontrol
    ---@field private query string
    local this__inst = {}

    ---@enum rech.jaycurry.ElementTypes
    this.ElementTypes = {}
    this.ElementTypes.tap="tap"
    this.ElementTypes.hold="hod"
    this.ElementTypes.arc="arc"
    this.ElementTypes.arctap="arctap"
    this.ElementTypes.timing="timing"
    this.ElementTypes.camera="camera"
    this.ElementTypes.scenecontrol="scenecontrol"

    this.ClassTypes = {blue=1,red=2,green=3,void=4,solid=5,judgable=6,judgable=6,sky=7,floor=8,short=9,long=10}
    
    local registeredScenecontrol = {
        -- ArcCreate built-in Scenecontrol
        ["hidegroup"] = -1,
        ["groupalpha"] = -1,
        ["trackdisplay"] = -1,
        ["enwidencamera"] = -1,
        ["enwidenlanes"] = -1,
    }

    local function tableappend(table, table2)
        if #table2 == 0 then return end
        for _, v in ipairs(table2) do
            table[#table+1] = v
        end
    end

    ---Select ArcTap of Arc
    ---@param arc LuaArc[]
    local function ofArcsConstraint(arc)
        ---@param arctap LuaArcTap
        return function(arctap)
            if not arctap.is("arctap") then return false end
            local arc2 = arctap.arc
            for _,arc1 in ipairs(arc) do
                if arc1.instanceEquals(arc2) then return true end
            end
            return false
        end
    end
    
    function this.registerScenecontrol(scName, endTimingArgIndex)
        if endTimingArgIndex == nil then endTimingArgIndex = -1 end
        registerScenecontrol[scName] = endTimingArgIndex
    end
    
    function this:init()
        ---@type string
        self.queryString = nil

        self.events = {}
        ---@type LuaChartEvent[]
        self.events.all = {}
        ---@type LuaTap[]
        self.events.tap = {}
        ---@type LuaHold[]
        self.events.hold = {}
        ---@type LuaArc[]
        self.events.arc = {}
        ---@type LuaArcTap[]
        self.events.arctap = {}
        ---@type LuaTiming[]
        self.events.timing = {}
        ---@type LuaCamera[]
        self.events.camera = {}
        ---@type LuaScenecontrol[]
        self.events.scenecontrol = {}
    end

    ---Static function for query, accepts multiple selectors, returns JayCurry instance.
    ---@param query string
    ---@return rech.jaycurry.JayCurry
    function this.query(selectors)
        local self = this()
        self.queryString = selectors
        for constraint in self.queryString:gmatch("[^%s]+") do
            local result, flags = this._buildConstraint(constraint)
            ---@type EventSelectionRequest
            local req = nil
            if flags.selected then
                req = Event.getCurrentSelection(result)
            else
                req = Event.query(result)
                -- coroutine.yield()
            end
            if flags.arctap then
                -- backup selection
                local oldSelection = Event.getCurrentSelection()
                Event.setSelection(req.resultCombined)
                req = Event.query(EventSelectionConstraint.create().arctap().custom(ofArcsConstraint(req.arc), ""))
                -- coroutine.yield()
                Event.setSelection(oldSelection.resultCombined)
            end
            tableappend(self.events.all, req.resultCombined)
            tableappend(self.events.tap, req.tap)
            tableappend(self.events.hold, req.hold)
            tableappend(self.events.arc, req.arc)
            tableappend(self.events.arctap, req.arctap)
            tableappend(self.events.timing, req.timing)
            tableappend(self.events.camera, req.camera)
            tableappend(self.events.scenecontrol, req.scenecontrol)
        
        end
        return self
    end

    ---Create a subquery Selects resulting note., only accepts one selector, flags are not allowed in this context.
    ---@return self
    function this:children(selector)
        local subquery = this()
        -- backup selection
        local oldSelection = Event.getCurrentSelection()
        coroutine.yield()
        Event.setSelection(self.events.all)
        local result, flags = this._buildConstraint(selector:match("[^%s]+"))
        local req = Event.getCurrentSelection(result)
        coroutine.yield()
        if flags.arctap then
            -- backup selection
            local oldSelection = Event.getCurrentSelection()
            Event.setSelection(req.resultCombined)
            req = Event.query(EventSelectionConstraint.create().arctap().custom(ofArcsConstraint(req.arc), ""))
            -- coroutine.yield()
            Event.setSelection(oldSelection.resultCombined)
        end
        tableappend(subquery.events.all, req.resultCombined)
        tableappend(subquery.events.tap, req.result["tap"])
        tableappend(subquery.events.hold, req.result["hold"])
        tableappend(subquery.events.arc, req.result["arc"])
        tableappend(subquery.events.arctap, req.result["arctap"])
        tableappend(subquery.events.timing, req.result["timing"])
        tableappend(subquery.events.camera, req.result["camera"])
        tableappend(subquery.events.scenecontrol, req.result["scenecontrol"])
        --- restore selection
        Event.setSelection(oldSelection.resultCombined)
        return subquery
    end

    ---Selects resulting note.
    function this:select()
        Event.setSelection(self.events.all)
    end

    ---Returns batch command that removes resulting notes.
    function this:remove()
        local command = Command.create()
        for _,item in ipairs(self.events.all) do
            command.add(item.delete())
        end
        return command
    end

    ---Returns batch command that moves arc by deltaX and deltaY.
    ---@param dx number
    ---@param dy number
    function this:movearc(dx, dy)
        local command = Command.create()
        for _,item in ipairs(self.events.arc) do
            item.startXY = xy(item.startX + dx, item.startY + dy)
            item.endXY = xy(item.endX + dx, item.endY + dy)
            command.add(item.save())
        end
        return command
    end

    ---Returns batch command that offsets event timing by ms.
    ---@return LuaChartCommand
    ---@param timing integer
    function this:offset(offset)
        local command = Command.create()
        for _,item in ipairs(self.events.timing) do
            if item.timing == 0 then
                command.add(item.copy().save())
            end
            item.timing = item.timing + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.tap) do
            item.timing = item.timing + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.arctap) do
            item.timing = item.timing + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.hold) do
            item.timing = item.timing + offset
            item.endTiming = item.endTiming + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.arc) do
            item.timing = item.timing + offset
            item.endTiming = item.endTiming + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.camera) do
            item.timing = item.timing + offset
            command.add(item.save())
        end
        for _,item in ipairs(self.events.scenecontrol) do
            local endTimingArgIndex = registeredScenecontrol[item.type]
            if endTimingArgIndex ~= nil then
                item.timing = item.timing + offset
                if endTimingArgIndex > 0 then
                    item.args[endTimingArgIndex] = item.args[endTimingArgIndex] + offset
                end
                command.add(item.save())
            end
        end
        return command
    end

    ---Copy objects to destination timing group
    ---@return LuaChartCommand
    ---@param tg number
    function this:copy(tg, skipConflicts)
        if tg >= Context.timingGroupCount then
            return nil
        end
        local command = Command.create()
        local newTimings = self.events.timing
        if not skipConflicts then
            -- replace clashed timings first
            log(string.format("timing[g=%d]", tg))
            local timings = this.query(string.format("timing[g=%d]", tg)).events.timing
            local function f()
                for sourceIndex,source in ipairs(newTimings) do
                    for targetIndex,target in ipairs(timings) do
                        if target.timing == source.timing then
                            target.bpm = source.bpm
                            command.add(target.save())
                            table.remove(newTimings, sourceIndex)
                            return
                        end
                    end
                end
            end
            f()
        end
        for _,item in ipairs(newTimings) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.tap) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.arctap) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.hold) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.arc) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.camera) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        for _,item in ipairs(self.events.scenecontrol) do
            local n = item.copy()
            n.timingGroup = tg
            command.add(n.save())
        end
        return command
    end

    ---Move objects to destination timing group
    ---@return LuaChartCommand
    ---@param tg number
    function this:move(tg)
        if Event.getTimingGroup(tg) == nil then
            return nil
        end
        local command = Command.create()
        for _,item in ipairs(self.events.timing) do
            if item.timing == 0 then
                item = item.copy()
            end
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.tap) do
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.arctap) do
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.hold) do
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.arc) do
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.camera) do
            item.timingGroup = tg
            command.add(item.save())
        end
        for _,item in ipairs(self.events.scenecontrol) do
            item.timingGroup = tg
            command.add(item.save())
        end
        return command
    end

    ---@param index number
    ---@return LuaTimingGroup[]
    function this.GetTimingGroups(index)
        index = tonumber(index)
        if index == nil then index = 1 end
        local t = {}
        for i = 0, Context.timingGroupCount -1 do
            t[#t+index] = Event.getTimingGroup(i)
        end
        return t
    end

    ---@return LuaTimingGroup[]
    function this.GetTimingGroupNameIndex()
        local t = {}
        for i = 0, Context.timingGroupCount - 1 do
            local name = Event.getTimingGroup(i).name
            if name then
                t[Event.getTimingGroup(i).name] = i
            end
        end
        return t
    end

    ---@private
    ---@param query string
    function this._buildConstraint(query)
        ---@type rech.jaycurry.Filter
        local customFilter = Filter()
        local element = query:match("^[^%[%]%.%:]+")
        local flags = {}
        customFilter:setTimingGroupMapping(this.GetTimingGroupNameIndex())

        if element ~= nil then
            element = element:lower()
            if not this.ElementTypes[element] then error("Element type " .. element .. " is not valid.") end
            customFilter:typeof(element)
        end
        -- Parse attributes 
        local starts, ends, attributes = query:find("^%a*%[(.*)%]")
        if attributes then
            for attribute in attributes:gmatch("[^,]+") do
                local prop, op, value = attribute:match("^(%w+)([!~>=<]*)(.*)")
                ---@type fun(self, op:string,value:any):fun(e:LuaChartEvent):boolean
                local filter = customFilter.mapping[prop:lower()]
                if filter == nil then error("property " .. prop .. " does not exist!") end
                filter(customFilter, op, value)
            end
        end
        if ends == nil then ends = 0 end
        -- Parse classes (.void.judgable)
        for class in query:sub(ends+1):gmatch("%.(%a+)") do
            local function f()
                if class == "blue" then
                    customFilter:color("=", 0)
                    return
                end
                if class == "red" then
                    customFilter:color("=", 1)
                    return
                end
                if class == "green" then
                    customFilter:color("=", 2)
                    return
                end
                if class == "void" then
                    customFilter:void("=", true)
                    return
                end
                if class == "solid" then
                    customFilter:void("=", false)
                    return
                end
                if class == "judgable" or class == "judgeable" then
                    customFilter:typeof(class)
                    return
                end
                if this.ClassTypes[class] then
                    customFilter:typeof(class)
                    return
                end
            end
            f()
        end
        for flag in query:sub(ends+1):gmatch("%:(%a+)") do
            local function f()
                if flag == "arctap" then
                    flags.arctap = true
                    return
                end
                if flag == "at" then
                    flags.arctap = true
                    return
                end
                if flag == "selected" then
                    flags.selected = true
                    return
                end
                if flag == "sel" then
                    flags.selected = true
                    return
                end
            end
            f()
        end
        local constraint = EventSelectionConstraint.create().any().custom(customFilter:build(), "")
        return constraint, flags
    end

    return this
end
