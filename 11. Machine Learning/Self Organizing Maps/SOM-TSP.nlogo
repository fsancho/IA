__includes ["SOM.nls"]


; Markers breed: show the solution in real time
breed [ markers marker ]

globals [
  TSet      ; Training set
  ]

markers-own [
  mynode     ; Node associated to this marker
]

; Create random cities and set TSet as their coordinates
to setup
  ca
  ; Create the learning nodes
  SOM:setup-Lnodes N Topology 2 "G"
  ; Create the markers
  setup-markers
  ; Create the cities (Training Set)
  ask n-of Num-cities patches [
    set pcolor white
  ]
  set Tset [(list pxcor pycor)] of patches with [pcolor = white]
  ; Reset timer
  reset-ticks
end

to setup-markers
  set-default-shape markers "circle"
  ; Markers will show the links between them (roads between cities)
  ask SOM:Lnodes [
    let x (item 0 weight)
    let y (item 1 weight)
    hatch-markers 1 [
      st
      setxy x y
      set color [52 93 169 50]
      set mynode myself
    ]
  ]
  ; Create the ring of markers
  ask links [
    let e1 end1
    let e2 end2
    let m1 one-of markers with [mynode = e1]
    let m2 one-of markers with [mynode = e2]
    ask m1 [create-link-with m2]
  ]
end

to Launch
  SOM:SOM TSet Training-Time
end

to SOM:ExternalUpdate
  ; Update the markers position
  ask markers [
    let xy [weight] of mynode
    setxy (first xy) (last xy)
  ]
  ; and count one tick
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
185
10
547
373
-1
-1
3.505
1
12
1
1
1
0
0
0
1
-50
50
-50
50
1
1
1
ticks
30.0

SLIDER
10
80
182
113
Training-Time
Training-Time
0
10000
100.0
100
1
NIL
HORIZONTAL

BUTTON
97
196
182
229
SOM!
Launch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
196
95
229
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
230
95
275
Radius
precision (SOM:R ticks) 3
17
1
11

MONITOR
97
230
182
275
Learning Rate
precision (SOM:L ticks) 5
17
1
11

SLIDER
10
115
182
148
Initial-Learning-Rate
Initial-Learning-Rate
0
1
0.1
.001
1
NIL
HORIZONTAL

SLIDER
10
45
182
78
N
N
1
600
417.0
1
1
NIL
HORIZONTAL

SLIDER
10
10
182
43
Num-Cities
Num-Cities
1
200
200.0
1
1
NIL
HORIZONTAL

CHOOSER
10
150
182
195
Topology
Topology
"Ring" "SqGrid" "HxGrid"
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

hex
false
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
