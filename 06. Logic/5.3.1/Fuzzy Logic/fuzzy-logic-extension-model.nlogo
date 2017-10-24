;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GNU GENERAL PUBLIC LICENSE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; fuzzy-logic-extension-model 
;; fuzzy-logic-extension-model is a model designed to show how to implement 
;; a system of fuzzy IF-THEN rules in NetLogo. Version 1.1
;;
;; Copyright (C) 2014 Doina Olaru & Luis R. Izquierdo
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;; Contact information:
;; Luis R. Izquierdo 
;;   University of Burgos, Spain. 
;;   e-mail: lrizquierdo@ubu.es

extensions [fuzzy] 

;;;;;;;;;;;;;;;;;
;;; Variables ;;;
;;;;;;;;;;;;;;;;;

globals [
  temperature
  visitors          ;; agents who do the visit in the current period
  recommended       ;; agents who have been recommended to do the visit 
  accumulated-#-of-visitors
  no-more-tours-at
]

breed [agents agent]

agents-own [
  
  my-concept-of-nice
  my-concept-of-extreme
  
  my-concept-of-expensive
  my-concept-of-inexpensive
  
  my-concept-of-likely
  my-concept-of-unlikely
  
  my-prob-of-recommending
  
  selected?
  ticks-past-since-visit
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  clear-all
  fuzzy:set-resolution 8
  setup-agents
  plot-templates
  reset-ticks  
end

to setup-agents
  create-agents initial-num-of-visitors [
    set hidden? true
    set selected? true
    create-my-fuzzy-sets
  ]
  set visitors agents
end

to create-my-fuzzy-sets  

  ;; TEMPERATURE
  set s-extreme clip>0 s-extreme
  set s-nice clip>0 s-nice
  set mu-nice clip [-10 50] mu-nice
  
  set my-concept-of-nice fuzzy:gaussian-set (list 
    clip [-10 50] (mu-nice + noise variability)
    clip>0 (s-nice + noise variability)
    [-10 50])
  
  let my-concept-of-high fuzzy:gaussian-set (list 
    50 clip>0  (s-extreme + noise variability)
    [-10 50]) 
  let my-concept-of-low fuzzy:gaussian-set (list 
    -10 clip>0 (s-extreme + noise variability)
    [-10 50]) 
  set my-concept-of-extreme fuzzy:or (list my-concept-of-high my-concept-of-low)
  
  ;; PRICE
  set initial-expensive clip [0 10] initial-expensive
  set final-inexpensive clip [0 10] final-inexpensive
  
  set my-concept-of-expensive   fuzzy:piecewise-linear-set (list [0 0] (list clip [0 10] (initial-expensive + noise variability) 0) [10 1]) 
  set my-concept-of-inexpensive fuzzy:piecewise-linear-set (list [0 1] (list clip [0 10] (final-inexpensive + noise variability) 0) [10 0]) 
  
  ;; PROBABILITY
  set initial-likely clip [0 1] initial-likely
  set final-unlikely clip [0 1] final-unlikely
  
  set my-concept-of-likely   fuzzy:piecewise-linear-set (list [0 0] (list clip [0 1] (initial-likely + noise (variability / 10)) 0) [1 1]) 
  set my-concept-of-unlikely fuzzy:piecewise-linear-set (list [0 1] (list clip [0 1] (final-unlikely + noise (variability / 10)) 0) [1 0]) 

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Run-time procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
    
  if not any? visitors [
    user-message "There are no visitors" 
    set no-more-tours-at ticks
    stop
  ]
  
  do-visit
    
  ask visitors [ compute-probability ]

  do-plots
    ;; We plot here because the set of visitors will change later, and the plots are for visitors.
  
  ask (agents with [ticks-past-since-visit >= recommend-opportunities]) [die]
    ;; agents who have no more opportunities to recommend leave the simulation.
  
  set recommended no-turtles
  ask agents [do-recommendation]
  
  set-visitors-for-next-period

  ask agents [set ticks-past-since-visit (ticks-past-since-visit + 1)] 
    ;; Note that even visitors (next-period) are adding 1 to ticks-past-since-visit, but this is not a problem, 
    ;; since ticks-past-since-visit is set to 0 when they visit.
    ;; We could do this at the beginning of the procedure; it does not really matter.
    
  tick
end

to do-visit
  set temperature clip [-10 50] random-normal 20 10
  
  ask visitors [
    set ticks-past-since-visit 0    
    set accumulated-#-of-visitors (accumulated-#-of-visitors + 1)
  ]
  
end

to compute-probability
  
  ;; COMPUTATION OF RESHAPED CONSEQUENTS FOR EACH RULE
  let R1 fuzzy:and-rule (list (list price my-concept-of-inexpensive) (list temperature my-concept-of-nice))    my-concept-of-likely
  let R2 fuzzy:or-rule  (list (list price my-concept-of-expensive)   (list temperature my-concept-of-extreme)) my-concept-of-unlikely 
  
  let list-of-rules (list R1 R2)
  
  ;; AGGREGATION OF ALL THE RESHAPED CONSEQUENTS
  let my-prob-of-recommending-fuzzy-set (runresult (word "fuzzy:" type-of-aggregation " list-of-rules"))   
  
  ;; DEFUZZIFICATION OF THE AGGREGATED FUZZY SET
  set my-prob-of-recommending (runresult (word "fuzzy:" type-of-defuzzification "-of my-prob-of-recommending-fuzzy-set")) 
  
end

to do-recommendation
  if random-float 1.0 < my-prob-of-recommending [
    hatch-agents 1 [
      set selected? false
      set recommended (turtle-set recommended self)
    ] 
  ]
end

to set-visitors-for-next-period
  let n-of-recommended (count recommended)
  let n-of-visitors ifelse-value (n-of-recommended > group-size) [group-size] [n-of-recommended]
  
  set visitors no-turtles
  ask n-of n-of-visitors recommended [
    set selected? true
    create-my-fuzzy-sets
    set visitors (turtle-set visitors self)
  ]
  
  ask recommended with [not selected?] [die]
end

;;;;;;;;;;;;;;;;;;;;;;;;
;;;      Plots       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to do-plots
  
  set-current-plot "Temperature"
  plotxy ticks temperature
  
  set-current-plot "Visits"
  plotxy ticks count visitors
  set-plot-y-range 0 group-size 
  
  set-current-plot "Likelihood of recommending"
  
  if any? visitors [
    let probabilities [my-prob-of-recommending] of visitors
    set-current-plot-pen "min" plotxy ticks min probabilities
    set-current-plot-pen "avg" plotxy ticks mean probabilities
    set-current-plot-pen "max" plotxy ticks max probabilities
  ]
  
end

to plot-concepts
  
  plot-templates  
  
  set-current-plot "Concepts of nice and extreme temperature"
  clear-plot
  set-plot-x-range -10 50
  set-plot-pen-color red
  ask visitors [fuzzy:plot my-concept-of-extreme]
  set-plot-pen-color blue
  ask visitors [fuzzy:plot my-concept-of-nice]

  set-current-plot "Concepts of expensive and inexpensive"
  clear-plot
  set-plot-x-range 0 10
  set-plot-pen-color red
  ask visitors [fuzzy:plot my-concept-of-expensive]
  set-plot-pen-color blue
  ask visitors [fuzzy:plot my-concept-of-inexpensive]
  
  set-current-plot "Concepts of likely and unlikely"
  clear-plot
  set-plot-x-range 0 1
  set-plot-pen-color red
  ask visitors [fuzzy:plot my-concept-of-unlikely]
  set-plot-pen-color blue
  ask visitors [fuzzy:plot my-concept-of-likely]
end

to plot-templates
  
  ;; TEMPERATURE
  set-current-plot "Template for concepts of temperature"
  clear-plot
  set-plot-x-range -10 50
  
  let nice-template fuzzy:gaussian-set (list mu-nice s-nice [-10 50])
  
  let high-template fuzzy:gaussian-set (list 50 (clip>0 s-extreme) [-10 50]) 
  let low-template fuzzy:gaussian-set (list -10 (clip>0 s-extreme) [-10 50]) 
  let extreme-template fuzzy:or (list high-template low-template)
  
  set-plot-pen-color blue
  fuzzy:plot nice-template
  
  set-plot-pen-color red
  fuzzy:plot extreme-template
  
  ;; PRICE
  set-current-plot "Template for concepts of price"
  clear-plot
  
  let expensive-template   fuzzy:piecewise-linear-set (list [0 0] (list initial-expensive 0) [10 1])
  let inexpensive-template fuzzy:piecewise-linear-set (list [0 1] (list final-inexpensive 0) [10 0]) 
  
  set-plot-pen-color blue
  fuzzy:plot inexpensive-template
  
  set-plot-pen-color red
  fuzzy:plot expensive-template
  
  ;; PROBABILITY
  set-current-plot "Template for concepts of likelihood"
  clear-plot
  
  let likely-template   fuzzy:piecewise-linear-set (list [0 0] (list initial-likely 0) [1 1])
  let unlikely-template fuzzy:piecewise-linear-set (list [0 1] (list final-unlikely 0) [1 0]) 
  
  set-plot-pen-color blue
  fuzzy:plot likely-template
  
  set-plot-pen-color red
  fuzzy:plot unlikely-template
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Supporting procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report noise [v]  ;; reports a random number in the interval [-v v]
  report (v - random-float (2 * v))
end

to-report clip [i v] ;; clips the value v within the interval i
  let f first i
  let l last i
  if v < f [set v f]
  if v > l [set v l]
  report v
end

to-report clip>0 [v]
  if v <= 0 [set v 0.01]
  report v 
end
@#$#@#$#@
GRAPHICS-WINDOW
737
15
982
200
1
1
51.33333333333334
1
10
1
1
1
0
1
1
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
8
12
87
47
setup
startup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

PLOT
186
10
459
201
Template for concepts of temperature
temperature
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

PLOT
187
267
460
470
Concepts of nice and extreme temperature
temperature (ºC)
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
718
475
984
604
Likelihood of recommending
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"max" 1.0 2 -14730904 true "" ""
"avg" 1.0 0 -13345367 true "" ""
"min" 1.0 2 -11221820 true "" ""

PLOT
465
474
715
604
Visits
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -16777216 true "" ""

TEXTBOX
117
10
180
42
Fuzzy sets
11
0.0
1

BUTTON
9
65
87
98
go once
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
10
174
164
207
initial-num-of-visitors
initial-num-of-visitors
0
group-size
30
1
1
NIL
HORIZONTAL

CHOOSER
23
558
181
603
type-of-defuzzification
type-of-defuzzification
"COG" "FOM" "LOM" "MOM" "MeOM"
0

PLOT
187
474
461
603
Temperature
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

BUTTON
104
66
179
99
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

SLIDER
11
253
168
286
group-size
group-size
0
100
30
1
1
NIL
HORIZONTAL

INPUTBOX
186
203
285
263
mu-nice
20
1
0
Number

INPUTBOX
288
203
373
263
s-nice
10
1
0
Number

INPUTBOX
375
203
460
263
s-extreme
10
1
0
Number

SLIDER
10
291
178
324
recommend-opportunities
recommend-opportunities
1
10
2
1
1
NIL
HORIZONTAL

MONITOR
120
109
177
154
NIL
ticks
0
1
11

CHOOSER
23
509
180
554
type-of-aggregation
type-of-aggregation
"max" "prob-or" "sum"
0

BUTTON
72
425
178
458
NIL
plot-concepts
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
328
178
373
NIL
accumulated-#-of-visitors
0
1
11

MONITOR
11
377
178
422
NIL
no-more-tours-at
0
1
11

PLOT
462
10
718
202
Template for concepts of price
price
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

PLOT
722
10
986
202
Template for concepts of likelihood
likelihood
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

INPUTBOX
465
204
590
264
initial-expensive
2
1
0
Number

INPUTBOX
593
204
718
264
final-inexpensive
8
1
0
Number

INPUTBOX
722
204
847
264
initial-likely
0.1
1
0
Number

INPUTBOX
850
204
985
264
final-unlikely
0.9
1
0
Number

PLOT
464
267
717
470
Concepts of expensive and inexpensive
price
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

PLOT
720
267
985
471
Concepts of likely and unlikely
probability
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

SLIDER
10
212
165
245
price
price
0
10
5
0.1
1
NIL
HORIZONTAL

SLIDER
9
470
181
503
variability
variability
0
5
3
0.1
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
NetLogo 5.2.0
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
