globals [
  data-list    ; List of pairs [Input Output] to train the network
  inputs       ; List with the binary inputs in the training
  outputs      ; List with the binary output in the training
  epoch-error  ; error in every epoch during training
]

links-own [weight]


breed [input-neurons input-neuron]
input-neurons-own [activation grad]
breed [output-neurons output-neuron]
output-neurons-own [activation grad]
breed [hidden-neurons hidden-neuron]
hidden-neurons-own [activation grad]


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

  ; Create Input neurons.
  foreach (reverse n-values Neurons-Input-Layer [ ?1 -> ?1 ]) [
    create-input-neurons 1 [
      set size min (list (10 / Neurons-Input-Layer) 1)
      setxy -6 (19 / Neurons-Input-Layer * ( who - (Neurons-Input-Layer / 2) + 0.5))
      set activation random-float 0.1]]

  ; Create Hidden neurons
  foreach (n-values Neurons-Hidden-Layer [ ?1 -> ?1 ]) [
    create-hidden-neurons 1 [
      set size min (list (10 / Neurons-Hidden-Layer) 1)
      setxy 2 (19 / Neurons-Hidden-Layer * ( who - Neurons-Input-Layer - (Neurons-Hidden-Layer / 2) + 0.5))

;      setxy 2 (- int (neurons-Hidden-Layer / 2) + 1 + ?)
      set activation random-float 0.1 ]]

  ; Create Output neurons
  foreach (reverse n-values 1 [ ?1 -> ?1 ]) [
;    ask patch 8 (- 4 + ?) [set pcolor (5 + ? / 2)]
    create-output-neurons 1 [
      setxy 7 0
      set activation random-float 0.1]]
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

;;;
;;; Training Procedure
;;;

to train
  set epoch-error 0
  ;ask links [set weight random-float 0.2 - 0.1]
  ; Repeat the Number of iterations
  ;repeat Number-of-epochs [
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
    plotxy ticks epoch-error ;;plot the error
    ;set epoch-error (epoch-error / Number-of-epochs)
    tick
  ;]
end


;;;
;;; Propagation Procedures
;;;

;; Forward Propagation of the signal along the network
to Forward-Propagation
  ask hidden-neurons [ set activation sigmoid compute-activation ]
  ask output-neurons [ set activation compute-activation ]
  recolor
end

to-report compute-activation
  report sum [[activation] of end1 * weight] of my-in-links
end

;; Sigmoid Function
to-report sigmoid [x]
  report 1 / (1 + e ^ (- x))
end

;; Step Function
to-report step [x]
  ifelse x > 0.5
    [ report 1 ]
    [ report 0 ]
end

