; Training Nodes
breed [ nodes node ]

; Label Markers breed
breed [ markers marker ]


nodes-own [
  weight     ;
  err        ; mean distance of this wieght node to the neighbors ones
]

globals [
  TSet      ; Training set
  Header    ; Identifiers of Training Vectors
  Att-name  ; Attributes in Training Vectors
  ]

; Inicialmente, asignamos un peso aleatorio a cada patch y generamos aleatoriamente
; los vectores de entrenamiento
to setup
  ca
  resize-world 0 Size-World 0 Size-World
  set-patch-size 400 / Size-World
  read-data
  setup-nodes
  reset-ticks
end

to setup-nodes
  set-default-shape nodes "hex"
  ask patches
    [ sprout-nodes 1
        [ set size 1.28
          set weight n-values (length first Tset) [random-float 1]
          set color map [255 * ?] (sublist weight 0 3)
          if pxcor mod 2 = 0
            [ set ycor ycor - 0.5 ] ] ]
end


; Función que devuelve el radio de influencia dependiente el tiempo.
;   Es una función que tiende a disminuir suavemente el radio, hasta
;   hacer que el entorno de influencia de cada punto sea unitario.
to-report R [t]
  let r0 Size-World / 2
  let T-Cons Training-Time / (ln r0)
  report r0 * exp (-1 * t / T-Cons)
end

; Función que calcula la distancia euclídea de 2 vectores.
;   Por motivos de eficiencia, se quita la raiz cuadrada.
to-report dist [v1 v2]
  report sum (map [(?1 - ?2) ^ 2] v1 v2)
end

; Función que devuelve el nuevo peso de cada punto.
;   Cuando más cercano al BMU, más se modifica. Cuanto más cercano
;   al borde del entorno, menos. Depende de una tasa de aprendizaje (L)
;   y de una función que suaviza el comportamiento en el entorno (D).
to-report new-weight [W V t]
  report (map [?1 + (D t) * (L t) * (?2 - ?1)] W V)
end

; Función que calcula la tasa de aprendizaje. Comienza con un valor
;   que introduce el usuario, y disminuye en cada paso de ejecución.
to-report L [t]
  report Initial-Learning-Rate * exp (-1 * t / Training-Time)
end

; Función que suaviza el comportamiento del cálculo del peso en
;   función de la ditancia al BMU.
to-report D [t]
  report exp (-1 * (distance myself) / (2 * (R t)))
end

; Devuelve el BMU de un vector, es decir, la node que más lo aproxima.
to-report BMU [V]
  report min-one-of nodes [dist ([weight] of self) V]
end

; Iteración del SOM: para cada vector de entrenamiento se toma su BMU,
;   y al entorno de éste se le aplica la modificación de sus pesos para
;   que se acerquen al vector. Está preparado para dar un número fijo de
;   pasos, y se representan los pesos como colores del patch.
to SOM
  ask nodes [set label ""]
 (foreach TSet Header [
    let V ?1
    let W BMU V
    ask W [set label ifelse-value (label = "") [?2][(word label "/" ?2)]]
    ask W [
      ask nodes in-radius (R ticks) [
        set weight new-weight weight V ticks
        set color map [255 * ?] (sublist weight 0 3)
        ]]])
  tick
  if ticks > Training-Time [
    ask nodes with [label != ""] [
      hatch-markers 1 [
        set size 0 ]
      set label "" ]
    compute-error 1
    stop
    ]
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
    set line map [? / max-line] (bf line)
    set att lput line att
  ]
  file-close-all
  set TSet []
  foreach (n-values length Header [?])
  [
    let i ?
    set Tset lput (map [item i ?] att) TSet
  ]
end

to refresh [i]
  ask nodes [
    set color scale-color yellow (item i weight) -0.4 1.4
  ]
  ask markers [set label-color black]
  display
end

to-report Att-size
  let a 0
  carefully [ set a (length Att-name) - 1] [set a 1]
  report a
end

to compute-error [#radius]
  ask nodes [
    let vec other nodes in-radius #radius
    set err sum map [dist weight ?] ([weight] of vec) / (count vec)
    ;set color scale-color black err 0.05 0
    ]
  let MM max [err] of nodes
  ask nodes [ set color map [positive (? - err / MM * 255)] color]
  display
end

to-report positive [x]
  report max (list x 0)
end

to original-color
  ask nodes [
    set color map [255 * ?] (sublist weight 0 3)
  ]
  ask markers [
    set label-color white
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
187
10
606
450
-1
-1
12.903225806451612
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
31
0
31
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
140
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
SOM
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
9
109
72
142
NIL
setup\n
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
precision (R ticks) 3
17
1
11

MONITOR
70
231
181
276
Learning Rate
precision (L ticks) 5
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
31
2
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
0
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
NetLogo 5.3.1
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
