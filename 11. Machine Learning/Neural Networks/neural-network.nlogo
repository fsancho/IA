; N-Layer Neural Network matricial implementation in NetLogo 6 by Fernando Sancho
;   (over a work of Stephen Larroque)

extensions [matrix]



;==============================================================
;=================       EXAMPLE USAGE        =================
;==============================================================

to-report random-matrix
  report matrix:map [random 10] matrix:make-constant 3 4 0
end

to test3
  let A random-matrix
  print matrix:pretty-print-text A
  print matrix:pretty-print-text matrix:bfc A
  print matrix:pretty-print-text matrix:from-row-list (list matrix:get-row A 1)
end

; Real example for learning a neural network, either in debug mode (weights fixed and stochasticity removed) or not
to go-learn
  clear-all

  ;====== CONFIGURATION ======

  ; Parameters
  ;let neurons_per_layer (list 2 5 2) ; you can directly specify all the neurons if you want
  let Architecture []
  let lambda nnlambda ; to reduce overfitting, this is the cost of parameters complexity
  let epsilon nnepsilon ; gradient step, use smaller values if using stochastic gradient descent. May need a bit lower epsilon than in the Octave code because here the precision is more by default
  let nIterMax 5000
  let learnPart 0.6 ; 0.6 = 60% points will be attributed to learning and the rest to the test set, 0 to disable
  let checkGrad false ; Check the gradient at the end?

  ; Toy datasets
  let X []
  let y []
  ;1- Simple factor (epsi = 0.1 stoch)
  if chooseExample = "Simple factor" [
    set X matrix:from-column-list [[1 2 3 4 5]]
    set y matrix:from-column-list [[2 4 6 8 10]]
  ]
  ;2- Housing prices (epsi = 0.03 stoch)
  if chooseExample = "Housing prices" [
    set X matrix:from-column-list [[1 3 4 5 9]]
    set y matrix:from-column-list [[2 5.2 6.8 8.4 14.8]]
  ]
  ;3- Multivariate factor (epsi = 0.01 stoch)
  if chooseExample = "Multivariate factor" [
    set X matrix:from-row-list [[1 3] [2 4] [3 5] [4 6] [5 7]]
    set y matrix:from-row-list [[2 9] [4 12] [6 15] [8 18] [10 21]]
  ]
  ;4- Multivariate combination of features factor (epsi = 0.003 stoch and epsi = 0.01 batch)
  if chooseExample = "Multivariate combination of features" [
    set X matrix:from-row-list [[1 3] [2 4] [3 5] [4 6] [5 7]]
    set y matrix:from-row-list [[2 3] [4 8] [6 15] [8 24] [10 35]]
  ]

  ;====== PROGRAM ======

  ; If using GUI to define the network layout, we generate the variable here
  if empty? Architecture [
    let dim matrix:dimensions X
    let N (item 1 dim)
    let dimY matrix:dimensions Y
    let NY (item 1 dimY)
    set Architecture (sentence N (n-values hlayers [hneurons]) NY)
  ]

  let useCrossval false
  if learnPart > 0 and learnPart < 1 [
    set useCrossval true
  ]

  let init_Ws (ANN:InitializeWs Architecture)
  let Ws (matrix:copy-recursive init_Ws)

  ; Splitting dataset and then learning the neural network
  let Xtrain []
  let Ytrain []
  let Xtest []
  let Ytest []
  ifelse useCrossval [
    let onecross (crossval X y learnPart)
    set Xtrain (item 0 onecross)
    set Ytrain (item 1 onecross)
    set Xtest (item 2 onecross)
    set Ytest (item 3 onecross)
  ]
  ; No splitting
  [
    set Xtrain X
    set Ytrain y
    set Xtest []
    set Ytest []
  ]

  ; Train
  let Fit-Train (ANN:Train 3 Ws Architecture lambda Xtrain Ytrain Xtest Ytest epsilon nIterMax)

  set Ws (item 0 Fit-Train)
  let errtrain (item 1 Fit-Train)
  let errtest (item 2 Fit-Train)
  plot-learning-curve "Train" errtrain
  plot-learning-curve "Test" errtest


  ; Check on Train Data
  let check-Train (ANN:ForwardProp Ws Xtrain)
  let OTrain (item 0 check-Train)
  let Atrain (item 1 check-Train)

  let Otest []
  let Atest []
  if useCrossval [
    let check-Test (ANN:ForwardProp Ws Xtest)
    set Otest (item 0 check-Test)
    set Atest (item 1 check-Test)
  ]

  ; Cost
  let M (item 0 matrix:dimensions Xtrain)
  let Jtrain (ANN:ComputeError Ytrain Otrain Ws lambda)

  let Mtest 0
  let Jtest 0
  if useCrossval [
      set Mtest (item 0 matrix:dimensions Xtest)
      set Jtest (ANN:ComputeError Ytest Otest Ws lambda)
  ]


  ; Printing infos
  print "Xtrain:"
  print matrix:pretty-print-text Xtrain
  print "Ytrain:"
  print matrix:pretty-print-text Ytrain
  if useCrossval [
    print "Xtest:"
    print matrix:pretty-print-text Xtest
    print "Ytest:"
    print matrix:pretty-print-text Ytest
  ]

  print (word "Otrain:\n" matrix:pretty-print-text Otrain "\n")
  if useCrossval [
    print (word "Otest:\n" matrix:pretty-print-text Otest "\n")
  ]
  print (word "Train error:" Jtrain "\n")
  if useCrossval [
     print (word "Test error:" Jtest "\n")
  ]
  print "---------------------------------\n"
