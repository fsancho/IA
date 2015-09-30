;;;;------------------------------------------------------------------------
;;;; Variables Globales

globals 
[
  raiz ; Raíz del árbol generado
  cont ; Contador para ir numerando los nodos visitados de forma secuencial
  acont; Contador para numerar la profundidad de las aristas
]

;;;; Familia de Agentes

breed [nodos nodo]   ; Familia de agentes para los nodos del árbol/grafo

nodos-own
[
  visitado?        ; Indica si el nodo ha sido visitado en la búsqueda 
                   ;       (usado en DFS y BFS)
  en-desarrollo?   ; Indica si el nodo ya ha sido desarrollado/expandido 
                   ;        en la búsqueda (usado en BFS)
  indice           ; Muestra el índice del nodo dentro del recorrido
  
  altura
]

;;;;------------------------------------------------------------------------
;;;; Generación de árboles/grafos

; Genera un árbol de ramificación constante indicando la profundidad 
; (número de niveles) y anchura (número de hijos)

to genera-arbol [#profundidad #anchura]
  ; El módulo principal genera un solo nodo (la raíz) y lanza el módulo 
  ;   recursivo de generación de hijos
  create-nodos 1
  [
    setxy random-xcor random-ycor
    set shape "square"
    set color blue
    set label-color white
    set size 1
    set raiz self
    set visitado? true
    set en-desarrollo? false
    set indice -1
    ; Llamada al módulo recursivo auxiliar. Ver abajo
    genera-arbol-aux (#profundidad - 1) #anchura self
  ]
  ; Tras haber generado el árbol, le damos layout radial
  layout-radial nodos links raiz
end
  
; El módulo recursivo auxiliar recibe la profundidad, anchura, y un nodo, 
; y genera el subárbol que pende de ese nodo
to genera-arbol-aux [#profundidad #anchura padre]
  ; El módulo solo se ejecuta si la profundidad es > 0
  if #profundidad > 0
  [
    ; Pedimos al nodo que genere sus hijos y los una a él
    ask padre
    [
      hatch-nodos #anchura
      [
        set visitado? false
        set en-desarrollo? false
        create-link-with padre
        ; Para cada hijo, repetimos el proceso
        genera-arbol-aux (#profundidad - 1) #anchura self
      ]
    ]
  ]   
end

; Módulo para generar un grafo aleatorio con el número de nodos y número
;  de aristas dados por el usuario.

to genera-grafo
  ca
  ; Primero, generamos todos los nodos
  create-nodos num-nodos
  [
    setxy random-xcor random-ycor
    set shape "square"
    set color blue
    set label-color white
    set size 1
    set visitado? true
    set en-desarrollo? false
    set indice -1
  ]
  ; En un grafo no hay raíz, por eso tomamos uno de ellos como raíz
  set raiz nodo 0
  ; Generamos aristas al azar, controlando que se generen la cantidad 
  ;   adecuada
  while [count links < Num-aristas]
  [
    ask one-of nodos
    [ create-link-with one-of other nodos ]
  ]
  ; Damos un layout que permita visualizarlos más fácilmente
  repeat 500 [ layout-spring nodos links 0.2 (sqrt num-nodos) / num-nodos 1 ]
end

; Módulo para reiniciar los valores de los nodos
to reset
  set cont 0
  set acont 1
  ask nodos 
  [
    set visitado? false
    set en-desarrollo? false
    set label ""
  ]
end

; Módulo para centrar en el nodo de inicio
to re-layout
  layout-radial nodos links (one-of nodos with [indice = 0])
end

;;;;------------------------------------------------------------------------
;;;; Algoritmos de búsqueda (realmente, algoritmos de recorrido en los que 
;;;; se muestra el orden de recorrido de cada nodo)

; Algoritmo de recorrido en anchura: Recibe como dato de entrada el nodo del 
;   que comienza.
; En cada paso numera cada corona de forma ordenada (primero, los hijos de 
;   los que tengan nuemración más baja)
; Los nodos que han sido visitados pero que están por expandir se encuentran 
;   "en-desarrollo"
to recorrido-BFS [#start]
  ; Comenzamos marcando el nodo de inicio
  ask #start
  [
    set en-desarrollo? true
    set visitado? true
    set label cont
    set indice cont
    set cont cont + 1
  ]
  ; La etiqueta "en-desarrollo?" nos permite saber si hay nodos que deban
  ;   ser desarrollados 
  while [any? nodos with [en-desarrollo?]]
  [
    ; Se toman por orden de indice los nodos que han de desarrollarse
    let siguientes sort-by [[indice] of ?1 <= [indice] of ?2] nodos with [en-desarrollo?];
    ; Y cada uno de ellos (siguiendo ese orden) se expande y se numeran 
    ;   sus hijos
    foreach siguientes
    [
      ask ?
      [
        ; Una vez se ha expandido, sigue estando visitado, pero ya no está 
        ; en-desarrollo
        set en-desarrollo? false
        ask link-neighbors with [not visitado?]
        [
          set en-desarrollo? true
          set visitado? true
          set label cont
          set indice cont
          set cont cont + 1
          wait (1 - velocidad)
        ]
      ]
    ]
  ]
end

; Algoritmo de recorrido en profundidad: Recibe como dato de entrada el 
;   nodo del que comienza.
; En cada paso avanza todo lo posible en cada rama, hasta llegar a las 
;   hojas, y da numeración sucesiva.
; Usa backtracking para volver arriba.
;   A diferencia del BFS, es un procedimiento recursivo.

to recorrido-DFS [#start]
  ; Cada nodo de entrada se marca como visitado, se numera, y se 
  ;   profundiza hacia sus hijos.
  ask #start
  [
    set visitado? true
    set label cont
    set indice cont
    set cont cont + 1
    wait (1 - velocidad)
    ; Para cada hijo suyo no visitado, se repite la operación
    ;   es importante notar que la propia llamada recursiva genera que 
    ;   el marcado sea en profundidad
    ask link-neighbors with [not visitado?]
    [
      if not visitado? [ recorrido-DFS self ] ; Podría ocurrir q se hubiera visitado
                                              ; en el mismo ciclo
    ]
  ] 
end

; Algoritmo de recorrido por azar exhaustivo: Recibe como dato de entrada
;   el nodo por el que comienza.
; Una vez marcado el nodo de inicio. Recorre el resto de nodos al azar,
;   pero con la precaución de no repetir nodos.

to recorrido-azar-exahustivo [#start]
  ask #start
  [
    set visitado? true
    set label cont
    set indice cont
    set cont cont + 1
    wait (1 - velocidad)
  ]
  ask nodos with [not visitado?]
  [
    set visitado? true
    set label cont
    set indice cont
    set cont cont + 1
    wait (1 - velocidad)
  ]
end      
@#$#@#$#@
GRAPHICS-WINDOW
210
10
781
602
16
16
17.0
1
12
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

SLIDER
7
10
110
43
Profundidad
Profundidad
1
10
6
1
1
NIL
HORIZONTAL

SLIDER
7
42
110
75
Anchura
Anchura
1
5
3
1
1
NIL
HORIZONTAL

BUTTON
110
10
189
75
Genera Arbol
ca\ngenera-arbol Profundidad Anchura
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
69
258
177
291
Numera Profundidad
reset\nrun (word \"recorrido-DFS \" Inicio)
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
6
258
69
291
NIL
reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
6
213
177
258
Inicio
Inicio
"raiz" "(one-of nodos)"
0

BUTTON
69
291
177
324
Numera Anchura
reset\nrun (word \"recorrido-BFS \" Inicio)
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
6
291
69
324
Re-Layout
re-layout
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
7
76
110
109
Num-nodos
Num-nodos
0
200
52
1
1
NIL
HORIZONTAL

SLIDER
7
109
110
142
Num-Aristas
Num-Aristas
0
10 * Num-nodos
60
1
1
NIL
HORIZONTAL

BUTTON
110
76
189
142
Genera Grafo
genera-grafo
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
6
364
178
397
velocidad
velocidad
0
1
1
.1
1
NIL
HORIZONTAL

BUTTON
7
324
177
357
Numera Azar Exahustivo
reset\nrun (word \"Recorrido-azar-exahustivo \" inicio)
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

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
