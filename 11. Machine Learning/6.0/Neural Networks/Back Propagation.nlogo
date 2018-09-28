globals [
  data-list    ; List of pairs [Input Output] to train the network
  inputs       ; List with the binary inputs in the training
  outputs      ; List with the binary output in the training
  epoch-error  ; error in every epoch during training
  data-counter ; stores the number of samples to be used in training
  drawer       ; auxiliary turtle to draw the patterns to be recognized
]

links-own [weight]


breed [input-neurons input-neuron]
input-neurons-own [activation grad p2]
breed [output-neurons output-neuron]
output-neurons-own [activation grad p2]
breed [hidden-neurons hidden-neuron]
hidden-neurons-own [activation grad p2]


;;;
;;; Setup Procedure
;;;

to setup
  clear-all
  ; Building the Front Panel
  ask patches [ set pcolor 39 ]
  ask patches with [pxcor > -2] [set pcolor 38]
  ask patches with [pxcor > 4] [set pcolor 37]

  ask patch -6 10 [ set plabel-color 32 set plabel "Input"]
  ask patch  2 10 [ set plabel-color 32 set plabel "Hidden Layer"]
  ask patch  8 10 [ set plabel-color 32 set plabel "Output"]

  ; Building the network
  setup-neurons
  setup-links

  ; Recolor of neurons and links
  recolor

  ; Initializing global variables

  set epoch-error 0
  set data-counter 0
  set data-list []

  ; Building the drawer turtle
  crt 1 [
    set drawer self
    set size (1 / 8)
    set shape "drawer"
    set color 32
    ]
  reset-ticks
end

to setup-neurons
  set-default-shape input-neurons "square"
  set-default-shape output-neurons "neuron-node"
  set-default-shape hidden-neurons "neuron-node"

  ; Create Input neurons. A 6x8 Matrix
  foreach sort patches with [pxcor >= -9 and pxcor <= -4 and pycor >= -3 and pycor <= 4]
  [ ?1 -> ask ?1 [
      sprout-input-neurons 1 [
        set activation random-float 0.1]] ]

  ; Create Hidden neurons
  foreach (n-values Neurons-Hidden-Layer [ ?1 -> ?1 ]) [ ?1 ->
    create-hidden-neurons 1 [
      setxy 2 (- int (neurons-Hidden-Layer / 2) + 1 + ?1)
      set activation random-float 0.1 ] ]

  ; Create Output neurons
  foreach (reverse n-values 10 [ ?1 -> ?1 ]) [ ?1 ->
    ask patch 8 (- 4 + ?1) [set pcolor (5 + ?1 / 2)]
    create-output-neurons 1 [
      setxy 7 (- 4 + ?1)
      set activation random-float 0.1] ]
end

to setup-links
  conect input-neurons hidden-neurons
  conect hidden-neurons output-neurons
end

to conect [neurons1 neurons2]
  ask neurons1 [
    create-links-to neurons2 [
      set weight random-float 0.2 - 0.1
    ]
  ]
end

to recolor
  ask turtles with [self != drawer][
    set color item (step activation) [white yellow]
  ]
  let MaxP max [abs weight] of links
  ask links [
    set thickness 0.05 * abs weight
    ifelse weight > 0
      [ set color lput (255 * abs weight / MaxP) [0 0 255]]
      [ set color lput (255 * abs weight / MaxP) [255 0 0]]
  ]
end

;;;
;;; Training Procedur
;;;

to train
  set epoch-error 0
  ask links [set weight random-float 0.2 - 0.1]
  ; Repeat the Number of iterations
  repeat Number-of-epochs [
    ; For every trainig data
    foreach (shuffle data-list) [ datum ->

      ; Take the input and correct output
      set inputs first datum
      set outputs last datum

      ; Load input on input-neurons
      (foreach (sort input-neurons) inputs [ [neur input] ->
        ask neur [set activation input] ])

      ; Forward Propagation of the signal
      Forward-Propagation

      ; Back Propagation from the output error
      back-propagation
    ]
    plotxy ticks epoch-error ;;plot the error
    set epoch-error (epoch-error / Number-of-epochs)
    tick
  ]
end


