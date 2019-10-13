;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls" "LayoutSpace.nls"]

;--------------- Customizable Reports -------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using lists [ "representation" cost f], where:
; - f allows to transform states (it is the transition function),
; - cost is the cost of applying the transition on a state,
; - and "representation" is a string to identify the rule.

; Un posible movimiento consiste en cambiar una carta de montón:
to-report AI:children-states
  let cartas (n-values 10 [x -> x + 1])
  report map  [ i -> (list (change i) (list i 1))] cartas
end

; Change i cambia la carta i de montón:
to-report change [i]
  let M1 first content
  let M2 last content
  ifelse member? i M1
  [report (list (sort remove i M1) (sort fput i M2))]
  [report (list (sort fput i M1) (sort remove i M2))]
end

; final-state? is an agent report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.


to-report AI:final-state? [params]
  let M1 first content
  let M2 last content
  let suma ifelse-value (M1 = []) [0][sum M1]
  let prod ifelse-value (M2 = []) [0] [reduce * M2]
  report (abs (suma - 36) + abs (prod - 360) < 10)
end


; Searcher report to compute the heuristic for this searcher
to-report AI:heuristic [#Goal]
  let M1 first [content] of current-state
  let M2 last [content] of current-state
  let suma ifelse-value (M1 = []) [0][sum M1]
  let prod ifelse-value (M2 = []) [0] [reduce * M2]
  report abs (suma - 36) + abs (prod - 360)
end

to-report AI:equal? [a b]
  report a = b
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm for sorting lists
to test
  ca
  let M1 (n-values 10 [x -> x + 1])
  let M2 n-of 4 M1
  foreach M2 [ x -> set M1 remove x M1]
  Let Initial_State (list M1 M2)

  print (word "Initial State: " Initial_State)

  no-display
  ; We compute the path with A*
  let path (A* Initial_State true True True)
  layout-radial AI:states AI:transitions AI:state 0
  style
  display

  ; if any, we highlight it
  if path != false [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    print (word "Actions to get it: " (map [ t -> first [rule] of t ] path))
    let c [content] of ([end2] of last path)
    print (word "Current State: " c)
    set M1 first c
    set M2 last c
    let suma ifelse-value (M1 = []) [0][sum M1]
    let prod ifelse-value (M2 = []) [0] [reduce * M2]
    show suma
    show prod
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
NetLogo 6.1.1
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