end


;==============================================================
;=================  NEURAL NETWORK FUNCTIONS  =================
;==============================================================

; Add a column of 1's at the beginning
to-report ANN:addBias [A]
  let dim matrix:dimensions A
  let N item 0 dim
  report matrix:prepend-column A (n-values N [1])
end

; Compute the sigmoid function: R -> R
to-report ANN:sigm [x]
  let ret 0
  carefully [
    set ret 1 / (1 + e ^ (- x)) ; use e ^ (-x) so as to show to user that some values are too big and may produce weird results in the learning
  ]
  [
    show (word "Number too big for NetLogo, produces infinity in sig_aux with e ^ (- x): -x = " (- x))
    set ret 1 / (1 + exp (- x)) ; prefer using (exp x) rather than (e ^ x) because the latter can produce an error (number is too big) while exp will produce Infinity without error
  ]
  report ret
end

; Compute the matricial sigmoid (element-wise)
to-report ANN:sigmoid [A]
  report matrix:map ANN:sigm A
end

; Compute the matricial sigmoid derivative (element-wise)
to-report ANN:sigmoid' [A]
  let sigA ANN:sigmoid A
  report matrix:times-element-wise sigA (1 matrix:- sigA)
end


; Initialize all the weights matrices
to-report ANN:InitializeWs [Architecture]
  let Ws (map [[i j] -> (ANN:RandInitializeW i j)] (bl Architecture) (bf Architecture))
  report Ws
end

; Rand initilization of one weight matrix
to-report ANN:RandInitializeW [L_in L_out]
  let W matrix:make-constant L_out (L_in + 1) 0
  let epsilon_init ((sqrt 6) / (sqrt (L_in + L_out))) ; or 0.12, both are magic values anyway, so you can change that to anything you want
  set W matrix:map [((random-float 1) * 2 * epsilon_init - epsilon_init)] W
  report W
end

to-report crossval [X y learnPart]
  let dim matrix:dimensions X
  let M item 0 dim
  let N item 1 dim

  ; Generate list of indexes and shuffle it
  let indlist range M
  let indrand (shuffle indlist)

  ; Get the index where we must split the two datasets
  let numlearn (round (learnPart * M)) ; Be careful with round: round a * b = (round a) * b != (round (a * b))

  let indrandlearn sort (sublist indrand 0 numlearn)
  let indrandtest sort (sublist indrand numlearn M)

  ; Split the dataset in two
  let Xlearn (matrix:somerows X indrandlearn)
  let Ylearn (matrix:somerows Y indrandlearn)
  let Xtest (matrix:somerows X indrandtest)
  let Ytest (matrix:somerows Y indrandtest)

  report (list Xlearn Ylearn Xtest Ytest)
end

to-report ANN:Train [MiniBatch Ws Architecture lambda Xtrain Ytrain Xtest Ytest  epsilon nIterMax]

  let dim matrix:dimensions Xtrain
  let M item 0 dim

  let Layers (length Architecture)

  let t 1
  let errtrain []
  let errtest []

  let temp []
  while [t < nIterMax] [
    ; == Preparing for stochastic gradient (pick only one example for each iteration instead of all examples at once)
    let samples n-of MiniBatch (range M)
    let XBatch select-samples samples Xtrain
    let YBatch select-samples samples Ytrain

    ; == Forward propagating + Computing cost
    ; = Learning dataset
    let forward-train (ANN:ForwardProp Ws XBatch)
    let Out (item 0 forward-train)
    let As (item 1 forward-train)
    let Zs (item 2 forward-train)


    ; == Train and Test error
    set errtrain lput (ANN:ComputeError YBatch Out Ws lambda) errtrain

    let forward-test (ANN:ForwardProp Ws Xtest)
    let Otest (item 0 forward-test)
    let Atest (item 1 forward-test)
    let Ztest (item 2 forward-test)

    set errtest lput (ANN:ComputeError Ytest Otest Ws lambda) errtest

    ; == Back propagating
    ; Computing gradient
    let Ws_grad (ANN:BackwardProp lambda Ws As Zs YBatch)
    ; Update Ws
    let epsi (epsilon / (1 + (t - 1) * nnDecay)) ; Implementing learning rate decay (aka gradient step decay) so that the network converges faster
    set Ws (map [[W W'] -> (W matrix:- (epsi matrix:* W'))] Ws (bl Ws_grad))

    ; Force refreshing of the plots
    display

    ; Increment t (iteration counter)
    set t (t + 1)
  ]
  report (list Ws errtrain errtest)
