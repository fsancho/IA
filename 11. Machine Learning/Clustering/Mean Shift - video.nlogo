extensions [vid]
globals [_recording-save-file-name]
;See https://saravananthirumuruganathan.wordpress.com/2010/04/01/introduction-to-mean-shift-algorithm/

; We will make uso of three different breed turtles to our implementation
; Original will contain the data to be clustered
breed [originals original]
; Climbers will depart from original data and will use a Gradient Ascend Algorithm to
; reach the maximums of the Gaussian Field to determine the different clusters
breed [climbers climber]
; Contours will plot the countour of the Gaussian Field (level curves)
breed [contours contour]

climbers-own [
  origin    ; The original data point it start from
  in-move?  ; boolean to indicate if the climber has reached its maximum
]

contours-own [
  turn      ; Decides if the level curve will be travelled clockwise or anticlockwise
  travelled ; Amount of steps this countour has made in the current level
]

patches-own [
  visits    ; How mnay contours have visited this patch (use for redistributing the
            ; contour agents)
]

; The setup procedure to create artificial data
to setup
  ca
  ; White background and initialize patches (for contour purposes)
  ask patches [
    set pcolor white
    set visits 0
  ]
  ; Create N originals randomly distributed in the world
  ;   if grouped? they will be grouped in bags
  ifelse grouped?
  [setup-originals2 N]
  [setup-originals N]

  ; Create one climber per original datum
  ask originals [
    hatch-climbers 1 [
      set origin myself
      set color [0 0 255 50]
      set shape "dot"
      set in-move? true
      pd
    ]
  ]
  ; Fill patches with colors accoring to gaussian function
  if fill-colors? [fill-patches orange]

  ; Create 10 contours and restart their positions
  create-contours 10 [
    set color [0 0 0 10]
    restart-contour
  ]
end

; Create the original data in a randomly way
to setup-originals [num]
  create-originals num [
    setxy random-xcor random-ycor
    set color red
    set shape "circle"
]
end

; Create the original data grouped in a random set of bags. The number of
; bags will depend on dispersion value
to setup-originals2 [num]
  let bags random dispersion
  create-originals bags [
    setxy random-xcor random-ycor
    set color red
    set shape "circle"]
  repeat num - bags
  [
    ask one-of originals
    [hatch-originals 1 [set heading random 360 fd random-float 5]]]
end

; Fill the colors of patches with a scale according to gaussian distribution
to fill-patches [c]
  ;let MaxG max [gaussian (pxcor / max-pxcor) (pycor / max-pycor)] of patches
  let MaxG ifelse-value (grouped?) [3][1]
  ask patches [set pcolor scale-color c
                            (gaussian (pxcor / max-pxcor) (pycor / max-pycor))
                            0 MaxG]
end

; Report de Gaussian distribution from the original data points
to-report gaussian [x y]
  let coord (list x y)
  let h2 (h ^ 2)               ; h2 = h ^ 2, the bandwith parameter
  let S 0                      ; Will store the new sum vector
  ask originals [
    let d d2 coor coord        ; Distance from current position to the data point
    let ex exp (-1 * d / h2)   ; Exponential factor of the gradient
    set S S + ex               ; Accumulate the vectors
  ]
  set S S / (N * h2)    ; Normalize the sum
  report S              ; and report it
end



; Reset the climbers to their original associated data (and clear the drawing layer)
to reset
  ask climbers [
    pu
    move-to origin
    set in-move? true
    pd
  ]
  if fill-colors? [ fill-patches orange ]
  cd
end

; Cluster process (to be used inside a loop or in a forever button)
to cluster
  ; If all climbers have reached their maximums: stop
  if (not any? climbers with [in-move?]) [stop]
  ; If not, work with the in-move ones
  ask climbers with [in-move?][
    ; Calculate the new position of this climber by using the Gradient
    let S Grad-position
    ; If it almost hasn't moved
    if (d2 S coor) < 10 ^ -7 [
      set in-move? false ; Change its state
      ]
    ; Move to the new position. We must recover the "world" coordinates, as the
    ; implementation works in [-1,1]x[-1,1] area
    setxy (max-pxcor * first S) (max-pycor * last S)
  ]
end

; PLot Contour process (to be used inside a loop or in a forever button)
to plot-contour
  ; move contoours agents, and restart any of them trying to move out of the world
  ask contours [
    fd-contour
    if in-limits?[
      restart-contour
    ]
  ]
  ; Next lines try to provide a uniform distributed level curves, scaping from the
  ; atractor effects of some boundary curves:

  ; Take the contour with longer trip in its current level curve, and if it is over
  ; 1000 steps, restart it
  ask max-one-of contours [travelled] [
    if travelled > 1000 [ restart-contour ]
  ]
  ; Take patches with too many visits and restart contours in them
  ;ask max-n-of 10 patches [visits]
  ;[
  ;  ask contours-here [ restart-contour]
  ;]
  ; We have the option to create a contour from the mouse position
  if mouse-down? [
    ask n-of 2 contours [
      pu
      setxy mouse-xcor mouse-ycor
      set travelled 0
      pd
    ]
    wait .5
  ]
