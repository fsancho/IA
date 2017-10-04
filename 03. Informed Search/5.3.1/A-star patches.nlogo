globals
[
  p-valids   ; Valid Patches for moving not wall)
  Start      ; Starting patch
  Final-Cost ; The final cost of the path given by A*
]

patches-own
[
  father     ; Previous patch in this partial path
  Cost-path  ; Stores the cost of the path to the current patch
  visited?   ; has the path been visited previously? That is,
             ; at least one path has been calculated going through this patch
  active?    ; is the patch active? That is, we have reached it, but
             ; we must consider it because its children have not been explored
]

; Prepares the world and starting point
to setup
  ca
  ; Initial values of patches for A*
  ask patches
  [
    set father nobody
    set Cost-path 0
    set visited? false
    set active? false
  ]
  ; Generation of random obstacles
  ask n-of 100 patches
  [
    set pcolor brown
    ask patches in-radius random 10 [set pcolor brown]
  ]
  ; Se the valid patches (not wall)
  set p-valids patches with [pcolor != brown]
  ; Create a random start
  set Start one-of p-valids
  ask Start [set pcolor white]
  ; Create a turtle to draw the path (when found)
  crt 1
  [
    ht
    set size 1
    set pen-size 2
    set shape "square"
  ]
end

; Patch report to estimate the total expected cost of the path starting from
; in Start, passing through it, and reaching the #Goal
to-report Total-expected-cost [#Goal]
  report Cost-path + Heuristic #Goal
end

; Patch report to reurtn the heuristic (expected length) from the current patch
; to the #Goal
to-report Heuristic [#Goal]
  report distance #Goal
end

; A* algorithm. Inputs:
;   - #Start     : starting point of the search.
;   - #Goal      : the goal to reach.
;   - #valid-map : set of agents (patches) valid to visit.
; Returns:
;   - If there is a path : list of the agents of the path.
;   - Otherwise          : false

to-report A* [#Start #Goal #valid-map]
  ; clear all the information in the agents
  ask #valid-map with [visited?]
  [
    set father nobody
    set Cost-path 0
    set visited? false
    set active? false
  ]
  ; Active the staring point to begin the searching loop
  ask #Start
  [
    set father self
    set visited? true
    set active? true
  ]
  ; exists? indicates if in some instant of the search there are no options to
  ; continue. In this case, there is no path connecting #Start and #Goal
  let exists? true
  ; The searching loop is executed while we don't reach the #Goal and we think
  ; a path exists
  while [not [visited?] of #Goal and exists?]
  [
    ; We only work on the valid pacthes that are active
    let options #valid-map with [active?]
    ; If any
    ifelse any? options
    [
      ; Take one of the active patches with minimal expected cost
      ask min-one-of options [Total-expected-cost #Goal]
      [
        ; Store its real cost (to reach it) to compute the real cost
        ; of its children
        let Cost-path-father Cost-path
        ; and deactivate it, because its children will be computed right now
        set active? false
        ; Compute its valid neighbors
        let valid-neighbors neighbors with [member? self #valid-map]
        ask valid-neighbors
        [
          ; There are 2 types of valid neighbors:
          ;   - Those that have never been visited (therefore, the
          ;       path we are building is the best for them right now)
          ;   - Those that have been visited previously (therefore we
          ;       must check if the path we are building is better or not,
          ;       by comparing its expected length with the one stored in
          ;       the patch)
          ; One trick to work with both type uniformly is to give for the
          ; first case an upper bound big enough to be sure that the new path
          ; will always be smaller.
          let t ifelse-value visited? [ Total-expected-cost #Goal] [2 ^ 20]
          ; If this temporal cost is worse than the new one, we substitute the
          ; information in the patch to store the new one (with the neighbors
          ; of the first case, it will be always the case)
          if t > (Cost-path-father + distance myself + Heuristic #Goal)
          [
            ; The current patch becomes the father of its neighbor in the new path
            set father myself
            set visited? true
            set active? true
            ; and store the real cost in the neighbor from the real cost of its father
            set Cost-path Cost-path-father + distance father
            set Final-Cost precision Cost-path 3
          ]
        ]
      ]
    ]
    ; If there are no more options, there is no path between #Start and #Goal
    [
      set exists? false
    ]
  ]
  ; After the searching loop, if there exists a path
  ifelse exists?
  [
    ; We extract the list of patches in the path, form #Start to #Goal
    ; by jumping back from #Goal to #Start by using the fathers of every patch
    let current #Goal
    set Final-Cost (precision [Cost-path] of #Goal 3)
    let rep (list current)
    While [current != #Start]
    [
      set current [father] of current
      set rep fput current rep
    ]
    report rep
  ]
  [
    ; Otherwise, there is no path, and we return False
    report false
  ]
end

; Axiliary procedure to lunch the A* algorithm between random patches
to Look-for-Goal
  ; Take one random Goal
  let Goal one-of p-valids
  ; Compute the path between Start and Goal
  let path  A* Start Goal p-valids
  ; If any...
  if path != false [
    ; Take a random color to the drawer turtle
    ask turtle 0 [set color (lput 150 (n-values 3 [100 + random 155]))]
    ; Move the turtle on the path stamping its shape in every patch
    foreach path [
      ask turtle 0 [
        move-to ?
        stamp]]
    ; Set the Goal and the new Start point
    set Start Goal
  ]
end

; Auxiliary procedure to clear the paths in the world
to clean
  cd
  ask patches with [pcolor != black and pcolor != brown] [set pcolor black]
  ask Start [set pcolor white]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
624
445
-1
-1
4.0
1
10
1
1
1
0
0
0
1
0
100
0
100
0
0
1
ticks
30.0

BUTTON
15
10
105
43
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
110
10
195
43
Next
Look-for-Goal
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
120
400
195
445
NIL
Final-Cost
17
1
11

BUTTON
15
45
195
78
Clean Paths
clean
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

square
true
0
Rectangle -7500403 true true 0 0 300 300

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
1
@#$#@#$#@
