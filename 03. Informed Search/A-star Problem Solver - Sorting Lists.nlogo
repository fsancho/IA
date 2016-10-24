;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls"]

;-----------------------------------------------------------------------------

;---------------------- Preamble for models using AI Library -----------------

; In this case, we will work with turtles, not patches.
; Specifically with two types of turtles
breed[states state]       ; to represent the states of the problem
breed[searchers searcher] ; to represent the agents that will make the search

; We need one property in the states to store its content
states-own [
  content
]

; All the information about the search will be stored in the searchers.
; To know if a state has been explored it is enough to see if there
; is a searcher on it.

; Searchers will have some additional properties for their functioning.
searchers-own [
  memory               ; Stores the path from the start state to here
  cost                 ; Stores the real cost from the start
  total-expected-cost  ; Stores the total exepcted cost from Start to
                       ;   the Goal that is being computed
  current-state        ; The state where the searcher is
  active?              ; is the seacrher active? That is, we have reached
                       ;   the state, but we must consider it because its
                       ;   neighbors have not been explored
]

; The links of the graph store the applied rule between states
links-own [
  cost-link
  rule
]

;--------------- Customizable Reports -------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using lists [ "representation" cost f], where:
; - f allows to transform states (it is the transition function),
; - cost is the cost of applying the transition on a state,
; - and "representation" is a string to identify the rule.

to-report transp [i l]
  let a item i l
  let b item (i + 1) l
  let l1 replace-item i l b
  let l2 replace-item (i + 1) l1 a
  report l2
end


; children-states is a state report that returns the children for the current state.
; It will return a list of pairs [ns tran], where ns is the content of the children-state,
; and tran is the applicable transition to get it.
; It maps the applicable transitions on the current content, and then filters those
; states that are valid.

to-report children-states
  let indexes [0 1 2]
  report (map [(list (transp ? content) (list (word "T-" ?1) 1 ?))] indexes)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report final-state? [params]
  report ( reduce and (map [(item ? content) <= (item (? + 1) content)] [0 1 2]))
end


; Searcher report to compute the heuristic for this searcher
to-report heuristic [#Goal]
  let indexes [0 1 2]
  let c [content] of current-state
  report length filter [?] (map [(item ? c) > (item (? + 1) c)] indexes)
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm for sorting lists
to test
  ca
  let I shuffle [1 2 3 4]
  print (word "Initial State: " I
)  ; We compute the path with A*
  let path (A* I true)
  ; if any, we highlight it
  if path != false [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    print (word "Actions to sort it: " (map [first [rule] of ?] path))
  ]
  print (word (max [who] of turtles - count states) " searchers used")
  print (word (count states) " states created")
end


; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  foreach path [
    ask ? [
      set color yellow set thickness .4
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
85
10
524
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
10
10
73
43
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
