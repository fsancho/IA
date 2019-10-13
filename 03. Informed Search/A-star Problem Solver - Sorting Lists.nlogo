;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls" "LayoutSpace.nls"]

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

to-report AI:children-states
  let indexes [0 1 2]
  report (map [ i -> (list (transp i content) (list (word "T-" i) 1 i)) ] indexes)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report AI:final-state? [params]
  report ( reduce and (map [ i -> (item i content) <= (item (i + 1) content) ] [0 1 2]))
end


; Searcher report to compute the heuristic for this searcher
to-report AI:heuristic [#Goal]
  let indexes [0 1 2]
  let c [content] of current-state
  report length filter [ v -> v ] (map [ i -> (item i c) > (item (i + 1) c) ] indexes)
end

to-report AI:equal? [a b]
  report a = b
end


;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm for sorting lists
to test
  ca
  let I shuffle [1 2 3 4]
  print (word "Initial State: " I)

  no-display
  ; We compute the path with A*
  let path (A* I true True True)
  layout-radial AI:states AI:transitions AI:state 0
  style
  display

  ; if any, we highlight it
  if path != false [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    print (word "Actions to sort it: " (map [ t -> first [rule] of t ] path))
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
