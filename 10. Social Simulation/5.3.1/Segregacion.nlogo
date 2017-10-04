globals [
  %-similar  ;; en media, qué % del entorno de una tortuga tienen su mismo color
  %-infeliz  ;; qué porcentaje de las tortugas son infelices
]

turtles-own [
  feliz?       ;; para cada tortuga, indica si la trotuga es feliz, es decir, si al menos
               ;; el porcentaje de similares suyos en su entorno supera el deseado
  entorno-similar   ;; indica cuántas tortugas de su entorno son similares
  entorno-distinto ;; indica cuántas tortugas de su entorno son distintas
  entorno-total  ;; indica cuántas tortugas hay en su entorno (suma de los dos anteriores)
]


to setup
  clear-all
  if poblacion > count patches
    [ user-message (word "El mundo solo tiene sitio para " count patches " tortugas.")
      stop ]

  ;; crea las tortugas 
  let col 15
  repeat grupos
    [
    ask n-of (poblacion / grupos) patches with [not any? turtles-here]
      [sprout 1 [set color col]]
    set col col + 10
    ]
  actualiza-variables
  actualiza-graficos
end

to go
  if all? turtles [feliz?] [ stop ]
  mueve-tortugas-infelices
  actualiza-variables
  tick
  actualiza-graficos
end

to mueve-tortugas-infelices
  ask turtles with [ not feliz? ]
    [ encuentra-nueva-localizacion ]
end

to encuentra-nueva-localizacion
  rt random-float 360
  fd random-float salto
  if any? other turtles-here
    [ encuentra-nueva-localizacion ]          ;; vuelve a buscar una localización si el patch está ocupado
  move-to patch-here  ;; se mueve al centro del patch seleccionado
end

to actualiza-variables
  actualiza-tortugas
  actualiza-globales
end

to actualiza-tortugas
  ask turtles [
    ;; en las próximas líneas, se usa la instrucción "neighbors" para comprobar los 8 patches 
    ;; que circundan el patch actual.
    set entorno-similar count (turtles-on neighbors)
      with [color = [color] of myself]
    set entorno-distinto count (turtles-on neighbors)
      with [color != [color] of myself]
    set entorno-total entorno-similar + entorno-distinto
    set feliz? entorno-similar >= ( %-similar-deseados * entorno-total / 100 )
  ]
end

to actualiza-globales
  let similar-neighbors sum [entorno-similar] of turtles
  let total-neighbors sum [entorno-total] of turtles
  set %-similar (similar-neighbors / total-neighbors) * 100
  set %-infeliz (count turtles with [not feliz?]) / (count turtles) * 100
end

to actualiza-graficos
  set-current-plot "Porcentaje Similar"
  plot %-similar
  set-current-plot "Porcentaje Infeliz"
  plot %-infeliz
end
@#$#@#$#@
GRAPHICS-WINDOW
341
10
708
398
25
25
7.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks

MONITOR
260
441
336
486
% infeliz
%-infeliz
1
1
11

MONITOR
261
298
336
343
% similar
%-similar
1
1
11

PLOT
10
252
259
395
Porcentaje Similar
tiempo
%
0.0
5.0
0.0
100.0
true
false
PENS
"percent" 1.0 0 -2674135 true

PLOT
9
397
258
540
Porcentaje Infeliz
tiempo
%
0.0
5.0
0.0
100.0
true
false
PENS
"percent" 1.0 0 -10899396 true

SLIDER
19
22
231
55
poblacion
poblacion
500
2500
1410
10
1
NIL
HORIZONTAL

SLIDER
19
59
231
92
%-similar-deseados
%-similar-deseados
0
100
27
1
1
%
HORIZONTAL

BUTTON
64
171
184
204
Preparar Mundo
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
85
211
165
244
Ejecutar
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
20
96
232
129
grupos
grupos
1
10
7
1
1
NIL
HORIZONTAL

SLIDER
21
134
232
167
salto
salto
1
20
20
1
1
NIL
HORIZONTAL

@#$#@#$#@
¿QUÉ ES?
-----------
Este proyecto modela el comportamiento de una población de agentes de diversos grupos en una zona imaginaria. Todas los grupos coexisten en la misma zona, pero cada uno de ellos quiere estar seguro de que vive cerca de una cantidad mínima de su propio grupo. La simulación muestra cómo las prefeerncias individuales se trasnmiten a lo largo de toda la región, produciendo patrones globales.

