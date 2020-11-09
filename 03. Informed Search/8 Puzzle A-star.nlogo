;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls"]

;-----------------------------------------------------------------------------

breed [pieces piece]

pieces-own [number]

globals [Board]
;-------------------- Customizable Reports for A* -----------------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using lists [ "representation" cost f], where:
; - f allows to transform states (it is the transition function),
; - cost is the cost of applying the transition on a state,
; - and "representation" is a string to identify the rule.

; We represent a state as a shuffle of
; [ 0 1 2 ]
; [ 3 4 5 ]
; [ 6 7 8 ]

; [ 4 2 0 ]
; [ 1 3 5 ]
; [ 6 7 8 ]

; where 0 is the hole. And we will use lists [0 1 2 3 4 5 6 7 8]

; For a given position, h, (movements h) reports the list of possible swaps with
; the position h. For example:
; 0 can swap with 1 (right) and 3 (down)
; 1 can swap with 0 (left), 2 (right) and 4 (down)
; ... and so on
to-report movements [h]
  let movs  [[1 3] [0 2 4] [1 5] [0 4 6] [1 3 5 7] [2 4 8] [3 7] [6 4 8] [5 7]]
  report item h movs
end

; For a given state s, (swap i j s) returns a new state where tiles in
; positions i and j have been swapped
to-report swap [i j s]
  let old-i item i s
  let old-j item j s
  let s1 replace-item i s old-j
  let s2 replace-item j s1 old-i
  report s2
end

; children-states is a state report that returns the children for the current state.
; It will return a list of pairs [ns tran], where ns is the content of the children-state,
; and tran is the applicable transition to get it.
; It maps the applicable transitions on the current content, and then filters those
; states that are valid.

to-report AI:children-states
  let i (position 0 content)
  let indexes (movements i)
  report (map [ x -> (list (swap i x content) (list (word "T-" x) 1 "regla")) ] indexes)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report AI:final-state? [params]
  report ( content = params)
end

; Searcher report to compute the heuristic for this searcher.
; We use the sum of manhattan distances between the current 2D positions of every
; tile and the goal position of the same tile.

; d_e([x1,y1], [x2,y2]) = sqrt ((x1-x2)^2+ ((y1-y2)^2))
; d_m([x1,y1], [x2,y2])  = |x1-x2| + |y1-y2|


to-report AI:heuristic [#Goal]
  let pos [[0 0] [0 1] [0 2] [1 0] [1 1] [1 2] [2 0] [2 1] [2 2]]
  let c [content] of current-state
  report sum (map [ x -> manhattan-distance (item (position x  c   ) pos)
                                            (item (position x #Goal) pos) ]
                  (range 9))
  ;One other option is to count the misplaced tiles
  ;   report length filter [ x -> x = False] (map [[x y] -> x = y] c #Goal)
  ; but it is not so good as measuring the manhattan distance
end

to-report manhattan-distance [x y]
  report abs ((first x) - (first y)) + abs ((last x) - (last y))
end

to-report AI:equal? [a b]
  report a = b
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm
to New-Game
  ca
  create-board
  ; From a final position, we randomly move the hole some times
  set Board (range 9)
  repeat 60 [
    let i position 0 Board
    let j one-of movements i
    set Board swap i j Board
  ]
  View-Board
end

to Solve
  let path (A* Board (range 9) False False)
  let plan []
  ; if any, we highlight it
  if path != false [
    set plan (map [ s -> first [rule] of s ] path)
  ]
  foreach (map [x -> read-from-string last x] plan)
  [
    x -> move x
    wait .3
  ]
end


;-----------------------------------------------------------------------------
; Interface Procedures
;-----------------------------------------------------------------------------

to create-board
  (foreach (bl sort patches) (range 1 9)
  [
    [x y] ->
    ask x
    [
      sprout-pieces 1
      [
        set shape word "numero-" y
        set color item y base-colors
        __set-line-thickness 0.07
        set number y
      ]]])
end

to View-Board
  (foreach (sort patches) Board
  [
      [x y] -> if y != 0 [ask piece (y - 1) [move-to x]]
  ])
end

to shift [f dirx diry]
  ask f
  [
    repeat 100 [ setxy (xcor + dirx / 100) (ycor + diry / 100) wait .005]
  ]
end

to move [pos]
  let H one-of patches with [not any? pieces-here]
  let P one-of pieces-on (item pos (sort patches))
  shift P ([pxcor] of H - [xcor] of P) ([pycor] of H - [ycor] of P)
end
@#$#@#$#@
GRAPHICS-WINDOW
210
11
638
440
-1
-1
140.0
1
10
1
1
1
0
0
0
1
-1
1
-1
1
0
0
1
ticks
30.0

BUTTON
14
10
106
43
NIL
New-Game
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
112
10
175
43
NIL
Solve
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
## QUÉ ES

Un modelo base para el 8Puzzle sobre el que construir diversos resolvedores automáticos.
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

numero-0
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150
Line -1 false 105 150 90 165
Line -1 false 90 165 90 240

numero-1
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 105 90 150 45
Line -1 false 150 45 150 240
Line -1 false 195 255 165 255
Line -1 false 165 255 150 240
Line -1 false 135 255 150 240
Line -1 false 105 255 135 255

numero-2
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 105 150
Line -1 false 105 150 90 165
Line -1 false 90 165 90 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240

numero-3
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240

numero-4
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 255
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150

numero-5
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150

numero-6
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150
Line -1 false 105 150 90 165
Line -1 false 90 165 90 240

numero-7
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 210 255 210 240

numero-8
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150
Line -1 false 105 150 90 165
Line -1 false 90 165 90 240

numero-9
false
0
Rectangle -7500403 true true 15 15 285 285
Line -1 false 90 60 105 45
Line -1 false 105 45 195 45
Line -1 false 195 45 210 60
Line -1 false 210 60 210 135
Line -1 false 210 135 195 150
Line -1 false 195 150 105 150
Line -1 false 195 150 210 165
Line -1 false 210 165 210 240
Line -1 false 90 240 105 255
Line -1 false 105 255 195 255
Line -1 false 195 255 210 240
Line -1 false 90 60 90 135
Line -1 false 90 135 105 150

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

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