;; Back Propagation from the output error
to Back-propagation
  let error-sample 0
  ; Compute error and gradient of every output neurons
  (foreach (sort output-neurons) outputs [ [?1 ?2] ->
    ask ?1 [ set grad  (?2 - activation) ]
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

;;;
;;; Test Procedures
;;;

;; The input neurons are read and the signal propagated with the current weights

to-report  test
  let inp n-values Neurons-input-layer [one-of [0 1]]
  let out (list evaluate Function inp)
  set inputs inp;map [ifelse-value (? = black) [1] [0]] inp
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


; Activate input neurons with read inpiuts
to active-inputs
(foreach inputs (sort input-neurons )
  [ [?1 ?2] -> ask ?2 [set activation ?1] ])
  recolor
end

; Recolor neurons using activation value in a continuous way
to recolor-c
  ask (turtle-set hidden-neurons output-neurons) [
    set color scale-color yellow activation 0 .5
  ]
end

;; Functions

to-report evaluate [f x]
  report runresult (word f x)
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
0
0
1
Epochs
30.0

BUTTON
15
235
215
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
80
215
113
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
305
215
455
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
115
215
148
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
270
215
303
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
715
80
797
113
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

CHOOSER
15
185
215
230
Function
Function
"Majority" "Even"
1

SLIDER
15
150
215
183
Num-samples
Num-samples
0
1000
300.0
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
0
100
7.0
1
1
NIL
HORIZONTAL

MONITOR
40
455
190
500
NIL
epoch-error
17
1
11

@#$#@#$#@
## ¿QUÉ ES?

Es un modelo de reconocimiento de caracteres haciendo uso del método de propagación hacia atrás sobre una red neuronal. Esta versión se basa en la que viene en la librería por defecto de NetLogo, pero ampliando el tamaño de los caracteres a 6x8 pixels y permitiendo decidir el tamaño de la capa de nodos ocultos y ampliando la capa de salida a 10 nodos

## HOW IT WORKS

Initially the weights on the links of the networks are random. Inputs are entered into the input nodes by activating the 'draw' procedure and using the mouse to draw characters in the small frame to the left. After each character is drawn, pressing 'grab-pic' will use the drawing to activate the appropriate input nodes. The user can enter up to four different drawings, which will be then copied to the boxes below the net.
The values of the inputs times the random weights are added up to create the activation for the next node in the network.  The next node then sends out an activation along its output link.  These link weights and activations are summed up by the final output node which reports a value.  This activation is passed through a sigmoid function, which means that values near 0 are assigned values close to 0, and vice versa for 1.  The values increase nonlinearly between 0 and 1 with a sharp transition at 0.5. Light blue nodes have an activation below 0.5, yellow nodes an activation above 0.5.

To train the network the four inputs are presented to the network along with how the network should correctly classify the inputs. In this case, the outputs are simply the activation of the first, second, third and fourth output nodes for each drawing, in that order.  The network uses a back-propagation algorithm to pass error back from the output node and uses this error to update the weights along each link.

## HOW TO USE IT

To use it press SETUP to create the network and initialize the weights to small random numbers. This will also clear the small frame where the characters can be drawn.

Press DRAW to begin the drawing procedure and use the left button of the mouse to turn the white patches in the red frame to black. The drawings can be any pattern within the 3 X 5 rectangle.

Press GRAB-PIC to let the network know you are done with the character or CLEAR-FRAME to draw something else without recording it as an example. After pressing GRAB-PIC you will notice that the input nodes 'copy' the shape of your character through their activations. At the same time, the boxes below the net will save the characters you have already entered.

Once four characters have been added to the net, press TRAIN-ON-DATA and the net will present the four character inputs consecutively times the number of EXAMPLES-PER-EPOCH selected.

As in the original model, the larger the size of the link, the greater the weight it has.  If the link is red then its a positive weight.  If the link is blue then its a negative weight.

After the net is done training, you can press DRAW again to draw an input to test. Pres the TEST-NET button when you are done and see which output node is activated. The net should be able to recognize the original four characters by activating the appropriate output node (1 through 4, in the order they were entered).

LEARNING-RATE controls how much the neural network will learn from any one example.

## THINGS TO NOTICE

Now that the network has learned the examples, you can try to enter slightly different drawings. The net should be able to deal with 'noisy' inputs and yet recognize them as those that it was trained on. Adding or deleting 'pixels' from a test example will show you this is the case.

It is interesting to note that every time you run the net, even on the same test examples, the final result in terms of the weight and sign (positive or negative) of the links, more clearly visible in the links from the hidden nodes to the ouput nodes, is always slightly different.

## THINGS TO TRY

Manipulate the LEARNING-RATE parameter.  Can you speed up or slow down the training?

The more similar the original drawings are to one another, the more difficult it is to train the net to recognize them correctly. Try entering a letter P and a letter F and see which 'pixels' seem to cause the net to recognize the test examples as one or the other.


## EXTENDING THE MODEL

Back-propagation using gradient descent is considered somewhat unrealistic as a model of real neurons, because in the real neuronal system there is no way for the output node to pass its error back.  Can you implement another weight-update rule that is more valid?

## NETLOGO FEATURES

This model uses the link primitives.  It also makes heavy use of lists.

The extended character model also makes use of agentsets to define the frame and boxes.

## RELATED MODELS

The two models in the Neural Net models library. Particularly the Artificial Neural Net of which this is an extension.

## CREDITS AND REFERENCES
This model is part of NeuroLab, a set of neuroscience-related simulations in NetLogo written by
 Luis F. Schettino
Psychology Department
Lafayette College
Easton, PA, USA.
https://sites.lafayette.edu/schettil

From the original Artificial Neural Net Model:
The code for this model is inspired by the pseudo-code which can be found in Tom M. Mitchell's "Machine Learning" (1997).

Thanks to Craig Brozefsky for his work in improving this model.

To refer to this model in academic publications, please use:  Rand, W. and Wilensky, U. (2006).  NetLogo Artificial Neural Net model.  http://ccl.northwestern.edu/netlogo/models/ArtificialNeuralNet.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  Copyright 2006 Uri Wilensky.  All rights reserved.  See http://ccl.northwestern.edu/netlogo/models/ArtificialNeuralNet for terms of use.
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

hidden-neuron
false
1
Circle -7500403 true false 0 0 300
Circle -2674135 true true 15 15 270
Polygon -7500403 true false 135 75 60 75 120 150 60 225 135 225 135 210 135 195 120 210 90 210 135 150 90 90 120 90 135 105 135 90
Polygon -7500403 true false 255 75 210 75 180 210 150 210 150 225 195 225 225 90 240 90 255 90

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
