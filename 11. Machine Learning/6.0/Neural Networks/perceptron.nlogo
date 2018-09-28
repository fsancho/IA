; Perceptron is the agent that will store the perceptron parameters and will
; visualize both semiplanes. For that, its shape is a two-colored plane (red/blue)
; and its size is big enough to cover the world
breed [perceptrons preceptron]

; One origin at the (0,0)
breed [vectors vector]

; Data will be agents to be learned
breed [data datum]

data-own [
  output ; y
  input  ; (x1,x2)
]

perceptrons-own [
  weight ; [w0 w1 w2]
]


globals [
  origin ; origin agent (located in (0,0) for use fo learning
         ;    process visualization). Only one
  perc   ; perceptron agent. Only one
  w-vec  ; Point to create de weight vector for the perceptron
]

; Procedure to prepare the experiment
to setup
  ca
  ; Create one perceptron.
  create-perceptrons 1 [
    set shape "perceptron"
    set size 5 * max-pxcor
    ; The color is fixed, here we give the transparency
    set color [0 0 0 100]
    ; Random parameters fot the learner
    let w0 0;andom-float 2 - 1
    let w1 random-float 2 - 1
    let w2 random-float 2 - 1
    set weight (list w0 w1 w2)
    ; Orient the learner in the line direction
    set heading 90 + atan w1 w2
    set perc self
  ]

  ; Create the origin in (0,0)
  create-vectors 1[
    set shape "cruz"
    set size 2 * max-pxcor
    set origin self
  ]
  ; Create the point that will be used as reference for the weight vector
  create-vectors 1 [
    st
    set size 0
    let w [weight] of perc
    let n (.1 * sqrt ((item 1 w) ^ 2 + (item 2 w) ^ 2))
    setxy (item 1 w) / n (item 2 w) / n
    create-link-from origin [
      set color white
      set thickness .5
    ]
    set label "w   "
    set w-vec self
  ]

  ; Create random data: line through (xr,yr) and angle, and some
  ; points classified with this line
  let angle random 360
  let xr random-pxcor / 2
  let yr random-pycor / 2
  show angle
  create-data Data-Size [
    set size 1
    set shape "circle"
    setxy random-pxcor random-pycor
    set input (list xcor ycor)
    set output sign ((xcor - xr) * sin angle + (ycor - yr) * cos angle)
    set color ifelse-value (output = -1) [ red ] [ blue ]
  ]
end

; One step from algorithm:
;   take one random point of the data, and learn from it
to go
  let one-point one-of data
  learn-from one-point
end

; Learn procedure for the perceptron when looking at point P
to learn-from [P]
  ; i : the input of P
  let i fput 1 ([input] of P)
  ; y : the real ouput of P
  let y [output] of P
  ; w : the weight of the perceptron
  let w [weight] of perc
  ; If P is not correctly classified for the perceptron
  if sign (prod-esc w i) != y [
    ;wait .01
    ;ask d-vec [set color yellow]
    ask perc [
      ; Update the weight of the perceptron: w(t+1) = w(t) + y X
      set weight (map [[x1 x2] -> x1 + y * x2] weight i)
      let w0 item 0 weight
      let w1 item 1 weight
      let w2 item 2 weight
      ; orient the agent to visualize the weight
      set heading 90 + atan w1 w2
      ; locate the agent to visualize the weight
      ; it's a carefully block because maybe it reports some error
      carefully
      [
        let a (- w0) / w1
        let b (- w0) / w2
        ifelse abs a > max-pxcor [setxy 0 b] [setxy a 0]
        ; if it changes, update the weight vector
        ask w-vec [
          let n (sqrt (w1 ^ 2 + w2 ^ 2)) * 2 / max-pxcor
          setxy w1 / n w2 / n
        ]
      ]
      [
        ; if any error is found, we don't change it... maybe the next loop
      ]
    ]
  ]
end

; Auxiliary reports:

; sign report
to-report sign [x]
  report ifelse-value (x >= 0) [1][-1]
end

; Escalar Product report
to-report prod-esc [v1 v2]
  report sum (map [[x1 x2] -> x1 * x2] v1 v2)
end

; Some noise function (simply move randomly the points)
to noise
  ask data [
    rt random 360
    fd .01
    set input (list xcor ycor)
  ]
end

; Report to show the weight vector
to-report show-perceptron
  let w0 precision (item 0 [weight] of perc) 2
  let w1 precision (item 1 [weight] of perc) 2
  let w2 precision (item 2 [weight] of perc)2
  report (word "(" w0 ", " w1 ", " w2 ")")
end
@#$#@#$#@
GRAPHICS-WINDOW
175
10
546
382
-1
-1
3.6
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
15
40
100
73
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

BUTTON
15
75
170
108
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
110
170
155
Learned Perceptron
show-perceptron
4
1
11

BUTTON
105
40
168
73
NIL
noise
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
160
170
205
Learned Angle
[heading] of perc - 90
2
1
11

SLIDER
15
5
170
38
Data-Size
Data-Size
0
300
99.0
1
1
NIL
HORIZONTAL

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

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cruz
false
1
Line -7500403 false 150 0 150 300
Line -7500403 false 0 150 315 150

dot
false
0
Circle -7500403 true true 90 90 120

perceptron
true
0
Rectangle -2674135 true false 150 0 300 300
Rectangle -13345367 true false 0 0 150 300
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
Line -7500403 true 150 150 90 225
Line -7500403 true 150 150 210 225
@#$#@#$#@
1
@#$#@#$#@
