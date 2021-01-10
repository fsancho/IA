;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star-LT.nls" ]

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
           (list "*3" 1 ([ x -> x * 3 ]))
           (list "+7" 1 ([ x -> x + 7 ]))
           (list "-2" 1 ([ x -> x - 2 ]))
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

to-report AI:children-of [content]
  report filter [ s -> valid? (first s) ]
                (map [ t -> (list (run-result (last t) content) t) ]
                     applicable-transitions)
end

; final-state? is a state report that identifies the final states for the problem.
; It usually will be a property on the content of the state (for example, if it is
; equal to the Final State). It allows the use of parameters because maybe the
; verification of reaching the goal depends on some extra information from the problem.
to-report AI:final-state? [content params]
  report ( content = params)
end

; Searcher report to compute the heuristic for this searcher
to-report AI:heuristic [content #Goal]
  let d abs (content - #Goal)
  ;report d
  report ifelse-value (d > 3) [log d 3][d]
end

to-report AI:equal? [a b]
  report a = b
end


;------------------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm between two random states of the network
to test
  ca
  ; We compute the path with A*
  let ti timer
  let path (A* Initial Final)
  show timer - ti
  show path
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
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
3.0
1
1
NIL
HORIZONTAL

INPUTBOX
30
120
185
180
Final
50000.0
1
0
Number

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