;;;
;;; Propagation Procedures
;;;

;; Forward Propagation of the signal along the network
to Forward-Propagation
  ask hidden-neurons [ set activation compute-activation ]
  ask output-neurons [ set activation compute-activation ]
  recolor
end

to-report compute-activation
  report sigmoide sum [[activation] of end1 * weight] of my-in-links
end

;; Sigmoid Function
to-report sigmoide [x]
  report 1 / (1 + e ^ (- x))
end

;; Step Function
to-report step [x]
  ifelse x > 0.5
    [ report 1 ]
    [ report 0 ]
end

;; Back Propagation from the output error
to back-propagation
  let error-sample 0
  ; Compute error and gradient of every output neurons
  (foreach (sort output-neurons) outputs [
    [neur ouput] ->
    ask neur [ set grad activation * (1 - activation) * (ouput - activation) ]
    set error-sample error-sample + ( (ouput - [activation] of neur) ^ 2 )
  ])
  ; Average error of the output neurons in this epoch
  set epoch-error epoch-error + (error-sample / count output-neurons)
  ; Compute gradient of hidden layer neurons
  ask hidden-neurons [
    set grad activation * (1 - activation) * sum [weight * [grad] of end2] of my-out-links
  ]
  ; Update link weights
  ask links [
    set weight weight + Learning-rate * [grad] of end2 * [activation] of end1
  ]
  set epoch-error epoch-error / 2
end


;;
;; Input Procedures
;;

;; Use mouse to activate input neurons (draw input sample)
to Draw
  if mouse-down?
    [
      let selection input-neurons with [distancexy mouse-xcor mouse-ycor < .5]
      if any? selection [
        ask one-of selection [
          set color black
          ;ifelse color = black [set color white][set color black]
         ]
        wait .1]
    ]
end

;; Procedure to store the input and correct output (a consecutive activated output neuron)
to store-input
  ; Take the pattern from input neurons
  let pattern map [ x -> [color] of x ] (sort input-neurons)
  ; Get the binary input from pattern
  set inputs map [ x -> ifelse-value (x = black) [1] [0] ] pattern
  if length data-list < 10 [
    ; Asignamos la salida correspondiente
    assign-output
    ; Almacenamos los datos de entrenamiento
    store-data-list
    draw-datum inputs 7.7 (5.4 - data-counter)
    set data-counter data-counter + 1
  ]
  ;limpia-inputs
end

;; Assign outputs to 10000000 01000000 ...
to assign-output
  set outputs (n-values 10 [0])
  set outputs replace-item data-counter outputs 1
end

;; Store the pair [inputs outputs] in training data
to store-data-list
  set data-list (lput (list inputs outputs) data-list)
end

;; Draw the read pattern together the corresponding output neuron
to draw-datum [i x y]
  ask drawer [
    setxy x y
    while [not empty? i][
      let line (sublist i 0 6)
      foreach line [ ?1 ->
        if ?1 = 1 [stamp]
        set xcor xcor + 1 / 9
      ]
      setxy x (ycor - 1 / 9)
      set i sublist i 6 (length i)
    ]
  ]
end

to clean-input
  ask input-neurons [set color white]
end

to load [f]
  setup
  file-open f
  set data-list read-from-string file-read-line
  file-close-all
  set data-counter 0
  foreach data-list [ ?1 ->
    set inputs first ?1
    draw-datum inputs 7.7 (5.4 - data-counter)
    set data-counter data-counter + 1
  ]
end

to save [f]
  file-open f
  file-write data-list
  file-close-all
end


;;;
;;; Test Procedures
;;;

;; The input neurons are read and the signal propagated with the current weights

to test
  let pattern map [ x -> [color] of x ] (sort input-neurons)
  set inputs map [ x -> ifelse-value (x = black) [1] [0] ] pattern
  active-inputs
  Forward-Propagation
end

; Activate input neurons with read inpiuts
to active-inputs
(foreach (sort input-neurons) inputs
  [ [neur input] -> ask neur [set activation input] ])
  recolor
end

; Recolor neurons using activation value in a continuous way
to recolor-c
  ask (turtle-set hidden-neurons output-neurons) [
    set color scale-color yellow activation 0 .5
  ]
