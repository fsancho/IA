__includes ["SOM.nls"]

; TSet stores the Training Set
globals [
  TSet
  ]

; Setup procedure: initially, a weight is assigned to every node.
;   It can be done randomly, or using a grey gradient
to setup
  ca
  set TSet n-values TSet-size [n-values 3 [random-float 1]]
  create-ordered-turtles TSet-size [
    fd 15
    set size 7
    set shape "circle"
    let w (item who TSet)
    set color rgb (255 * item 0 w) (255 * item 1 w) (255 * item 2 w)
  ]

  if (Init = "Random")
  [
    SOM:setup-Lnodes world-width "SqGrid" 3 "R"
    ask patches [
      let w [weight] of one-of SOM:Lnodes-here
      set pcolor rgb (255 * item 0 w) (255 * item 1 w) (255 * item 2 w) ]
  ]
  reset-ticks
end

to go
  SOM:SOM TSet Training-Time
end

to SOM:ExternalUpdate
  ask patches [
    let w [weight] of one-of SOM:Lnodes-here
    set pcolor rgb (255 * item 0 w) (255 * item 1 w) (255 * item 2 w) ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
182
10
556
385
-1
-1
6.0
1
10
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
30.0

SLIDER
10
10
182
43
Training-Time
Training-Time
0
1000
140.0
1
1
NIL
HORIZONTAL

BUTTON
119
154
182
187
SOM!
go
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
154
73
187
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
198
71
243
Radius
precision (SOM:R ticks) 3
17
1
11

SLIDER
10
43
182
76
TSet-size
TSet-size
0
100
6.0
1
1
NIL
HORIZONTAL

MONITOR
71
198
182
243
Learning Rate
precision (SOM:L ticks) 5
17
1
11

SLIDER
10
121
184
154
Initial-Learning-Rate
Initial-Learning-Rate
0
1
0.157
.001
1
NIL
HORIZONTAL

CHOOSER
10
76
182
121
Init
Init
"Random" "Gradient"
0

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
Circle -16777216 false false 0 0 300
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
0
@#$#@#$#@
