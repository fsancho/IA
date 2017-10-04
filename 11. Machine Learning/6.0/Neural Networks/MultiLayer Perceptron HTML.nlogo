globals [
  data-list    ; List of pairs [Input Output] to train the network
  inputs       ; List with the binary inputs in the training
  outputs      ; List with the binary output in the training
  epoch-error  ; error in every epoch during training
]

breed [bias-neurons bias-neuron]
bias-neurons-own [activation grad]

breed [input-neurons input-neuron]
input-neurons-own [activation grad]

breed [output-neurons output-neuron]
output-neurons-own [activation grad]

breed [hidden-neurons hidden-neuron]
hidden-neurons-own [activation grad]

links-own [weight]

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
  ask patch  3 10 [ set plabel-color 32 set plabel "Hidden Layer"]
  ask patch  8 10 [ set plabel-color 32 set plabel "Output"]

  ; Building the network
  setup-neurons
  setup-links

  ; Recolor of neurons and links
  recolor

  ; Initializing global variables

  set epoch-error 0
  set data-list []
  set inputs []
  set outputs []

  create-samples

  reset-ticks
end

to setup-neurons
  set-default-shape input-neurons "square"
  set-default-shape output-neurons "neuron-node"
  set-default-shape hidden-neurons "hidden-neuron"
  set-default-shape bias-neurons "bias-node"

  ; Create Input neurons
  repeat Neurons-Input-Layer [
    create-input-neurons 1 [
      set size min (list (10 / Neurons-Input-Layer) 1)
      setxy -6 (-19 / Neurons-Input-Layer * ( who - (Neurons-Input-Layer / 2) + 0.5))
      set activation random-float 0.1]]

  ; Create Hidden neurons
  repeat Neurons-Hidden-Layer [
    create-hidden-neurons 1 [
      set size min (list (10 / Neurons-Hidden-Layer) 1)
      setxy 2 (-19 / Neurons-Hidden-Layer * ( who - Neurons-Input-Layer - (Neurons-Hidden-Layer / 2) + 0.5))
      set activation random-float 0.1 ]]

  ; Create Output neurons
  repeat Neurons-Output-Layer [
    create-output-neurons 1 [
      set size min (list (10 / Neurons-Output-Layer) 1)
      setxy 7 (-19 / Neurons-Output-Layer * ( who - Neurons-Input-Layer - Neurons-Hidden-Layer - (Neurons-Output-Layer / 2) + 0.5))
      set activation random-float 0.1]]

  ; Create Bias Neurons
  create-bias-neurons 1 [ setxy -1.5 9 ]
  ask bias-neurons [ set activation 1 ]

end

to setup-links
  connect input-neurons hidden-neurons
  connect hidden-neurons output-neurons
  connect bias-neurons hidden-neurons
  connect bias-neurons output-neurons

end

; Auxiliary procedure to totally connect two groups of neurons
to connect [neurons1 neurons2]
  ask neurons1 [
    create-links-to neurons2 [
      set weight random-float 0.2 - 0.1
    ]
  ]
end

to create-samples
  repeat num-samples [
    let inp n-values Neurons-input-layer [one-of [0 1]]
    let out (list evaluate Function inp)
    set inputs lput inp inputs
    set outputs lput out outputs
    set data-list lput (list inp out) data-list
  ]
end

