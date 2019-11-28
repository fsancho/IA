extensions [rnd]

globals [ mejor-recorrido
          coste-mejor-recorrido ]

breed [ nodos nodo ]
breed [ hormigas hormiga ]

links-own [ coste
            feromona ]

hormigas-own [ recorrido
               coste-recorrido ]

;;;;;;;;;;;;;;;:::::;;;;;;;;
;;; Procedimientos Setup ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape nodos "circle"
  ask patches [set pcolor white]

  crea-nodos
  crea-aristas
  crea-hormigas

  set mejor-recorrido camino-aleatorio
  set coste-mejor-recorrido longitud-de mejor-recorrido
  muestra-mejor-recorrido

  reset-ticks
end

to crea-nodos
  ask n-of num-nodos patches
  [
    sprout-nodos 1
    [
      set color blue + 2
      set size 2
    ]
  ]
end

to crea-aristas
  ask nodos
  [
    create-links-with other nodos
    [
      hide-link
      set color red
      set coste link-length
      set feromona random-float 0.1
    ]
  ]
  let max-coste max [coste] of links
  ask links
  [
    set coste coste / max-coste
  ]
end

to crea-hormigas
  create-hormigas num-hormigas [
    hide-turtle
    set recorrido []
    set coste-recorrido 0
  ]
end

to reset
  ask hormigas [die]
  ask links [
    hide-link
    set feromona random-float 0.1
  ]
  crea-hormigas

  set mejor-recorrido camino-aleatorio
  set coste-mejor-recorrido longitud-de mejor-recorrido
  muestra-mejor-recorrido

  reset-ticks
  clear-all-plots
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedimiento Principal ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  no-display
  ask hormigas [
    set recorrido generar-recorrido
    set coste-recorrido longitud-de recorrido

    if coste-recorrido < coste-mejor-recorrido [
      set mejor-recorrido recorrido
      set coste-mejor-recorrido coste-recorrido
      muestra-mejor-recorrido
    ]
  ]

  actualiza-feromona
  tick
  dibuja-plots
  display
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedimientos para encontrar recorridos ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report camino-aleatorio
  let resp [self] of nodos
  report lput (first resp) resp
end

to-report generar-recorrido
  let origen one-of nodos
  let nuevo-recorrido (list origen)
  let resto-nodos nodos with [self != origen]
  let nodo-actual origen

  while [any? resto-nodos] [
    let siguiente-nodo rnd:weighted-one-of resto-nodos [peso-desde nodo-actual]
    set nuevo-recorrido lput siguiente-nodo nuevo-recorrido
    set resto-nodos resto-nodos with [self != siguiente-nodo]
    set nodo-actual siguiente-nodo
  ]
  set nuevo-recorrido lput origen nuevo-recorrido

  report nuevo-recorrido
end


; Calcula el peso de un nodo (reporte de nodo) desde el nodo actual
; Nota: no es una probabilidad porque no está normalizada. Eso lo hace
; la función rnd:weighted-one-of al conocer el conjunto de nodos sobre
; el que trabaja
to-report peso-desde [nodo-actual]
  let a arista nodo-actual self
  report ([feromona] of a ^ alpha) * ((1 / [coste] of a) ^ beta)
end

