__includes ["SOM.nls" "Geom A-star.nls"]


; Markers breed: show the solution in real time
breed [ markers marker ]

breed [ robots robot ]

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
  setup-random-NVMesh
;  ask n-of Num-cities patches [
;    set pcolor white
;  ]
  set Tset [(list pxcor pycor)] of patches with [pcolor = white]
  ; Reset timer
  reset-ticks
end

; Create a random set of points that the robots can reach
to setup-random-NVMesh
  ; Import the map from an image. No Black colors will be considered as walls
  import-pcolors "map1.png"
  ask patches with [pcolor != black] [
    set pcolor red
    ask neighbors [set pcolor red]]
  ; Create robots to move around in a random way
  create-robots 20 [
    move-to one-of patches with [pcolor != red]
    set shape "robot"
    set size 3
  ]
  ; Repeat the process to create different random walks
  repeat 20 [
    ask robots [
      move-to one-of patches with [pcolor != red and not any? patches with [pcolor = red and distance myself < 3]]
      rt random 360
      repeat 30 [
        ifelse (any? (patches with [pcolor = red]) in-cone 3 45)
        [ rt 90 ]
        [ fd 1
          ; The robot will leave a spot only sometimes
          if random 10 = 0 [set pcolor white]
          rt random 10 - 5
        ]
      ]
    ]
  ]
  ask robots [die]
  ;Leave one robot for the cleaning and test
  create-robots 1 [
    set shape "robot"
    set size 3
    set color yellow
  ]
end

to setup-markers
  set-default-shape markers "circle"
  ; Markers will show the links between them (roads between spots)
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
  ask patches with [pcolor = white] [set pcolor black]
  set-plot-x-range 0 (1 + max [link-length] of links)
  histogram [link-length] of links
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

; Procedure to test the A* algorithm between two random nodes of the network, and clean
; the links that wil try to cross a wall.

to clean
  ; Take one random starting and ending point
  let start one-of markers
  ask start [set color green set size 1]
  let goal one-of markers with [distance start > max-pxcor]
  ask goal [set color green set size 1]
  let rep start
  ; If rep is not true, then rep will contain the last correct marker in the path,
  ; and the A* search is repeated from this last marker to the original goal.
  ; This trick removes a lot of incorrect links from the nav mesh in a fast way,
  ; because usually close to an incorrect one there are more incorrect.
  while [rep != true] [
    ; unhighlight the last path
    ask links with [color = yellow][set color grey set thickness 0]
    ; Compute the path with A*
    let path (A* rep goal)
    ; if any, we highlight it
    ifelse path != false [
      highlight-path path
      ; Ask the robot to try to follow the path
      ask robots[
        set rep follow-path path
    ]]
    [set rep true]
  ]
end

; Procedure to force a robot to follow a path. It will report true if it is successfull,
; and the last correct marker if there is a link that tries to cross a wall
to-report follow-path [path]
  move-to first path
  ; Move the robot from a to (a+1) marker in the path
  (foreach (bl path) (bf path) [
    [x y] ->
    let rep go-from-to x y
    if rep != true [ report rep ]
    ])
  report true
end

; Procedure to animate the movement of the robot to go from a marker a to a marker b.
; It will report true if it successfull, and a if the link a->b tries to cross a wall.
; If this is the case, this link is removed from the navigation mesh,
to-report go-from-to [a b]
  face b
  ;ask link [who] of a [who] of b [set color color + .01 set thickness thickness + .01]
  while [distance b > 1] [
    ; If the robot has a wall in front, then the link is incorrect and must be removed
    if (any? (patches with [pcolor = red]) in-cone 3 30) [
      ask (link [who] of a [who] of b) [die]
      report a
    ]
    fd 1
    display
  ]
  move-to b
  report true
end


; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  let a reduce highlight path
end


; Auxiliaty report to highlight the path with a reduce method. It recieives two nodes, as a secondary
; effect it will highlight the link between them, and will return the second node.
to-report highlight [x y]
  ask x
  [
    ask link-with y [set color yellow set thickness .4]
  ]
  report y
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
40
182
73
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
156
182
189
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
156
95
189
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
190
95
235
Radius
precision (SOM:R ticks) 3
17
1
11

MONITOR
97
190
182
235
Learning Rate
precision (SOM:L ticks) 5
17
1
11

SLIDER
10
75
182
108
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
5
182
38
N
N
1
600
15.0
1
1
NIL
HORIZONTAL

CHOOSER
10
110
182
155
Topology
Topology
"Ring" "SqGrid" "HxGrid"
1

PLOT
570
15
770
165
Histogram
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

BUTTON
100
340
182
373
100 clean
repeat 100 [clean]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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

robot
true
0
Circle -7500403 true true 120 0 60
Circle -16777216 false false 58 58 182
Circle -7500403 true true 60 60 180
Line -16777216 false 150 30 150 150
@#$#@#$#@
NetLogo 6.1.1
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
