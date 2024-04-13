return [[<b><size=20>Lua API</size></b>
JayCurry can also be used as Lua functions, you can import the module by adding following line:
<b>require<i></i>("rech.jaycurry.init")</b>
or
<b>local JayCurry = require<i></i>("rech.jaycurry.JayCurry")
local q = JayCurry.query</b>

you then now can use <b>q()</b> to query notes, it returns a JayCurry instance.

<size=18>JayCurry class static functions</size>
<b>JayCurry.query(query)</b>
    Static function for query, accepts multiple selectors, returns JayCurry instance.
<b>JayCurry.registerScenecontrol(scName, endTimingParamIndex)</b>
    Register Scenecontrol command, event will also be applied for offset by calling <b>:offset()</b> instance methods.
    If endTimingParamIndex is defined, when <b>:offset()</b> is called, the parameter value will also be modified.
<b>JayCurry.GetTimingGroups(index)</b>
    Return a table of LuaTimingGroup, you can specify whether the table starts with 1 or 0.
    When you want the result to be 0 based, put 0 into the parameter field.
    Please note that in Lua, ipair() only works with 1-index based table.
<b>JayCurry.GetTimingGroupNameIndex()</b>
    Return a table of string mapped to timing group ID, for consistency, value starts by 0.
    But base group is not able to be named, so it usually starts by 1

<size=18>JayCurry instance fields</size>
<b>.events.all</b>
    All events
<b>.events.tap</b>
    All Floor Tap events
<b>.events.hold</b>
    All Floor Hold events
<b>.events.arc</b>
    All Arc events
<b>.events.arctap</b>
    All ArcTap events
<b>.events.timing</b>
    All Timing events
<b>.events.camera</b>
    All Camera events
<b>.events.scenecontrol</b>
    All Scenecontrol events

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
<b>:copy(tgId)</b>
    Returns batch command that copy events to specified timing group.
<b>:move(tgId)</b>
    Returns batch command that move events to specified timing group.
]]
