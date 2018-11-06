;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls" "LayoutSpace.nls"]

;--------------- Customizable Reports -------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using lists [ "representation" cost f], where:
; - f allows to transform states (it is the transition function),
; - cost is the cost of applying the transition on a state,
; - and "representation" is a string to identify the rule.

; Un estado es una lista descendente de números (lo que nos permite comparar
; estados y evitar probar operaciones, como restas o divisiones)

to-report opera [x y L]
  let peso 1
  let ax item x L
  let ay item y L
  let L' remove ax (remove ay L)
  let res []
  set res lput (list (ax * ay) (list (word ax "*" ay) peso)) res
  set res lput (list (ax + ay) (list (word ax "+" ay) peso)) res
  if ax > ay [set res lput (list (ax - ay) (list (word ax "-" ay) peso)) res]
  ;if ay > ay [set res lput (list (ay - ax) (list (word ay "-" ax) peso)) res]
  if ax mod ay = 0 [set res lput (list (ax / ay) (list (word ax "/" ay) peso)) res]
  ;if ay mod ax = 0 [set res lput (list (ay / ax) (list (word ay "/" ax) peso)) res]
  report map [ i -> (list (reverse sort lput (first i) L') (last i))] res
end

to-report states-from [L]
  let res []
  foreach (range 0 (length L - 2)) [
    ix1 ->
    let ixs (range (ix1 + 1) (length L - 1))
    foreach ixs [
      ix2 ->
      set res sentence res (opera ix1 ix2 L)
    ]
  ]
  report res
end

;to-report rango [x y]
;  report n-values (1 + y - x) [? + x]
;end

; children-states is a state report that returns the children for the current state.
; It will return a list of pairs [ns tran], where ns is the content of the children-state,
; and tran is the applicable transition to get it.
; It maps the applicable transitions on the current content, and then filters those
; states that are valid.

to-report AI:children-states
  report states-from content
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report AI:final-state? [params]
  report member? params content
end


; Searcher report to compute the heuristic for this searcher
to-report AI:heuristic [#Goal]
  let c [content] of current-state
  report min map [ x -> abs (#Goal - x) ] c
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm for sorting lists
to test
  ca
  let I reverse [2 6 14 25];(n-values 4 [1 + random 25])
  print (word "Initial State: " I)

  let Goal random 1000
  no-display
  ; We compute the path with A*
  let path (A* I Goal False True)
  layout-radial AI:states AI:transitions AI:state 0
  style
  display

  print (word "Goal: " Goal)
  ; if any, we highlight it
  ifelse path = false
  [
    print "Goal not reached"
    let m min-one-of AI:states [min map [x -> abs (Goal - x)] content]
    print (word "Best: " [content] of m)
  ]
  [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    print (word "Actions to sort it: " (map [t -> first [rule] of t] path))
  ]
  print (word (max [who] of turtles - count AI:states) " searchers used")
  print (word (count AI:states) " states created")
end


; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  foreach path [
    t ->
    ask t [
      set color red set thickness .4
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
85
10
522
448
-1
-1
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
NetLogo 6.0.4
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
