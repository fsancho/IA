__includes ["SOM.nls"]

globals [
  TSet      ; Training set
  Header    ; Identifiers of Training Vectors
  Att-name  ; Attributes in Training Vectors
  ]

; Inicialmente, asignamos un peso aleatorio a cada patch y generamos aleatoriamente
; los vectores de entrenamiento
to setup
  ca
;  resize-world 0 (Size-World - 1) 0 (Size-World - 1)
;  set-patch-size 400 / (Size-World - 1)
  read-data
  SOM:setup-Lnodes Size-World "HxGrid" (length first Tset) "R"
  ask SOM:Lnodes [
    st
    set shape "hex"
    set size 1.345  * world-width / Size-World
    set label-color black
    set color scale-color white (mean weight) -0.0 1.0
  ]
  reset-ticks
end

to go
  ; Run the SOM Algorithm
  SOM:SOM Tset Training-Time
  ask patches [set pcolor white]
  let Mx max [xcor] of SOM:Lnodes
  let inc .1 * max-pxcor; - Mx * .9
  ask SOM:Lnodes [
    setxy (inc + xcor * .9) (inc + ycor * .9)
    set size size * .9
  ]
  ; Label the BMUs of TSet element with their names
  (foreach TSet Header [ [?1 ?2] ->
    let V ?1
    let W SOM:BMU V
    ask W [set label ifelse-value (label = "") [?2][(word label "/" ?2)]]
  ])
end

to SOM:ExternalUpdate
  ask SOM:Lnodes [ set color scale-color white (mean weight) -0.4 1.4]
  tick
end

; Read numeric data from a file and normalize it into TSet.
;   Alse creates the Header (identifiers of the columns), and names of attributes
to read-data
  file-close-all
  let f user-file
  if (f = false) [stop]
  file-open f
  set Header bf read-from-string (word "[" file-read-line "]")
  let att []
  set Att-name []
  while [not file-at-end?]
  [
    let line read-from-string (word "[" file-read-line "]")
    let max-line max (bf line)
    set Att-name lput (first line) Att-name
    set line map [ ?1 -> ?1 / max-line ] (bf line)
    set att lput line att
  ]
  file-close-all
  set TSet []
  foreach (n-values length Header [ ?1 -> ?1 ])
  [ ?1 ->
    let i ?1
    set Tset lput (map [ ??1 -> item i ??1 ] att) TSet
  ]
end

to refresh [i]
  ask SOM:Lnodes [
    set color scale-color yellow (item i weight) -0.4 1.4
    set label-color black
  ]
  display
end

to-report Att-size
  let a 0
  carefully [ set a (length Att-name) - 1] [set a 1]
  report a
end

to show-error
  SOM:error 6
  ask SOM:lnodes [set color scale-color white err  -.2 .5]
end
@#$#@#$#@
GRAPHICS-WINDOW
187
10
591
415
-1
-1
9.66
1
12
1
1
1
0
0
0
1
0
40
0
40
1
1
1
ticks
30.0

SLIDER
9
43
181
76
Training-Time
Training-Time
0
1000
150.0
1
1
NIL
HORIZONTAL

BUTTON
118
109
181
142
SOM!
go
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
9
109
72
142
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

MONITOR
9
231
70
276
Radius
precision (SOM:R ticks) 3
17
1
11

MONITOR
70
231
181
276
Learning Rate
precision (SOM:L ticks) 5
17
1
11

SLIDER
9
76
181
109
Initial-Learning-Rate
Initial-Learning-Rate
0
1
0.1
.001
1
NIL
HORIZONTAL

SLIDER
9
10
181
43
Size-World
Size-World
1
400
10.0
1
1
NIL
HORIZONTAL

MONITOR
9
142
181
187
Training Set Size
length Header
17
1
11

SLIDER
9
278
181
311
Attribute
Attribute
0
Att-size
9.0
1
1
NIL
HORIZONTAL

MONITOR
9
294
181
339
Attribute
item Attribute Att-name
17
1
11

BUTTON
71
339
127
372
Show
refresh Attribute
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
65
188
128
221
Error
show-error
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
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

hex
false
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270
@#$#@#$#@
NetLogo 6.0.2
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
