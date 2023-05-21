do
    ---@type rech.Class
    local Class = require("rech.Class")

    ---@module rech.jaycurry.Filter
    ---Custom constraints and some built-in constraints
    local this = Class()

    function this:init()
        self.conditions = {}
        self.haveTimingGroupConstraint = false
        self.types = {}
        self.haveTypeConstraint = false
    end

    ---Builds a dynamic function for custom constraints, faster than chaining a lot of custom constraints.
    function this:build()
        local typeCondition = nil
        if self.haveTypeConstraint then
            local typeofConditions = {}
            for type,enabled in pairs(self.types) do
                log(type)
                if enabled then
                    typeEscaped = string.format("%q", type)
                    typeofConditions[#typeofConditions+1] = "(e.is(" .. typeEscaped .. "))"
                end
            end
            typeCondition = "(" .. table.concat(typeofConditions, "or") .. ")"
        end
        local condition = table.concat(self.conditions, "and")
        if condition == "" then condition = " true" end
        local f = "local e = ...\n"
        if self.haveTypeConstraint then
            f = f .. "if not" .. typeCondition .. "then return false end\n"
        end
        if self.haveTimingGroupConstraint then
            f = f .. "local tg = Event.getTimingGroup(e.timingGroup)\n"
        end
        f = f .. "return" .. condition
        f = load(f)
            return f
    end

    -- ---@param f function
    -- function this:innerjoin(f1, f2)
    --     return function (e)
    --         return f1(e) and f2(e)
    --     end
    -- end

    -- ---@param fn function[]
    -- function this:allEquals(fn)
    --     return function (e)
    --         for _,f in ipairs(fn) do
    --             if not f(e) then return false end
    --             return true
    --         end
    --     end
    -- end

    ---@return boolean
    local function generateCompare(op, v1, v2)
        if op == "=" then op = "==" end
        local valid = 
            op == "=="
            or op == "~="
            or op == ">="
            or op == "<="
            or op == ">"
            or op == "<"
        if not valid then
            error("Operator " .. op .. " is invalid for " .. v1 .. " and " .. v2)
        end
        if type(v2) == "string" then v2 = string.format("%q", v2) end
        v2 = tostring(v2)
        return "(" .. v1 .. "~= nil and " .. v1 .. op .. v2 .. ")"
    end

    local function trueByDefault(operator, value)
        if operator == nil then return "=", true end
        if operator == "" then return "=", true end
        return operator, value
    end

    local function requireEqual(operator, value)
        if operator ~= nil and operator ~= "=" then error("Operator has to be = for matching " .. value .. ".") end
    end

    ---@param type ('"any"' | '"tap"' | '"hold"' | '"arc"' | '"solidarc"' | '"voidarc"' | '"trace"' | '"arctap"' | '"timing"' | '"camera"' | '"floor"' | '"sky"' | '"short"' | '"long"' | '"judgeable"')
    function this:typeof(type)
        self.types[type] = true
        self.haveTypeConstraint = true
        return self
    end

    --- All events

    ---@param value integer
    function this:group(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.timingGroup", value)
        return self
    end

    ---@param value integer
    function this:timing(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.timing", value)
        return self
    end

    ---@param value integer
    function this:lane(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.lane", value)
        if self.types["tap"] or self.types["hold"] then return self end
        return self:typeof("floor")
    end

    --- Long notes

    ---@param value integer
    function this:endtiming(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.endTiming", value)
        return self:typeof("long")
    end

    ---@param value integer
    function this:duration(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.endTiming-e.timing", value)
        return self:typeof("long")
    end
    
    --- Arc

    local colorMapping = {
        blue = 0,
        red  = 1,
        green = 2,
    }
    ---@param value integer
    function this:color(operator, value)
        value = tonumber(value)
        if type(value) == "string" then value = colorMapping[value] end
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.color", value)
        return self:typeof("arc")
    end

    ---@param value integer
    function this:x1(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.startX", value)
        return self:typeof("arc")
    end

    ---@param value integer
    function this:x2(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.endX", value)
        return self:typeof("arc")
    end

    ---@param value integer
    function this:y1(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.startY", value)
        return self:typeof("arc")
    end

    ---@param value number
    function this:y2(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.endY", value)
        return self:typeof("arc")
    end

    ---@param value string
    function this:easing(operator, value)
        requireEqual(operator, value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.type", value)
        return self:typeof("arc")
    end

    ---@param value boolean
    function this:void(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.isVoid", value)
        return self:typeof("arc")
    end

    ---ArcTap

    ---@param value integer
    function this:x(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.arc.xAt(e.timing, true)", value)
        return self:typeof("arctap")
    end

    ---@param value integer
    function this:y(operator, value)
        value = tonumber(value)
        self.conditions[#self.conditions+1] = generateCompare(operator, "e.arc.yAt(e.timing, true)", value)
        return self:typeof("arctap")
    end

    ---TimingGroup properties

    ---@param value boolean
    function this:noinput(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noInput", value)
        return self
    end

    ---@param value number
    function this:anglex(operator, value)
        value = tonumber(value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.angleX", value)
        return self
    end

    ---@param value number
    function this:angley(operator, value)
        value = tonumber(value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.angleY", value)
        return self
    end

    ---@param value string
    function this:side(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.side", value)
        return self
    end

    ---@param value boolean
    function this:noarccap(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noArcCap", value)
        return self
    end

    ---@param value boolean
    function this:noclip(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noClip", value)
        return self
    end

    ---@param value boolean
    function this:nohead(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noHead", value)
        return self
    end

    ---@param value boolean
    function this:noheightindicator(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noHeightIndicator", value)
        return self
    end

    ---@param value boolean
    function this:noshadow(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.noShadow", value)
        return self
    end

    ---@param value boolean
    function this:fadingholds(operator, value)
        operator, value = trueByDefault(operator, value)
        requireEqual(operator, value)
        self.haveTimingGroupConstraint = true
        self.conditions[#self.conditions+1] = generateCompare(operator, "tg.fadingHolds", value)
        return self
    end
    
    this.mapping = {
        ["timing"] = this.timing,
        ["t"] = this.timing,
        ["group"] = this.group,
        ["g"] = this.group,
        ["lane"] = this.lane,
        ["endtiming"] = this.endtiming,
        ["t2"] = this.endtiming,
        ["duration"] = this.duration,
        ["d"] = this.duration,
        ["color"] = this.color,
        ["x1"] = this.x1,
        ["x2"] = this.x2,
        ["y1"] = this.y1,
        ["y2"] = this.y2,
        ["void"] = this.void,
        ["v"] = this.v,
        ["easing"] = this.easing,
        ["e"] = this.easing,
        ["x"] = this.x,
        ["y"] = this.y,
        ["noinput"] = this.noinput,
        ["noshadow"] = this.noshadow,
        ["anglex"] = this.anglex,
        ["angley"] = this.angley,
        ["side"] = this.side,
        ["noarccap"] = this.noarccap,
        ["noclip"] = this.noclip,
        ["nohead"] = this.nohead,
        ["noheightindicator"] = this.noheightindicator,
        ["fadingholds"] = this.fadingholds,
    }

    return this
end