end

; Forward movement for contours
to fd-contour
  ; Compute the new position by the Gradient Ascend Algorithm
  let S Grad-position
  ; Face the contour agent to it
  facexy (max-pxcor * first S) (max-pycor * last S)
  ; And turn 90º, since the level curve is orthogonal to the gradient direction
  rt turn * 90
  ; Advance a little bit
  fd .5
  ; Increment the visits of the patch here
  set visits visits + 1
  ; Increment the travelled coounter for this contour agent
  set travelled travelled + 1
  ;if visits > 50 [restart-contour]
  ;set color lput 20
  ;          extract-rgb scale-color white
  ;                            (gaussian (xcor / max-pxcor) (ycor / max-pycor))
  ;                            2 -1
end

; Restart one contour agent
to restart-contour
  ; Pen up, because we will move it and don't want to leave the trace
  pu
  ; Move the contour to some patch with lwer visits (less curves crossing it)
  move-to min-one-of patches [visits]
  ; Move randomly inside the patch
  setxy (xcor + random-float 1 - .5) (ycor + random-float 1 - .5)
  ; Pen down
  pd
  ; Restart the travelled counter, since it is in a new level curve
  set travelled 0
  ; Decide the type of turn
  set turn one-of [-1 1]
  ;set color (lput 20 n-values 3 [random 256])
  ;set color lput 20
  ;          extract-rgb scale-color white
  ;                            (gaussian (xcor / max-pxcor) (ycor / max-pycor))
  ;                            1 0

end

; Report to know if an agent is in the limits of the world
to-report in-limits?
  report (abs xcor) > max-pxcor or (abs ycor) > max-pycor
end

; Report to compute the New position from the current one by using the Gradient
to-report Grad-position
  let h2 h ^ 2                     ; h2 = h ^ 2, the bandwith parameter
  let normalizer 0                 ; Will store the normalizer factor for the sum
  let S [0 0]                      ; Will store the new sum vector
  ask originals [
    let d Pd2 self myself          ; Distance from current position to the data point
    let ex exp (-1 * d / h2)       ; Exponential factor of the gradient
    set normalizer normalizer + ex ; Accumulate the normalizer
    let x V* ex coor               ; Weighted vector from current data point
    set S V+ S x                   ; Accumulate the vectors
  ]
  set S V* (1 / normalizer) S      ; Normalize the sum
  report S                         ; and report it
end

;---------------------------------------------
; Auxiliary report for vector operations
;---------------------------------------------

; Sum of two vectors
to-report V+ [v1 v2]
  report (map + v1 v2)
end

; Product an scalar by a vector
to-report V* [k v]
  report map [ ?1 -> k * ?1 ] v
end

; Distance sqare between to vectors
to-report d2 [v1 v2]
  report sum (map [ [?1 ?2] -> (?1 - ?2) ^ 2 ] v1 v2)
end

; Version of D2 for turtles (using their coordinates)
to-report Pd2 [P1 P2]
  report d2 [coor] of P1 [coor] of P2
end

; Report the list of real coordinates of a turtle (in [-1,1]x[-1,1])
to-report coor
  report (list (xcor / max-pxcor) (ycor / max-pycor))
end

;to-report Vsuma [lv]
;  report reduce V+ lv
;end

;to-report P+ [P1 P2]
;  report V+ [coor] of P1 [coor] of P2
;end

;to-report Psuma [Ps]
;  report Vsuma [coor] of Ps
;end

;to-report P* [k P]
;  report V* k [coor] of P
;end

; Creation of a video while varying the h parameter

to experimento
  set h 1
  set _recording-save-file-name "Kernelcontour2.mov"
  vid:start-recorder
  while [h > 0][
    reset
    repeat 3000 [plot-contour]
    vid:record-view
    set h h - .01
  ]
  vid:save-recording _recording-save-file-name
end
@#$#@#$#@
GRAPHICS-WINDOW
194
10
604
421
-1
-1
2.0
1
10
1
1
1
0
0
0
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
110
10
190
115
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
10
155
100
188
Clusters
cluster
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
190
190
223
h
h
0
1
0.19
.01
1
NIL
HORIZONTAL

BUTTON
110
120
190
153
NIL
reset
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
105
155
190
188
Contour
plot-contour
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
10
105
43
N
N
0
1000
100.0
10
1
NIL
HORIZONTAL

SWITCH
10
120
105
153
Fill-colors?
Fill-colors?
0
1
-1000

SWITCH
10
45
105
78
grouped?
grouped?
1
1
-1000

SLIDER
10
80
105
113
dispersion
dispersion
0
100
50.0
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
1
@#$#@#$#@