end

;;
;; Procedures to compute the inverse, that is, the activation that an
;;  input neuron must have to be useful for a specific output (after
;;  using "Invert" one of th output neurons must be pressed)
;;

; This procedure makes something like a back-propagation from the output neuron
;; n to the input neurons
to inverse-output [n]
  ask n [
    ; Compute the max and min limits to scale colors to represent
    let Pmax max [weight] of my-in-links
    let Pmin min [weight] of my-in-links
    let pm2 max (list pmax (abs pmin))
    ask my-in-links [
      let p weight
      ask end1 [
        set p2 p
        ifelse p2 > 0
          [set color scale-color blue p2 -1 (Pmax + 1)]
          [set color scale-color red p2 (Pmin - 1) 1]
        set color lput (abs p2 * 255 / Pm2) extract-rgb color
      ]
    ]
  ]
  ask input-neurons [
    set p2 sum [weight * [p2] of end2] of my-out-links
    set p2 p2 / neurons-Hidden-Layer
    ifelse p2 > 0 [set color scale-color blue p2 -1 2] [set color scale-color red p2 -3 0 ]
  ]
end

; Mouse procedure to select the hidden/output neuron to invert
to invert
  if mouse-down?
  [
    let selection output-neurons with [distancexy mouse-xcor mouse-ycor < .5]
    if any? selection [
      inverse-output one-of selection
      wait .1]
    set selection hidden-neurons with [distancexy mouse-xcor mouse-ycor < .5]
    if any? selection [
      inverse-hidden one-of selection
      wait .1]
  ]
end

; This procedure makes something like a back-propagation from the hidden neuron
;; n to the input neurons, and a propagation to the ouput neurons
to inverse-hidden [n]
  ask n [
    ask my-in-links [
      let p weight
      ask end1 [
        set p2 p
        ifelse p2 > 0 [set color scale-color blue p2 -1 2] [set color scale-color red p2 -3 0 ]
      ]
    ]
    ask my-out-links [
      let p weight
      ask end2 [
        set p2 p
        ifelse p2 > 0 [set color scale-color blue p2 -1 2] [set color scale-color red p2 -3 0 ]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
225
10
708
494
-1
-1
22.62
1
10
1
1
1
0
0
0
1
-10
10
-10
10
0
0
1
ticks
30.0

BUTTON
15
110
215
143
setup
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

SLIDER
15
40
215
73
Learning-rate
Learning-rate
0.0
1.0
0.2
1.0E-4
1
NIL
HORIZONTAL

PLOT
15
180
215
330
Error vs. Epochs
Epochs
Error
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
15
75
214
108
Number-of-epochs
Number-of-epochs
0
2000.0
1000.0
100
1
NIL
HORIZONTAL

BUTTON
150
145
213
178
Train
train
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
715
80
780
113
Classify
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

BUTTON
715
10
780
43
NIL
Draw
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
715
45
780
78
Store
store-input
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
785
10
848
43
Clean
clean-input
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
145
75
178
Load
load user-file
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
80
145
145
178
Save
save user-new-file
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
16
6
215
39
Neurons-Hidden-Layer
Neurons-Hidden-Layer
1
20
10.0
1
1
NIL
HORIZONTAL

BUTTON
785
80
860
113
See Weights
recolor-c
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
715
130
805
163
Analyze
Invert
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
720
165
870
210
With this button pressed you can click on any hidden/output neuron to analyze it
11
0.0
1

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bias-node
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 120 60 150 60 165 60 165 225 180 225 180 240 135 240 135 225 150 225 150 75 135 75 150 60

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

drawer
false
0
Rectangle -7500403 true true 0 0 300 300

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0

neuron-node
false
1
Circle -7500403 true false 0 0 300
Circle -2674135 true true 30 30 240
Polygon -7500403 true false 195 75 90 75 150 150 90 225 195 225 195 210 195 195 180 210 120 210 165 150 120 90 180 90 195 105 195 75

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -6459832 true false 0 0 300 300
Rectangle -7500403 true true 15 15 285 285

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
setup repeat 100 [ train ]
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
@#$#@#$#@
1
@#$#@#$#@
