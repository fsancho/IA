; Training Nodes
breed [ nodes node ]

; Markers breed: show the solution in real time
breed [ markers marker ]


nodes-own [
  weight     ;
  err        ; mean distance of this wieght node to the neighbors ones
]

markers-own [
  mynode     ; Node associated to this marker
]

globals [
  TSet      ; Training set
  link-len  ; distance between nodes )minimal radius to reach)
  ]

; Inicialmente, asignamos un peso aleatorio a cada patch y generamos aleatoriamente
; los vectores de entrenamiento
to setup
  ca
  ; Create the learning nodes
  setup-nodes
  ; Create the cities (Training Set)
  set Tset n-values Num-cities [(list random-pxcor random-pycor)]
  foreach Tset [
    ask patch (first ?) (last ?) [ set pcolor white]
  ]
  ; Reset timer
  reset-ticks
end

; Create N nodes and N markers (to show the evolution of the weights' nodes)
to setup-nodes
  set-default-shape markers "circle"
  ; Markers will show the links between them (roads between cities)
  create-ordered-markers N
  [
    fd 5
    set color [52 93 169 50]
    let mn 0
    ; Every marker has an associated learning node
    hatch-nodes 1 [
      ht
      set weight (list xcor ycor)
      set mn self
      ]
    set mynode mn
  ]
  ; Create the ring of markers
  ask markers [
    let con ifelse-value (who > 0) [who - 1] [N - 1]
    create-link-with marker con [set color white]
  ]
  ; set the minimum radius to be considered
  set link-len [link-length] of one-of links
end


; Función que devuelve el radio de influencia dependiente el tiempo.
;   Es una función que tiende a disminuir suavemente el radio, hasta
;   hacer que el entorno de influencia de cada punto sea unitario.
to-report R [t]
  let r0 5
  let T-Cons Training-Time / (ln (r0 / link-len))
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
  (foreach TSet [
    let V ?1
    let W BMU V
    ask W [
      ask nodes in-radius (R ticks) [
        set weight new-weight weight V ticks
      ]]])
  ; Update the markers position
  ask markers [
    let xy [weight] of mynode
    setxy (first xy) (last xy)
  ]
  tick
  if ticks > Training-Time [ stop ]
end

to toggle-markers
  let m one-of markers
  let new-mode ifelse-value ([pen-mode = "down"] of m) ["up"]["down"]
  ask markers [
    set pen-mode new-mode
  ]
end

to toggle-associations
  if-else any? nodes with [any? link-neighbors]
  [ ask nodes [ask my-links [die] ] ]
  [ ask markers [create-link-with mynode [set color [100 100 100 100]]]]
end
@#$#@#$#@
GRAPHICS-WINDOW
185
10
510
356
31
31
5.0
1
12
1
1
1
0
0
0
1
-31
31
-31
31
1
1
1
ticks
30.0

SLIDER
10
80
182
113
Training-Time
Training-Time
0
10000
2500
100
1
NIL
HORIZONTAL

BUTTON
98
150
183
183
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
11
150
96
183
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
11
184
96
229
Radius
precision (R ticks) 3
17
1
11

MONITOR
98
184
183
229
Learning Rate
precision (L ticks) 5
17
1
11

SLIDER
10
115
182
148
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
10
45
182
78
N
N
1
400
150
1
1
NIL
HORIZONTAL

SLIDER
10
10
182
43
Num-Cities
Num-Cities
1
100
50
1
1
NIL
HORIZONTAL

BUTTON
10
230
95
263
Toggle Markers
toggle-markers
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
10
265
95
298
Start-End
toggle-associations
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

circle
false
0
Circle -7500403 true true 0 0 300

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
1
@#$#@#$#@