to actualiza-feromona
  ;; Evapora la feromona del grafo
  ask links [
    set feromona (feromona * (1 - rho))
  ]

  ;; Añade feromona a los caminos encontrados por las hormigas
  ask hormigas [
    let inc-feromona (100 / coste-recorrido)
    ask (aristas-de recorrido) [ set feromona (feromona + inc-feromona) ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedimientos Plot/GUI ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Muestra el mejor recorrido obtenido, ocultando las aristas
; que no pertenecen a él
to muestra-mejor-recorrido
  ask links [ hide-link ]
  ask (aristas-de mejor-recorrido) [ show-link ]
end

; Muestra la feromona de cada arista (en grosor y opacidad)
to muestra-feromona
  let M max [feromona] of links
  ask links [
    set label ""
    show-link
    set thickness feromona / M
    set color lput (255 * feromona / M) [255 0 0]
  ]
  display
end

to dibuja-plots
  set-current-plot "Coste Mejor Recorrido"
  plot coste-mejor-recorrido

  set-current-plot "Distribución Costes de Recorridos"
  set-plot-pen-interval .1
  set-plot-x-range 0 int (2 * coste-mejor-recorrido)
  histogram  [coste-recorrido] of hormigas
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedimientos auxiliares ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Devuelve el conjunto de aristas que intervienen en un recorrido (agentset)
to-report aristas-de [r]
  report link-set (map [[x y] -> arista x y] r (lput (first r) (bf r)))
end

; Devuelve la arista que conecta n1 con n2 (son nodos)
to-report arista [n1 n2]
  report (link ([who] of n1) ([who] of n2))
end

; Devuelve la longitud de un recorrido
to-report longitud-de [r]
  report sum [coste] of (aristas-de r)
end
@#$#@#$#@
GRAPHICS-WINDOW
245
10
679
445
-1
-1
6.0
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
70
0
70
1
1
1
ticks
30.0

BUTTON
10
10
125
43
Setup
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
127
115
242
148
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
400
125
445
Mejor Recorrido
coste-mejor-recorrido
3
1
11

PLOT
10
151
240
271
Coste Mejor Recorrido
Tiempo
Coste
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
10
275
240
395
Distribución Costes de Recorridos
Coste
Nº Hormigas
0.0
50.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" ""

SLIDER
10
80
125
113
alpha
alpha
0
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
127
80
242
113
beta
beta
0
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
115
125
148
rho
rho
0
0.99
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
10
45
125
78
num-nodos
num-nodos
0
100
36.0
1
1
NIL
HORIZONTAL

SLIDER
127
45
242
78
num-hormigas
num-hormigas
0
100
32.0
1
1
NIL
HORIZONTAL

BUTTON
127
10
242
43
Reset
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

BUTTON
130
400
240
445
Feromona
muestra-feromona
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
##¿QUÉ ES?

Este modelo es una implementación del algoritmo AS (Ant System) aplicado a la resolución del Problema del Viajante.

##¿CÓMO FUNCIONA?

El algoritmo AS se puede usar para encontrar el camino más corto en un grafo por medio del mismo mecanismo descentralizado que usan las hormigas para recolectar comida. En el modelo, cada agente (hormiga)construye un camino en el grafo decidiendo en cada nodo qué nodo visitará a continuación de acuerdo a una probabilidad asociada a cada arista. La probabilidad de que una hormiga escoja un nodo específico en un momento viene determinada por la cantidad de feromona y por el coste de la arista que une dicho nodo con el nodo en el que la hormiga esté actualmente.

En el modelo se pueden ajustar los parámetros del algoritmo (alpha, beta y rho)para modificar el comportamiento del algoritmo. Los valores alpha y beta se usan para determinar la probabilidad de transición de la que se ha hablado antes, afectando la influencia relativa entre la feromona de cada arista y el coste que tiene. El valor de rho está asociado a la tasa de evaporación de feromona que permite al algoritmo "olvidar" aquellos tramos que no son muy visitados porque no han intervenido en recorridos buenos.

##¿CÓMO SE USA?

Selecciona el número de nodos, el número de hormigas que recorrerán el grafo, y los parámetros que se usarán para la ejecución del algoritmo. Pulsa SETUP para crear los componentes que se usarán en la ejecución del algoritmo. GO para ejecutarlo, y RESET para mantener el mismo grafo y poder modificar el resto de parámetros (lo que permite hacer comparaciones entre los parámetros sobre el mismo grupo de datos).

ALPHA controla la tendencia de las hormigas para explotar caminos con altas cantidades de feromona. BETA controla cómo de "tacañas" son las hormigas, es decir, si tienen tendencia alta a buscar aristas de bajo coste (aunque a veces no sea bueno).

## COSAS A TENER EN CUENTA

En el modelo se muestran dos plots para visualizar la ejecución del algoritmo. Por una parte, en uno se muestra el coste del mejor recorrido encontrado en cada paso, mientras que en el segundo se muestra cómo se distribuyen las hormigas en el espacio de soluciones (un histograma de número de hormigas respecto del coste de sus caminos)

## COSAS A INTENTAR

De acuerdo con [1], los resultados empíricos muestra que los valores óptimos son: alpha = 1, beta = 5, rho = 0.5. Intenta comprobar cómo estos parámetros afectan a la eficiencia del resultado. Comprueba si hay tendencias a óptimos locales que no sean globales. Estudia la distribución de costes para ver si los cambios en la tasa de evaporación tienen algún tipo de repercusión.

## REFERENCIAS

 * Roach, Christopher (2007).  NetLogo Ant System model. Computer Vision and Bio-inspired Computing Laboratory, Florida Institute of Technology, Melbourne, FL.

 * Dorigo, M., Maniezzo, V., and Colorni, A., The Ant System: Optimization by a colony of cooperating agents.  IEEE Transactions on Systems, Man, and Cybernetics Part B: Cybernetics, Vol. 26, No. 1. (1996), pp. 29-41. http://citeseer.ist.psu.edu/dorigo96ant.html

 * http://www.tsp.gatech.edu/
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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>best-tour-cost</metric>
  </experiment>
</experiments>
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
