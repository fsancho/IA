;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls"]

;-----------------------------------------------------------------------------

;---------------------- Preamble for models using AI Library -----------------

; In this case, we will work with turtles, not patches.
; Specifically with two types of turtles
breed[states state]       ; to represent the states of the problem
breed[searchers searcher] ; to represent the agents that will make the search

; We need one extra property in the states to store its content
states-own [
  content
]

; All the information about the search will be stored in the searchers,
; and to know if a state has been explored it is enough to see of there
; is a searcher on it.

; Searchers will have some additional properties for their functioning.
searchers-own [
  memory               ; Stores the path from the start state to here
  cost                 ; Stores the real cost from the start
  total-expected-cost  ; Stores the total exepcted cost from Start to
                       ;   the Goal that is being computed
  current-state         ; The state where the searcher is
  active?              ; is the seacrher active? That is, we have reached
                       ;   the state, but we must consider it because its
                       ;   neighbors have not been explored
]

; In the links of the graph the searching is building we store the rule
links-own [
  cost-link
  rule
]

;--------------- Customizable Reports -------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using pairs [ "representation" cost f]
; in such a way that f allows to transform states (it is the transition function),
; cost is the cost of applying the transition on a state,
; and "representation" is a string to identify the rule. We will use tasks in
; order to store the transition functions.

to-report applicable-transitions
  report (list
           (list "*3" 1 (task [? * 3]))
           (list "+7" 1 (task [? + 7]))
           (list "-2" 1 (task [? - 2]))
           )
end

; valid? is a boolean report to say which states are valid
to-report valid? [x]
  report (x > 0)
end

; children-states is a state report that returns the children for the current state.
; It will return a list of pairs [ns tran], where ns is the content of the children-state,
; and tran is the applicable transition to get it.
; It maps the applicable transitions on the current content, and then filters those
; states that are valid.

to-report children-states
  report filter [valid? (first ?)]
                (map [(list (run-result (last ?) content) ?)]
                     applicable-transitions)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report final-state? [params]
  report ( content = params)
end

; Searcher report to compute the heuristic for this searcher
to-report heuristic [#Goal]
  let d abs (([content] of current-state) - #Goal)
  report ifelse-value (d > 1) [log d 3][d]
end

;------------------------------------------------------------------------------------------

; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  foreach path [
    ask ? [
      set color yellow set thickness .4
    ]
  ]
end

; Auxiliary procedure to test the A* algorithm between two random states of the network
to test
  ca
  ; We compute the path with A*
  let path (A* Initial Final)
  ; if any, we highlight it
  if path != false [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    show map [first [rule] of ?] path]
  show max [who] of turtles - count states
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
131
76
194
109
NIL
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

SLIDER
28
10
200
43
Initial
Initial
0
100
2
1
1
NIL
HORIZONTAL

SLIDER
28
44
200
77
Final
Final
0
100
92
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

circle
false
0
Circle -7500403 true true 0 0 300

@#$#@#$#@
NetLogo 5.3.1
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
