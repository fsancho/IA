; States are agents
breed [states state]
states-own
[
  content   ; Stores the content of the state (the value)
  explored? ; Shows if the state has been explored or not
  path      ; Stores the path to reach this state
]

; Transitions will be represented as links
directed-link-breed [transitions transition]
transitions-own
[
  rule       ; Stores the "representable" version of the applied rule
  R          ; Value of reward for Q-learning algorithm
  Q          ; Value of learning for Q-learning algorithm
  variation  ; Value of variation in learning for Q-learning algorithm
]

globals [
  M ; Number of towers, it is computed from the length of initial state
    ; The number of discs ared determined by the the values in use in
    ; input state
]

;--------------- Customizable Functions  --------------------------

; Rules are represented as pairs [ "representation" f ] where f allows
; to move between states (transition function) and "representation" is
; string to identify the applied rule

to-report applicable-transitions [c]
  let t-a []
  let MList (n-values M [ ?1 -> ?1 ])
  foreach MList [ ?1 ->
    let i ?1
    foreach MList [ ??1 ->
      let j ??1
      let t (list (word i "->" j) (list i j))
      if transition-valid? t c [set t-a lput t t-a]
    ]
  ]
  report t-a
end
; discs 1 < 2 < 3 < ... < N
; state = [ [Pole1] [Pole2] [Pole3] ... [PoleM] ]
; Pole_i= [i_1 < i_2 < i_3], [i_1 < i_2], [i_1], [ ]

to-report transition-valid? [t s]
  let i first last t
  let j last last t
  if empty? (item i s) [report false]
  if empty? (item j s) [report true]
  let disc first (item i s)
  let head first (item j s)
  if disc < head [report true]
  report false
end

to-report apply-transition [t s]
  let i first last t
  let j last last t
  let disc first (item i s)
  set s replace-item i s (bf (item i s))
  set s replace-item j s (fput disc (item j s))
  report s
end


; equal? is a report to identify the final states
to-report equal? [ob]
  report ( content = ob)
end

;---------------- Procedure to build the complete graph ----------------
; Essentially, we calculate the children states for every non explored state
; and connect them with the applied transition. The process continues till
; there are no more non explored states.

to complete-graph [initial-state]
  ca
  ask patches [ set pcolor white ]
  set M length read-from-string Initial_state

  ; Create the agent associated with the initial state
  create-states 1
  [
    set shape "hanoi"
    set color green
    set size 2
    set content read-from-string initial-state
    set label-color black
    set label content
    set path (list self)
    set explored? false
  ]
  ; While there are non explored states (the verification about reaching the
  ; goal is done in the loop)
  while [any? states with [not explored?]]
  [
    ask states with [not explored?]
    [
      ; Calculate the successor states applying every rule to the current state
      foreach applicable-transitions content
      [ ?1 ->
        let applied-state apply-transition ?1 content
        ; Consider only new states
        ifelse not any? states with [content = applied-state]
        [
          ; Create a new agent for every new state
          hatch-states 1
          [
            set content applied-state
            set label content
            set explored? false
            ; and connect it to its father with a labelled link
            create-transition-from myself [set rule ?1 set label first ?1 set label-color black]
            set color white
            ; Complete the path from initial state to here
            set path lput self path
          ]
        ]
        [
          let past one-of states with [content = applied-state]
          create-transition-to past [set rule ?1 set label first ?1 set label-color black]
        ]
        ; Update the representation
        if layout? [repeat 10 [layout]]
      ]
      ; After calculated all the successors, we mark the state as explored
      set explored? true
    ]
  ]
end

; Graph layout
to layout
  if states-size != [size] of state 0 [ask states [set size states-size]]
  layout-spring states transitions elasticity e-length repulsion
end

to adjust
  ask states [setxy (xcor * .9 + random-float 1) (ycor * .9 + random-float 1)]
end

;;
;; Q-Learning algortihm Procedures
;;

