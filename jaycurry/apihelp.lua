return [[<b><size=20>Lua API</size></b>
JayCurry can also be used as Lua functions, you can import the module by adding following line:
<b>require("rech.jaycurry.init")</b>
or
<b>local JayCurry = require("rech.jaycurry.JayCurry")
local q = JayCurry.query</b>

you then now then use <b>q()</b> to query notes, it returns an JayCurry instance.

<size=18>JayCurry class functions</size>
<b>JayCurry.query(query)</b>
    Static function for query, accepts multiple selectors, returns JayCurry instance.
<b>JayCurry.registerScenecontrol(scName, endTimingParamIndex)</b>
    Register Scenecontrol command, event will also be applied for offset by calling <b>:offset()</b> instance methods.
    If endTimingParamIndex is defined, when <b>:offset()</b> is called, the parameter value will also be modified.

<size=18>JayCurry instance functions</size>
<b>:children(query)</b>
    Create a subquery from resulting notes, only accepts one selector, flags are not allowed in this context.
<b>:select()</b>
    Selects resulting note.
<b>:remove()</b>
    Returns batch command that removes resulting notes.
<b>:offset(ms)</b>
    Returns batch command that offsets event timing by ms.
<b>:movearc(deltaX, deltaY)</b>
    Returns batch command that moves arc by deltaX and deltaY.
]]
