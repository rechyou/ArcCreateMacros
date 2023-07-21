return [[<b><size=20>Query syntax</size></b>
JayCurry selector implements a syntax that defines the pattern to select elements.
JC selector can be grouped into 4 categories: Element Types, Attributes, Classes, Flags

<size=18>Examples</size>
<b>arc[y1>=1].void:arctap</b>
This queries arctap where the arc is void and y1 is larger than 1.

<b>arctap[x>=0,x<=1]</b>
Selects ArcTap where their x is at 0~1.

<b>tap[noinput=false]</b>
Selects floor tap where their timing group resides does not have noinput.

<size=18>Element Types</size>
<b>tap</b> - Floor tap
<b>hold</b> -Floor holds
<b>arc</b> - Arcs
<b>arctap</b> - ArcTap
<b>timing</b> - Timing
<b>camera</b> - Camera
<b>scenecontrol</b> - Scenecontrol

<size=18>Attributes</size>
Several attributes supports more than equal comparators (=), for example, >, >=, <, <=
Attributes supporting that are:
<b>timing, endTiming, group, anglex, angley, color, x1, x2, y1, y2, x, y</b>
Attributes that automatically assumed as <color=green>true</color> when there's no value specified are:
<b>void, noinput, noarccap, noclip, nohead, noheightindicator, noshadow, fadingholds</b>

Attributes are splitted into different categories: <b>All events, long notes, floor notes, Arc, ArcTap</b>
<color=#ffaaaa>Note: when attributes for designated types are used, type constraints are automatically applied.</color>

Some attributes allow self-comparing: timing, endTiming, x1, x2, y1, y2.
For example, arc[x1==x2] selects arc that has same starting X position and ending X position.

<size=16>All events and notes</size>
<b>timing t t1</b>
    Event start timing
<b>group tg g</b>
    Timing group ID of the event
<b>fadingholds noinput noshadow noarccap nohead noheightindicator noclip side</b>
    Timing group where event resides match attribute value
<b>anglex angley</b>
    Timing group note approaching angle

<size=16>Long notes</size>
<b>endTiming t2</b>
    End timing of the event
<b>duration d</b>
    Duration of the event

<size=16>Floor notes</size>
<b>lane</b>
    Lane position

<size=16>Arc</size>
<b>color</b>
    Color value
<b>x1 x2 y1 y2</b>
    Arc starting/ending position
<b>void v</b>
    Arc void state
<b>easing e</b>
    Arc easing

<size=16>ArcTap</size>
<b>x y</b>
    ArcTap position at their timing

<size=18>Classes</size>
<b>.blue</b>
    Arc color is 0 ([color=1])
<b>.red</b>
    Arc color is 1 ([color=1])
<b>.green</b>
    Arc color is 2 ([color=2])
<b>.void</b>
    Shorthand for attribute [void=true]
<b>.solid</b>
    Shorthand for attribute [void=false]
<b>.judgable .judgeable</b>
    Event is judgable note
<b>.floor</b>
    Event is floor note
<b>.sky</b>
    Event is Arc or ArcTap
<b>.short</b>
    Event is short note (tap)
<b>.long</b>
    Event is long note (hold, arc)

<size=18>Flags</size>
<b>:selected :sel</b>
    Only query from notes user selected
<b>:arctap :at</b>
    Only select arctaps from resulting arcs



]]

