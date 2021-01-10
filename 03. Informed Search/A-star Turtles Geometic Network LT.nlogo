__includes ["A-star-LT.nls"]
; In this case, we will work with turtles, not patches.
; Specifically with two types of turtles
breed[nodes node]         ; to represent the nodes of the network

patches-own [weight]

globals [
  tipo
]

; Setup procedure: simply create the geometric network based on the number of random located nodes
; and the maximum radius to connect two any nodes of the network
to setup
  ca
  create-nodes Num-nodes [
    setxy random-xcor random-ycor
    set shape "circle"
    set size .5
    set color blue]
  ask nodes [
    create-links-with other nodes in-radius radius]
;  ask n-of 8 patches [set weight 1]
  ask patches [ set weight random-float 1]
  repeat 300 [ diffuse weight 1]
  let maxw max [weight] of patches
  let minw min [weight] of patches
  ask patches [
    set weight (weight - minw) / (maxw - minw)
    set pcolor scale-color red weight 0 1.5]
end

; Auxiliary procedure to test the A* algorithm between two random nodes of the network
to test
  ask nodes [set color blue set size .5]
  ask links with [color = yellow or color = green][set color grey set thickness 0]
  let start one-of nodes
  ask start [set color green set size 1]
  let goal one-of nodes with [distance start > max-pxcor]
  ask goal [set color green set size 1]
  ; We compute the path with A*
  let ti timer
  set tipo 0
  let path (A* [who] of start [who] of goal)
  print path
  ; if any, we highlight it
  ;show path
  if path != false [
    set path first path
    highlight-path0 path
  ]

;  set tipo 1
;  set path (A* [who] of start [who] of goal)
;  ; if any, we highlight it
;  ;show path
;  if path != false [
;    highlight-path1 path
;  ]

  show timer - ti
end

; Searcher report to compute the heuristic for this searcher: in this case, one good option
; is the euclidean distance from the location of the node and the goal we want to reach
to-report AI:heuristic [content #Goal]
  let rep 0
  ask (node content) [
    set rep distance (node #Goal)
  ]
  report rep
end

to-report AI:final-state? [content goal]
  report content = goal
end

to-report AI:children-of [content]
  let rep []
  ask (node content) [
    let rules my-links
    set rep map [r -> (list ([who] of [other-end] of r) (list content  ([length-mod] of r) "regla"))] (sort rules)
  ]
  report rep
end

to-report length-mod
  ifelse tipo = 0
  [ report link-length  * (([weight] of end1) + ([weight] of end1)) / 2 ]
  [ report link-length ]
end

; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path0 [path]
  let a reduce highlight0 path
end

to highlight-path1 [path]
  let a reduce highlight1 path
end

; Auxiliaty report to highlight the path with a reduce method. It recieives two nodes, as a secondary
; effect it will highlight the link between them, and will return the second node.
to-report highlight0 [x y]
  ask (node x)
  [
    ask link-with (node y) [set color yellow set thickness 1]
  ]
  report y
end

to-report highlight1 [x y]
  ask (node x)
  [
    ask link-with (node y) [set color green set thickness 1]
  ]
  report y
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
622
423
-1
-1
4.0
1
10
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
0
0
1
ticks
30.0

BUTTON
22
76
85
109
NIL
setup
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
131
76
194
109
NIL
test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
10
194
43
radius
radius
0
10
1.0
.1
1
NIL
HORIZONTAL

SLIDER
22
43
194
76
Num-Nodes
Num-Nodes
0
20000
20000.0
50
1
NIL
HORIZONTAL

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300
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
0
@#$#@#$#@
