; Every patch-node will have a variable to store the weight vector
patches-own [
  weight ]

; TSet stores the Training Set
globals [
  TSet
  ]

; Setup procedure: initially, a weight is assigned to every node.
;   It can be done randomly, or using a grey gradient
to setup
  ca
  ifelse (Init = "Random")
  [
    ask patches [
      set weight n-values 3 [random-float 1]
      set pcolor rgb (255 * item 0 weight) (255 * item 1 weight) (255 * item 2 weight) ]
  ]
  [
    ask patches [
      set pcolor scale-color black ((pxcor + pycor + 2 * max-pxcor) / (4 * max-pxcor)) 0 1
      set weight map [? / 255] extract-rgb pcolor ]
  ]
  set TSet n-values TSet-size [n-values 3 [random-float 1]]
  reset-ticks
end

; Time-dependent Radius: It decreases the radius softly from
;    covering the world to one point.
to-report R [t]
  let T-Cons Training-Time / (ln max-pxcor)
  report (max-pxcor * exp (-1 * t / T-Cons))
end

; Euclidean Distance function (without square root)
to-report dist [v1 v2]
  report sum (map [(?1 - ?2) ^ 2] v1 v2)
end

; Weight Update function:
;   It depends on the distance to BMU, the Learning Rate, and a
;   function D to soft in the borders.
to-report new-weight [W V t]
  report (map [?1 + (D t) * (L t) * (?2 - ?1)] W V)
end

; Learning Rate Function:
;   It starts with a custom value and decresase in the iterations.
to-report L [t]
  report Initial-Learning-Rate * exp (-1 * t / Training-Time)
end

; Soft function for the weight update function.
to-report D [t]
  report exp (-1 * (distance myself) / (2 * (R t)))
end

; Best Matching Unit: Closest weight-patch to V.
to-report BMU [V]
  report min-one-of patches [dist ([weight] of self) V]
end

; SOM Algorithm iteration:
;   For every training vector, we take its BMU and update its neighbourhood.
;   It will stop automatically after Training-Time steps.
to SOM
  foreach (shuffle TSet)
  [
    let V ?
    let W BMU V
    ask W [
      ask patches in-radius (R ticks)
      [
        set weight new-weight weight V ticks
        set pcolor rgb (255 * item 0 weight) (255 * item 1 weight) (255 * item 2 weight) ]
    ]
  ]
  tick
  if ticks > Training-Time [stop]
end
@#$#@#$#@
GRAPHICS-WINDOW
182
10
600
449
25
25
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
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
200
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
SOM
T
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
precision (R ticks) 3
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
9
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
precision (L ticks) 5
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
0.1
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

@#$#@#$#@
NetLogo 5.3
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
