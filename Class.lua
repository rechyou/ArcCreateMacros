do
    ---@class rech.Class
    local Class = {}
    setmetatable(Class, {
        __call = function (cls, ...)
            return cls.create(...)
        end,
    })

    ---@class rech.Class
    ---@field _instanceof table[]
    local Class__inst = {}

    ---Class creation with inheritance
    ---@vararg table
    function Class.create(...)
        local this, bases = {}, {...}

        for i, base in ipairs(bases) do
            for k, v in pairs(base) do
                this[k] = v
            end
        end

        this.__index, this._instanceof = this, {[this] = true}
        for _, base in ipairs(bases) do
            for c in pairs(base._instanceof) do
                this._instanceof[c] = true
            end
              this._instanceof[base] = true
        end

        setmetatable(this, {
          __call = function (c, ...)
            local instance = setmetatable({}, c)
            local init = instance.init
            if init then init(instance, ...) end
            return instance
          end
        })
        return this
    end

    function Class:instanceof(object)
        return self._instanceof[object] == true
    end

    return Class
end
