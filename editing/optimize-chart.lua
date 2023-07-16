do
    ---@type rech.Object
    local Class = require("rech.Class")
    
    ---@class rech.editing.OptimizeChart
    local this = Class()

    ---@type rech.jaycurry.JayCurry
    local jq = require("rech.jaycurry.JayCurry")

    local __MACRO_ID = "rech.editing.OptimizeChart"
    local __MACRO_DISPLAY_NAME = "Optimize chart"

    ---Init macro
    ---@param parentId string
    function this.initMacro(parentId)
        removeMacro(__MACRO_ID)
        addMacroWithIcon(parentId, __MACRO_ID, __MACRO_DISPLAY_NAME, "e663", this.activate)
    end

    ---@param batch Command
    local function optimizeStraightArc(batch)
        local q = nil
        q = jq.query("arc[x1==x2,y1==y2] arc[t1==t2] arc[x1==x2,y1~=y2,easing=si] arc[x1==x2,y1~=y2,easing=so]")
        for _,v in ipairs(q.events.arc) do
            v.type = "s"
            batch.add(v.save())
        end
        q = jq.query("arc[y1==y2]")
        for _,v in ipairs(q.events.arc) do
            v.type = v.type:sub(0, 2)
            batch.add(v.save())
        end
    end

    function this.activate()
        local batch = Command.create("Optimize chart")
        optimizeStraightArc(batch)
        batch.commit()
    end

    return this
end
