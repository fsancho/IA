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

; The general Problem Solver A* Algorithm es very similar to the previous one (patches).
; Where, now, the network is formed by the states of the problem to be solved and the
; links between them are the transitions that obtains one from the other.
; The main difference is that it is not a good idea to have all the netwrok precomputed,
; and we will build it (calculating the children-states) while we need it.
to-report A* [#Start #Goal]
  ; Create a state with the #Start content, and a searcher in it
  create-start #Start #Goal
  ; The main loop will run while we have active searchers to
  ; inspect. Tha means that a path connecting start and goal is still possible
  while [ any? searchers with [active?]]
  [
    ; From the active searchers we take one of the minimal expected cost to the goal
    ask min-one-of (searchers with [active?]) [total-expected-cost]
    [
      ; We will explore its neighbors, so we deactivated it
      set active? false
      ; Store this searcher and its current-state in temporal variables to facilitate their use
      let this-searcher self
      let previous-cost cost
      let C-S current-state
      ; Next, we create the neighbors of the state
      create-neighbor-states C-S
      ; For every neighbor state of this location
      ask ([out-link-neighbors] of C-S)
      [
        ; Take the link that connect it to the Location of the searcher
        let connection in-link-from C-S
        ; The cost to reach the neighbor in this path is the previous cost plus the cost of the link
        let c previous-cost + [cost-link] of connection
        ; Maybe in this state there are other searchers (comming from other states).
        ; If this new path is better than the other, then we put a new searcher and remove the old ones
        if not any? searchers-in-state with [cost < c]
        [
          hatch-searchers 1
          [
            ht
            set shape "circle"
            set color red
            set current-state myself ; the location of the new searcher is this neighbor state
            set memory lput connection ([memory] of this-searcher) ; the path is built from the
                                                                   ; original searcher's path
            set cost c   ; real cost to reach this state
            set total-expected-cost cost + heuristic #Goal ; expected cost to reach the goal with this path
            set active? true  ; it is active to be explored
            ask other searchers-in-state [die] ; Remove other seacrhers in this state
          ]
        ]
      ]
    ]
    ; If some of the searchers has reached the goal, we have an upper bound for the cost, so
    ; we deactivate all the searchers with cost over this bound. But we must continue with
    ; the search because maybe there is one other path with lower cost.
    ; If you want a fast calculated path but maybe not the shorter in cost, you can remove
    ; this part and stop the main loop as soon as the first searcher has reached the goal:
    ;  change
    ;     while [ any? searchers with [active?]]
    ; by
    ;     while [ not any? searchers with [final-searcher? #Goal] and
    ;             any? searchers with [active?]]
    if any? searchers with [final-searcher? #Goal] [
      let c min [cost] of (searchers with [final-searcher? #Goal])
      ask searchers with [active? and cost > c] [set active? false]
    ]
    layout-radial states links state 0
  ]
  ; When the loop has finished, we have two options: no path, or a searcher has reached the goal
  ; By default the return will be false (no path)
  let res false
  ; But if it is the second option
  if any? searchers with [final-searcher? #Goal]
  [
    ; we will return the path located in the memory of one of the searchers
    ; that reached the goal with minimal cost
    let minimal-searcher min-one-of (searchers with [final-searcher? #Goal]) [cost]
    show [cost] of minimal-searcher
    set res [memory] of minimal-searcher
  ]
  ; Remove the searchers
  ask searchers [die]
  ; and report the result
  report res
end

; Auxiliary report to decide (via its current-state) if a searcher has reached thw goal
to-report final-searcher? [#Goal]
  report [final-state? #Goal] of current-state
end

; Auxiliary procedure to create the initial state and the searcher that will start from it
to create-start [#start #Goal]
  create-states 1 [
    set content #Start
    set color blue
    set shape "circle"
    set label content
    hatch-searchers 1
    [
      ht
      set shape "circle"
      set color red
      set current-state myself
      set memory []
      set cost 0
      set total-expected-cost cost + heuristic #Goal ; Compute the expected cost
      set active? true ; It is active, because we didn't calculate its neighbors yet
     ]
  ]
end

; Create dinamically the neighbors of s
to create-neighbor-states [s]
  ask s [
    foreach children-states [
      let ns first ?
      let r last ?
      ifelse not any? states with [content = ns]
      [
        hatch-states 1 [
          set content ns
          set label content
          create-link-from s [
            set rule r
            set label first r
            set cost-link item 1 r
          ]
        ]
      ]
      [
        ask one-of states with [content = ns] [
          create-link-from s [
            set rule r
            set cost-link item 1 r
            set label first r
          ]
        ]
      ]
    ]
  ]
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

; Auxiliary state report to return the searchers located in it (it is like a version of turtles-here)
to-report searchers-in-state
  report searchers with [current-state = myself]
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
NetLogo 5.3
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