end

to-report select-samples [samples X]
  report matrix:from-row-list (map [i -> matrix:get-row X i] samples)
end

; Forward Propagation of ANN
to-report ANN:ForwardProp [Ws X]
  let Layers (length Ws) + 1
  let As (list ANN:addBias(X))
  let Zs [0]
  let Z 0
  foreach (range 1 Layers) [
    L ->
    let A last As
    let W (item (L - 1) Ws)
    set Z A matrix:* (matrix:transpose W)
    set Zs lput Z Zs
    set As lput (ANN:addBias (ANN:sigmoid Z)) As
  ]
  set As lput Z (bl As) ; Change the last activation for the same but without sigmoid
  let O Z
  report (list O As Zs)
end

to-report ANN:ComputeError [Y O Ws lambda]

  ; First, the Predictive error: (O - Y)^2
  if is-number? Y [ set Y matrix:from-row-list (list (list Y)) ] ; Convert to a matrix if it's only a number
  if is-number? O [ set O matrix:from-row-list (list (list O)) ] ; Convert to a matrix if it's only a number
  let Y-O (Y matrix:- O)
  let J1 sum matrix:to-list (matrix:times-element-wise Y-O Y-O) ; First we must sum over the features to compute some kind of euclidian distance,
                                                                   ; then we can sum over all examples errors
  let M item 0 matrix:dimensions Y
  set J1 (1 / (2 * M) * J1) ; scale cost relatively to the size of the dataset

  ; Second, the Regularization factor (if lambda > 0, then small values in Ws are choosen)
  let Ws_red map [th -> matrix:bfc th] Ws
  let sum_Ws sum (map [ th -> sum matrix:to-list (matrix:times-element-wise th th)] Ws_red)
  let J2 lambda / (2 * M) * sum_Ws

  ; Sum
  let J (J1 + J2)

  report J
end

