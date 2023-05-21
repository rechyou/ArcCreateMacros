do
    ---@type rech.Object
    local Class = require("rech.Class")
    ---@type rech.jaycurry.Filter
    local Filter = require("rech.jaycurry.Filter")

    ---@class rech.jaycurry.JayCurry
    local this = Class()
    this.__index = this

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
            local arc1 = arctap.arc.instance
            local arc2 = arc.instance
            if arc1 == arc2 then return true end
            return false
        end
    end
    
    function this.registerScenecontrol(scName, endTimingArgIndex)
        if endTimingArgIndex == nil then endTimingArgIndex = -1 end
        registerScenecontrol[scName] = endTimingArgIndex
    end
    
    function this:init()
        ---@type string
        self.query = nil
        ---@type table<string,LuaChartEvent[]>
        self.events = {}
        ---@type LuaChartEvent
        self.events.all = {}
        ---@type LuaTap
        self.events.tap = {}
        ---@type LuaHold
        self.events.hold = {}
        ---@type LuaArc
        self.events.arc = {}
        ---@type LuaArcTap
        self.events.arctap = {}
        ---@type LuaTiming
        self.events.timing = {}
        ---@type LuaCamera
        self.events.camera = {}
        ---@type LuaScenecontrol
        self.events.scenecontrol = {}
    end

    ---Creates new query
    ---@param query string
    ---@return rech.jaycurry.JayQuery
    function this.query(selectors)
        local self = this()
        self.query = selectors
        for constraint in self.query:gmatch("[^%s]+") do
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

    --- Create a subquery from selector, only 1 selector is allowed.  
    --- `:selected` selector is not allowed in this context.
    ---@return rech.jaycurry.JayQuery
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

    ---Selects all notes from query
    function this:select()
        Event.setSelection(self.events.all)
    end

    ---Removes event from query
    function this:remove()
        local command = Command.create()
        for _,item in ipairs(self.events.all) do
            command.add(item.delete())
        end
        return command
    end

    ---Offsets arc from query
    ---@param dx number
    ---@param dy number
    function this:movearc(dx, dy)
        local command = Command.create()
        for _,item in ipairs(self.events.arc) do
            item.startX = item.startX + dx
            item.startY = item.startY + dy
            item.endX = item.endX + dx
            item.endY = item.endY + dy
            command.add(item.save())
        end
        return command
    end

    ---Offset event timing from query
    ---@param timing integer
    function this:offset(offset)
        local command = Command.create()
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

    ---@param query string
    function this._buildConstraint(query)
        ---@type rech.rquery.Filter
        local customFilter = Filter()
        local element = query:match("^[^%[%]%.%:]+")
        local flags = {}

        if element ~= nil then
            element = element:lower()
            if this.ElementTypes[element] then error("Element type " .. element .. " is not valid.") end
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
            log(class)
            if class == "blue" then
                customFilter:color("=", 0)
                goto NextClass
            end
            if class == "red" then
                customFilter:color("=", 1)
                goto NextClass
            end
            if class == "green" then
                customFilter:color("=", 2)
                goto NextClass
            end
            if class == "void" then
                customFilter:void("=", true)
                goto NextClass
            end
            if class == "solid" then
                customFilter:void("=", false)
                goto NextClass
            end
            if class == "judgable" or class == "judgeable" then
                customFilter:typeof(class)
                goto NextClass
            end
            if this.ClassTypes[class] then
                customFilter:typeof(class)
                goto NextClass
            end
            :: NextClass ::
        end
        for flag in query:sub(ends+1):gmatch("%:(%a+)") do
            log(flag)
            if flag == "arctap" then
                flags.arctap = true
                goto NextFlag
            end
            if flag == "selected" then
                flags.selected = true
                goto NextFlag
            end
            :: NextFlag ::
        end
        local constraint = EventSelectionConstraint.create().any().custom(customFilter:build(), "")
        return constraint, flags
    end

    return this
end