Este proyecto está inspirado en los artículos sobre sistemas sociales de Thomas Schelling.


¿CÓMO SE USA?
-------------
Tras haber fijado los parámetros del experimento, haz click en el botón "Preparar Mundo". Se generarán tantos agentes como indique la barra "POBLACION", aleatoriamente distribuidos por la región, y uniformemente distribuidos por grupos (es decir, igual cantidad en cada grupo). Cada grupo se diferencia por el color de sus agentes. Haz clicg en "Ejecutar" para comenzar la simulación. Si los agentes no tienen suficientes vecinos del mismo color, saltarán a otro patch cercano (la longitud del salto dependerá del valor de "SALTO").

El control "%-SIMILAR-DESEADOS" controla el porcentaje mínimo de gentes del mismo color que cada agente quiere entre sus vecino. Por ejemplo, si dicho control está en 30, cada agente requerirá de, al menos, un 30% de sus vecinos iguales que él.

El monitor "% SIMILAR" muestra la media de los porcentajes de vecinos del mismo color que tiene cada agente. El monitor "% INFELIZ" muestra el porcentaje de agentes que tienen menos vecinos del mismo grupo de los deseados (y que, por tanto, querrán mudarse). Ambos monitores se actualizan en tiempo real.


COSAS A TENER EN CUENTA
----------------
A medida que los agentes se mueven porque están infelices en su residencia actual, mofician el valor de felicidad de los restantes agentes, de forma que las acciones de cada uno de los agentes (que se toman de forma individualizada) acaban afectando al global de la población.

Obsevarás que, bajo muchas de las condiciones iniciales, el número de agentes felices decrece, pero el mundo comienza a aparecer segregado, con diferentes regiones en las que las poblaciones esta´n formadas por un solo grupo.

Por ejemplo, en el caso de estar trabajando solo con 2 grupos, y exigiendo un porcentaje de similitud del 30% (relativamente bajo), termina surgiendo una distribución en la que (en media) todos los agentes acaban con un 70% de vecinos del mismo grupo. Por tanto, un nivel de exigencia erlativamente bajo provoca una segregación global bastante significativa, sin necesidad de que haya un plan global de segregación ni una tendencia fuerte de sus individuos a dicha situación.


COSAS A INTENTAR
-------------
Prueba diferentes valores para cada parámetro, principalmente juega a mover los valores de %-SIMILAR-DESEADO. ¿Cómo cambia el grado global de segregación?

Comprueba cómo cambia este efecto cuando permitimos que en el mundo haya más grupos diferenciados.

Comprueba cómo afecta la variable SALTO a la velcocidad de convergencia del sistema (es decir, en cuántos pasos el sistema se mantiene estable y ya nadie desea cambiar de residencia).


EXTENDIENDO EL MODELO
-------------------
Hay muchas formas de extender el modelo, prácticamente cualquer idea que se nos ocurra puede provocar una mayor riqueza en el mismo. Por ejemplo, conceptos como la introducción de ruido de fondo (es decir, perturbar el conocimiento que tiene un agente de su entorno de forma aleatoria), introduciendo prejuicios (valores globales que tienden a modificar el peso positivo o negativo que ciertos grupos pueden tener para calcular la función de felicidad), etc... pueden ser fácilmente introducidos.
 
Incorpora redes sociales al modelo.  Por ejemplo, permite que los agentes cambien de posición conociendo información de otros agentes acerca de cómo son sus respectivos entornos (aquí puedes elegir que ese conocimiento lo adquieran únicamente de agentes de su mismo grupo o de otros grupos).

Utiliza topologías distintas como soporte del mundo en el que se mueven los agentes. En el caso aquí presentado la topología que usan los agentes es el de una malla cudrangular.

CARACTERÍSTICAS NETLOGO
----------------
Fíjate en la forma en que se generan los diversos grupos de agentes para evitar que se pisen unos sobre otros.

Cuando se mueve un agente, se usa MOVE-TO para situarlo en el centro del patch que encuentre libre.

CREDITOS Y REFERENCIAS
----------------------
Este modelo es una modificación del que viene originalmente en la biblioteca de modelos de la distribución de NetLogo (segregation.nlogo).

Como referencias acerca de sus fundamentos teóricos, acude a la bibliografía del curso.
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
NetLogo 4.1.3
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
