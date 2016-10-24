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

; We represent a state as a shuffle of
; [ 0 1 2 ]
; [ 3 4 5 ]
; [ 6 7 8 ]
; where 0 is the hole. And we will use lists [0 1 2 3 4 5 6 7 8]

; For a given position, h, (movements h) reports the list of possible swaps with
; the position h. For example:
; 0 can swap with 1 (right) and 3 (down)
; 1 can swap with 0 (left), 2 (right) and 4 (down)
; ... and so on
to-report movements [h]
  let resp  [[1 3] [0 2 4] [1 5] [0 4 6] [1 3 5 7] [2 4 8] [3 7] [6 4 8] [5 7]]
  report item h resp
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

to-report children-states
  let i (position 0 content)
  let indexes (movements i)
  report (map [(list (swap i ? content) (list (word "T-" ?1) 1 "regla"))] indexes)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report final-state? [params]
  report ( content = params)
end


; Searcher report to compute the heuristic for this searcher.
; We use the sum of manhattan distances between the current 2D positions of every
; tile and the goal position of the same tile.
to-report heuristic [#Goal]
  let pos [[0 0] [0 1] [0 2] [1 0] [1 1] [1 2] [2 0] [2 1] [2 2]]
  let c [content] of current-state
;  One other option is to count the misplaced tiles
;  report length filter [ ? = False] (map [?1 = ?2] c #Goal)
  report sum (map [man (item (position ? c) pos) (item (position ? #Goal) pos)]
                  (n-values 9 [?]))
end

to-report man [x y]
  report abs ((first x) - (first y)) + abs ((last x) - (last y))
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm
to test
  ca
  ; From a final position, we randomly move the hole some times
  let In (n-values 9 [?])
  type 0
  repeat 12 [
    let i position 0 In
    let j one-of movements i
    type (word "->" j)
    set In swap i j In
  ]
  print ""
  print (word "Initial State: " In)
  no-display
  ; We compute the path with A*
  let path (A* In (n-values 9 [?]))
  display
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

MONITOR
90
475
152
520
# States
count states
17
1
11

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