; Training Procedure
to Q-learning
  ; Ticks will count the number of steps
  reset-ticks
  ; Reset the values for transitions and states
  ask transitions [
    set Q 0
    set R 0
    set label ""
    set thickness 0
    set color grey
    set variation (Max-Variation + 1)
  ]
  ask states [
    set label ""
  ]
  ; Transitions reaching final states get maximal reward
  let f-state one-of states with [content = read-from-string Final_state]
  ask f-state [
    ask my-in-transitions [set R 100]
    set color red
  ]
  ; Repeat the learning process for transitions until max of variations is under the boud
  while [max [variation] of transitions > Max-Variation]
  [
    ask transitions [
      let Q2 (1 - nu) * Q + nu * (R + gamma * max [Q] of ([my-out-transitions] of end2))
      set variation abs (Q2 - Q)
      set Q Q2
      set label Q
    ]
    tick
  ]
  ; Normalize the quality of transitions and show it as color and thickness on links
  let MaxQ max [Q] of transitions
  ask transitions [
    set Q Q / MaxQ
    set color scale-color color Q 1 0
    set thickness Q / 4
    set label ""
  ]
end

; To use the information of Q in the calculation of the Solution we move from the initial state
; to the final state using the transitions iwth higher weights (Q).
to Q-execute
  ask states [set label ""]
  ask transitions [set color scale-color grey Q 1 0]
  let i-state one-of states with [content = read-from-string Initial_state]
  ask i-state [ set color green ]
  let f-state one-of states with [content = read-from-string Final_state]
  while [i-state != f-state]
  [
    ask i-state [
      set label (word content "       ")
      let accion max-one-of my-out-transitions [Q]
      ask accion [
        set color red
        set label first rule
      ]
      set i-state [end2] of accion
    ]
  ]
  ask f-state [
    set label (word content "       ")
    set color red
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1085
580
-1
-1
17.0
1
16
1
1
1
0
0
0
1
-25
25
-16
16
0
0
1
ticks
30.0

BUTTON
110
560
200
593
NIL
layout
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
10
45
105
90
Estados:
count turtles
17
1
11

INPUTBOX
10
95
200
155
Initial_state
[[1 2 3] [][]]
1
0
String

INPUTBOX
10
155
200
215
Final_state
[[][][1 2 3]]
1
0
String

BUTTON
10
10
105
43
Create Graph
complete-graph Initial_state
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
220
105
253
Q-Entrena
Q-learning
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
110
10
200
43
layout?
layout?
0
1
-1000

BUTTON
110
220
200
253
NIL
Q-Execute
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
10
260
200
293
nu
nu
0
1
0.15
.01
1
NIL
HORIZONTAL

SLIDER
10
295
200
328
gamma
gamma
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
10
330
200
363
Max-Variation
Max-Variation
0
1
0.01
.01
1
NIL
HORIZONTAL

MONITOR
10
365
200
410
Convergence in steps:
ticks
17
1
11

SLIDER
10
420
200
453
states-size
states-size
0
4
1.6
.1
1
NIL
HORIZONTAL

SLIDER
10
455
200
488
elasticity
elasticity
0
1
0.4
.1
1
NIL
HORIZONTAL

SLIDER
10
490
200
523
e-length
e-length
0
10
4.5
.5
1
NIL
HORIZONTAL

SLIDER
10
525
200
558
repulsion
repulsion
0
2
1.0
.1
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

hanoi
false
0
Rectangle -7500403 true true 0 30 300 285
Rectangle -16777216 false false 0 30 300 285
Rectangle -6459832 true false 0 225 300 255
Rectangle -6459832 true false 45 45 75 225
Rectangle -6459832 true false 225 45 255 225
Rectangle -6459832 true false 135 45 165 225
Rectangle -14835848 true false 0 180 120 210
Rectangle -13791810 true false 15 135 105 165
Rectangle -955883 true false 30 90 90 120
Rectangle -11221820 true false 180 180 300 210
Rectangle -5825686 true false 210 135 270 165
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
1.0
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