to-report ANN:BackwardProp [lambda Ws As Zs Y]
  let Layers length As
  let M item 0 matrix:dimensions Y

  let deltas (n-values Layers [0])
  let O (item (Layers - 1) As)

  if is-number? Y [ set Y matrix:from-row-list (list (list Y)) ] ; Convert to a matrix if it's only a number

  ; == backpropagate delta values
  set deltas (replace-item (Layers - 1) deltas (O matrix:- Y))
  foreach (range (Layers - 2) 0 -1) [
    L ->
    let W_L item L Ws
    let Z_L item L Zs
    let delta_L+1 item (L + 1) deltas
    let delta_L (delta_L+1 matrix:* (matrix:bfc W_L))
    set delta_L (matrix:times-element-wise delta_L (ANN:sigmoid' Z_L))
    set deltas (replace-item L deltas delta_L)
  ]

  ; == Backpropagating error gradient (for the weights) from last layer towards first layer
  let Ws_grad (n-values Layers [0])
  foreach (range (Layers - 2) -1 -1) [
    L ->
    let A item L As
    let delta_L+1 item (L + 1) deltas
    let W_L_grad (matrix:times (1 / M) (matrix:transpose delta_L+1) A)
    set Ws_grad (replace-item L Ws_grad W_L_grad)
  ]

  ; == Regularize the gradient
  foreach (range (Layers - 2) -1 -1) [
    L ->
    let W_L_grad (item L Ws_grad)
    let Wn_L_grad matrix:bfc W_L_grad
    let W1_L_grad (matrix:get-column W_L_grad 0)
    let W_L (item L Ws)
    set W_L_grad Wn_L_grad matrix:+ ((lambda / M)  matrix:* (matrix:bfc W_L))
    set Ws_grad (replace-item L Ws_grad (matrix:prepend-column W_L_grad W1_L_grad))
  ]

  report Ws_grad
end

to plot-learning-curve [pen cost]
  set-current-plot "Learning curve"
  set-current-plot-pen pen
  foreach cost plot
;  plot cost
end

;==============================================================
;================= MATRIX AUXILIARY FUNCTIONS =================
;==============================================================

; row is a list
to-report matrix:prepend-row [X row]
  report matrix:from-row-list fput row (matrix:to-row-list X)
end

; column is a list
to-report matrix:prepend-column [X column]
  report matrix:from-column-list fput column (matrix:to-column-list X)
end

; Semi-vectorized procedure to sum a matrix over rows or columns
; If the matrix is not summable or there is only one element, it will return the same matrix
to-report matrix:sum [X columnsOrRows?] ; columnsOrRows? 2 = over columns
  if is-number? X [report X] ; if it's already a number, we've got nothing to do, just return it
  if is-list? X [report sum X] ; if it's a list we use the built-in function
  if columnsOrRows? = 2 [ report map sum matrix:to-column-list X ] ; Columns
  if columnsOrRows? = 1 [ report map sum matrix:to-row-list X ] ; Rows
end

; Semi-vectorized procedure to return the max value of a matrix over rows or columns
; If the matrix is not summable or there is only one element, it will return the same matrix
; NB: it's a copy-cat of matrix:sum
to-report matrix:max [X columnsOrRows?] ; columnsOrRows? 2 = over columns
  if is-number? X [report X] ; if it's already a number, we've got nothing to do, just return it
  if is-list? X [report max X] ; if it's a list we use the built-in function
  if columnsOrRows? = 2 [ report map max matrix:to-column-list X ] ; Columns
  if columnsOrRows? = 1 [ report map max matrix:to-row-list X ] ; Rows
end

; Semi-vectorized procedure to return the min value of a matrix over rows or columns
; If the matrix is not summable or there is only one element, it will return the same matrix
; NB: it's a copy-cat of matrix:sum
to-report matrix:min [X columnsOrRows?] ; columnsOrRows? 2 = over columns
  if is-number? X [report X] ; if it's already a number, we've got nothing to do, just return it
  if is-list? X [report min X] ; if it's a list we use the built-in function
  if columnsOrRows? = 2 [ report map min matrix:to-column-list X ] ; Columns
  if columnsOrRows? = 1 [ report map min matrix:to-row-list X ] ; Rows
end

; Deep recursive copy of a megamatrix (list of matrix)
to-report matrix:copy-recursive [megamatrix]
  ; Entry point: if it's a list, we will recursively copy everything inside (deep copy)
  ifelse is-list? megamatrix [
    let n (length megamatrix)
    let m2 (n-values n [0])

    let i 0
    while [i < n] [
      set m2 (replace-item i m2 (matrix:copy-recursive (item i megamatrix)))
      set i (i + 1)
    ]
    report m2
  ]
  ; Recursively called from here
  [
    ; If it's a number or string we just report it
    ifelse is-number? megamatrix or is-string? megamatrix [
      report  megamatrix
    ]
    ; Else if it's a matrix (we have no other way to check it but by default), then we make a copy and report it
    [
      report matrix:copy megamatrix
    ]
  ]
end

; Devuelve la misma matriz, pero eliminando la primera columna
to-report matrix:bfc [X]
  let dim matrix:dimensions X
  let N first dim
  let M last dim
  report matrix:submatrix X 0 1 N M
end

; Devuelve una matriz con una sola fila de i (pero es matriz)
to-report matrix:1row [X i]
  report matrix:from-row-list (list matrix:get-row X i)
end

to-report matrix:somerows [X indx]
  let Xlist map [i -> matrix:get-row X i] indx
  report matrix:from-row-list Xlist
end

to-report matrix:to-list [X]
  report reduce sentence matrix:to-row-list X
end
@#$#@#$#@
GRAPHICS-WINDOW
282
10
459
188
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-6
6
-6
6
0
0
1
ticks
30.0

BUTTON
4
115
80
148
Learn!
go-learn
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1
212
279
362
Learning curve
Iteration
Cost
0.0
10.0
0.0
0.0
true
true
"" ""
PENS
"train" 1.0 0 -14070903 true "" ""
"test" 1.0 0 -5298144 true "" ""

BUTTON
80
115
227
148
Learn debug (fixed params)
go-learn
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
3
10
227
55
chooseExample
chooseExample
"Simple factor" "Housing prices" "Multivariate factor" "Multivariate combination of features"
3

INPUTBOX
4
55
60
115
hneurons
5.0
1
0
Number

INPUTBOX
60
55
110
115
hlayers
1.0
1
0
Number

INPUTBOX
170
55
227
115
nnepsilon
0.05
1
0
Number

INPUTBOX
110
55
170
115
nnlambda
0.0
1
0
Number

INPUTBOX
227
56
280
116
nnDecay
0.01
1
0
Number

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

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
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