to recolor
  ask turtles [
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

; Training Procedure: On only training step.
;   To be called from a Forever button, for example

to train
  set epoch-error 0
    ; For every trainig data
    foreach data-list [ ?1 ->

      ; Take the input and correct output
      set inputs first ?1
      set outputs last ?1

      ; Load input on input-neurons
      (foreach (sort input-neurons) inputs [ [??1 ??2] ->
        ask ??1 [set activation ??2] ])

      ; Forward Propagation of the signal
      Forward-Propagation

      ; Back Propagation from the output error
      Back-propagation
    ]
    plotxy ticks epoch-error ;plot the error
    tick
end


; Propagation Procedures

; Forward Propagation of the signal along the network
to Forward-Propagation
  ask hidden-neurons [ set activation compute-activation ]
  ask output-neurons [ set activation compute-activation ]
  recolor
end

to-report compute-activation
  report sigmoid sum [[activation] of end1 * weight] of my-in-links
end

; Sigmoid Function
to-report sigmoid [x]
  report 1 / (1 + e ^ (- x))
end

; Step Function
to-report step [x]
  ifelse x > 0.5
    [ report 1 ]
    [ report 0 ]
end

; Back Propagation from the output error
to Back-propagation
  let error-sample 0
  ; Compute error and gradient of every output neurons
  (foreach (sort output-neurons) outputs [ [?1 ?2] ->
    ask ?1 [ set grad activation * (1 - activation) * (?2 - activation) ]
    set error-sample error-sample + ( (?2 - [activation] of ?1) ^ 2 ) ])
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

; Test Procedures

; The input neurons are read and the signal propagated with the current weights

to-report  test
  let inp n-values Neurons-input-layer [one-of [0 1]]
  let out (list evaluate Function inp)
  set inputs inp
  active-inputs
  Forward-Propagation
  report (list out [activation] of output-neurons)
end

to-report prueba [n]
  let er 0
  repeat n [
    let t test
    set er er + ((first first t) - (first last t)) ^ 2
  ]
  report er / n
end

; Activate input neurons with read inputs
to active-inputs
(foreach inputs (sort input-neurons )
  [ [?1 ?2] -> ask ?2 [set activation ?1] ])
  recolor
end


; Test Functions

to-report evaluate [f x]
  if f = "Majority" [report Majority x]
  if f = "Even" [report Even x]
end

to-report Majority [x]
  let ones length filter [ ?1 -> ?1 = 1 ] x
  let ceros length filter [ ?1 -> ?1 = 0 ] x
  report ifelse-value (ones > ceros) [1] [0]
end

to-report Even [x]
  let ones length filter [ ?1 -> ?1 = 1 ] x
  report ifelse-value (ones mod 2 = 1) [1] [0]
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
15
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
1
1
1
Epochs
30.0

BUTTON
15
235
80
268
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
115
215
148
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
270
215
440
Error
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

BUTTON
150
235
215
268
Train
train
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
145
485
215
518
One Test
show test
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
45
215
78
Neurons-Hidden-Layer
Neurons-Hidden-Layer
1
20
4.0
1
1
NIL
HORIZONTAL

CHOOSER
15
185
215
230
Function
Function
"Majority" "Even"
0

SLIDER
15
150
215
183
Num-samples
Num-samples
0
1000
310.0
10
1
NIL
HORIZONTAL

SLIDER
15
10
215
43
Neurons-Input-Layer
Neurons-Input-Layer
1
20
9.0
1
1
NIL
HORIZONTAL

MONITOR
40
440
190
485
NIL
epoch-error
17
1
11

SLIDER
15
80
215
113
Neurons-Output-Layer
Neurons-Output-Layer
1
20
1.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bias-node
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240
Circle -16777216 true false 90 120 120
Circle -7500403 true true 105 135 90
Polygon -16777216 true false 90 60 120 60 135 60 135 225 150 225 150 240 105 240 105 225 120 225 120 75 105 75 120 60
Rectangle -7500403 true true 90 120 120 225

hidden-neuron
false
1
Circle -16777216 true false 0 0 300
Circle -2674135 true true 15 15 270
Polygon -16777216 true false 135 75 60 75 120 150 60 225 135 225 135 210 135 195 120 210 90 210 135 150 90 90 120 90 135 105 135 90
Polygon -16777216 true false 255 75 210 75 180 210 150 210 150 225 195 225 225 90 240 90 255 90

neuron-node
false
1
Circle -16777216 true false 0 0 300
Circle -2674135 true true 15 15 270
Polygon -16777216 true false 195 75 90 75 150 150 90 225 195 225 195 210 195 195 180 210 120 210 165 150 120 90 180 90 195 105 195 75

square
false
0
Rectangle -16777216 true false 0 0 300 300
Rectangle -7500403 true true 15 15 285 285
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
