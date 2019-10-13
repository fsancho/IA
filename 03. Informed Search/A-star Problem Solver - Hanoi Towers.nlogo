;----------------- Include Algorithms Library --------------------------------

__includes [ "A-star.nls" "LayoutSpace.nls"]

;-----------------------------------------------------------------------------


;--------------- Customizable Reports -------------------

; These reports must be customized in order to solve different problems using the
; same A* function.

; Rules are represented by using lists [ "representation" cost f], where:
; - f allows to transform states (it is the transition function),
; - cost is the cost of applying the transition on a state,
; - and "representation" is a string to identify the rule.

; The representation of the states is:
; Discs 1 < 2 < 3 < ... < N
; State = [ [Tower1] [Tower2] [Tower3] ... [TowerM] ]
; Tower_i= [i_1 < i_2 < i_3], [i_1 < i_2], [i_1], [ ]

; This agent report returns the applicable transitions for the content (it depends
; on the current state)

to-report applicable-transitions [c]
  let t-a []
  let lista (range (length c))
  foreach lista [ i ->
    foreach lista [ j ->
      let t (list (word i "->" j) 1 (list i j))
      if valid-transition? t c [set t-a lput t t-a]
    ]
  ]
  report t-a
end

; valid-transition? reports if a transition t is applicable to a state s

to-report valid-transition? [t s]
  let i first last t
  let j last last t
  if empty? (item i s) [report false]
  if empty? (item j s) [report true]
  let top-disc-i first (item i s)
  let top-disc-j first (item j s)
  report top-disc-i < top-disc-j
end

; apply-transition returns the result of applying a transition t to a state s.
; It is used directly by the map application of children-states.

to-report apply-transition [t s]
  let i first last t
  let j last last t
  let disco first (item i s)
  set s replace-item i s (bf (item i s))
  set s replace-item j s (fput disco (item j s))
  report (list s t)
end

; children-states is an agent report that returns the children for the current state.
; it will return a list of pairs [ns tran], where ns is the content of the children-state,
; and tran is the applicable transition to get it.
; It maps the applicable transitions on the current content, and then filters those
; states that are valid.

to-report AI:children-states
  report (map [ t -> apply-transition t content ] (applicable-transitions content))
end

; final-state? idetifies final states

to-report AI:final-state? [params]
  report ( content = params)
end

; Searcher report to compute the heuristic for this searcher.
to-report AI:heuristic [#Goal]
  ; Add any heuristic you want test, and comment the other ones:

  ;report heur1
  report heur2 #Goal

end

; Several heuristic examples to be tested:
to-report heur1
  report 0
end

to-report heur2 [#Goal]
  report (length (item 0 [content] of current-state ))
end

to-report AI:equal? [a b]
  report a = b
end

;--------------------------------------------------------------------------------

; Auxiliary procedure to test the A* algorithm
to test
  ca
  ; Define Initial and Final States
  let In (list (range 1 (N-Discs + 1)) [] [])
  let Fn (list [] [] (range 1 (N-Discs + 1)))
  print (word "From: " In ", to: " Fn)
  no-display
  ; We compute the path with A*
  let path (A* In Fn True True)
  layout-radial AI:states AI:transitions AI:state 0
  style
  display
  ; if any reported path, we highlight it in the graph and show the rules:
  if path != false [
    ;repeat 1000 [layout-spring states links 1 3 .3]
    highlight-path path
    print (word "Number of steps: " (length path))
    print (word "Actions to sort it: " (map [ s -> first [rule] of s ] path))
  ]
  print (word (max [who] of turtles - count AI:states) " searchers used")
  print (word (count AI:states) " states created")
end


; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  foreach path [
    s ->
    ask s [
      set color red set thickness .4
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
115
10
552
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

MONITOR
15
125
77
170
# States
count AI:states
17
1
11

SLIDER
10
55
102
88
N-discs
N-discs
1
10
5.0
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
