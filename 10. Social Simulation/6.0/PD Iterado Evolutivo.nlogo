patches-own [
  coopera?         ;; patch coopera
  ha-cooperado?    ;; patch ha cooperado
  puntuacion       ;; puntuación resultante de la interacción con los vecinos
  color-tipo       ;; valor numérico 1= azul, 2= rojo, 3= verde, 4= amarillo
]

to setup
  ca
  ask patches [
    ifelse random-float 1.0 < (cooperacion-inicial / 100)
      [inicia-cooperacion true]
      [inicia-cooperacion false]
    asigna-color
  ]
  actualiza-plot
end

to inicia-cooperacion [value]
  set coopera? value
  set ha-cooperado? value
end

to go
  ask patches [interaccion]             ;; Se lanzan los juegos con los vecinos
  ask patches [selecciona-estrategia]   ;; adopta la estrategia del vecino que tuvo puntuación máxima
  tick
  actualiza-plot
end

to actualiza-plot
  set-current-plot "Frecuencia Cooperación/No Cooperación"
  auxiliar-plot-histograma "cc" blue
  auxiliar-plot-histograma "dd" red
  auxiliar-plot-histograma "cd" green
  auxiliar-plot-histograma "dc" yellow
end

to auxiliar-plot-histograma [lapiz col]
  set-current-plot-pen lapiz
  histogram [color-tipo] of patches with [pcolor = col]
end

to interaccion  ;; procedimiento de patch
  let total-cooperantes count neighbors with [coopera?]             ;; nº total de vecinos que cooperan
  ifelse coopera?
    [set puntuacion total-cooperantes]                              ;; el ccoperante consigue como puntuación el nº de vecinos que cooperan
    [set puntuacion Recompensa-No-Cooperacion * total-cooperantes]  ;; el no-cooperante consigue como puntuación un factor del nº de vecinos que cooperan
end

to selecciona-estrategia ;; procedimiento de patch
  set ha-cooperado? coopera?
  set coopera? [coopera?] of max-one-of neighbors [puntuacion]  ;; escoge como estrategia (cooperar, no cooperar) aquella del vecino que mayor puntuación haya tenido
  asigna-color
end

to asigna-color  ;; procedimiento de patch
  ifelse ha-cooperado?
    [ifelse coopera?
      [set pcolor blue
       set color-tipo 1]
      [set pcolor green
       set color-tipo 3]
    ]
    [ifelse coopera?
      [set pcolor yellow
       set color-tipo 4]
      [set pcolor red
       set color-tipo 2]
    ]
end


; Copyright 2002 Uri Wilensky. All rights reserved.
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
397
10
811
445
50
50
4.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks

BUTTON
23
10
104
43
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

BUTTON
118
10
195
43
NIL
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
5
48
213
81
cooperacion-inicial
cooperacion-inicial
0
100
54.4
0.1
1
%
HORIZONTAL

TEXTBOX
238
17
394
166
Asignación Color por Estrategia\n                              Ronda \n                   Anterior    Actual\nAzul                 C                C\nRojo                D                 D\nVerde              C                 D\nAmarillo           D                 C\n                  C = Coopera \n                  D = No Coopera
11
0.0
0

SLIDER
4
85
214
118
Recompensa-No-Cooperacion
Recompensa-No-Cooperacion
0
3
1.49
0.01
1
x
HORIZONTAL

PLOT
7
158
392
371
Frecuencia Cooperación/No Cooperación
Tipo
Frecuencia (%)
1.0
5.0
0.0
1.0
true
false
PENS
"cc" 1.0 1 -13345367 true
"dd" 1.0 1 -2674135 true
"cd" 1.0 1 -10899396 true
"dc" 1.0 1 -1184463 true

@#$#@#$#@
¿QUÉ ES?
-----------
Uno de los fenómenos más estudiados en Teoría de Juegos es el que se conoce como "Dilema del Prisionero", que fuer formulado por Melvin Drescher y Merrill Flood y llamado así por Albert W. Tucker. Es un ejemplo de una clase de juegos llamados "juegos de suma no nula".

En los juegos de suma nula, el beneficio total de todos los jugadores suma 0, es decir, cada jugador únicamente puede ganar a expensas de que otros jugadores han perdido (p.e., ajedrez, futbol, poker). Sin embargo, en los juegos de suma no nula el beneficio de cada persona no viene necesariamente a expensas de alguien más. En muchas situaciones de suma no nula, una persona puede beneficiarse sólo cuando otros se benefician también. Estas situaciones se presentan cuando el suministro de recursos no está prefijado o viene limitado de alguna forma (p.e., conocimiento, arte, comercio,...). El Dilema del prisionero, como juego de suma no nula, demuestra un conflicto entre el comportamiento racional del individuo y los beneficios de la cooperaciónen siertas circunstancias.

El Dilema del Prisionero (DP) clásico es como sigue:

Tenemos dos sospechosos detenidos por la policia, que no tiene suficientes pruebas para culpabilizarlos. Como resultado, los separa en distintas celdas y les proponen el siguiente trato:  "Si confiesas, y tu cómplice permanece callado, él irá a la cárcel 10 años y tú quedarás en libertad. Si ambos permanecéis callados, solo podremos culparos de cargos menores y ambos iréis a la cárcel 6 meses. Si ambos confesáis, a cada uno os tocará 5 años de cárcel."

Cada sospechoso puede razonar como sigue-- "O mi compañero confiesa o no. Si lo hace y yo me quedo callado, me caerán 10 años, mientras que si confieso, serán 5 años. Por tanto, si mi compañero confiesa, es mejor que yo también lo haga y conseguir únicamente 5 años en vez de 10. Si él no confiesa, entonces, si yo confieso, quedaré en libertad, mientras que si permacezco en silencio, estaré 6 meses. Por tanto, si él no confiesa, es mejor que yo sí lo haga y así estaré en libertad. En consecuencia, confiese o no mi compañero, es mejor que yo lo haga."

En un DP no iterado, los protagonistas no tienen que volver a trabajar juntos, y por tanto ambos razonarán de la forma anterior y decidirán confesar. Consecuentemente, ambos recibirán 5 años de prisión, mientras que si no hubieran confesado, se hubieran llevado 6 meses. El comportamiento racional lleva, paradójicamente, a un resultado socialmente no beneficioso.


|                          Matriz de Beneficios
|                          --------------------
|                               TU COMPAÑERO
|                     Coopera           No Coopera
|                    -----------------------------
|       Cooperas  |   (0.5, 0.5)           (0, 10)
|  TU             |
|       No Coop.  |    (10, 0)              (5, 5)
|
|        (x, y) = x: tu puntuación, y: su puntuación
|        Nota: Cuanto menor puntuación, mejor.


En un DP iterado donde tienes más de dos jugadores y múltiples rondas, como el que se presenta en este modelo, la puntuación suele ser diferente, ya que suponemos que un incremento en el número de personas que cooperan incrementará proporcionalmente el beneficio de cada cooperante (que es correcta, por ejemplo, en el caso del conocimiento). Para aquellos que no cooperan, supondremos que su beneficio es un factor (alpha) multiplicado por el número de personas que cooperan (continuando con el ejemplo anterior, los no cooperantes toman el conocimiento de los otros, pero no comparten el propio). Cómo resulta la cooperación en este proceso va a depender de este factor para la no cooperación. Consecuentemente, en un DP iterado con múltiples jugadores puede resultar interesante observar la dinámica de la cooperación.

|                          Matriz de Beneficios
|                          --------------------
|                                OPONENTE
|                     Coopera           No Coopera
|                    -----------------------------
|       Cooperas  |   (1, 1)            (0, alpha)
|  TU             |
|       No Coop.  | (alpha, 0)           (0, 0)
|
|        (x, y) = x: tu puntuación, y: su puntuación
|        Nota: Cuanto mayor puntuación, mejor.


CÓMO SE USA
--------------
Decide what percentage of patches should cooperate at the initial stage of the simulation and change the INITIAL-COOPERATION slider to match what you would like.  Next, determine the DEFECTION-AWARD multiple (mentioned as alpha in the payoff matrix above) for defecting or not cooperating.  The Defection-Award multiple varies from range of 0 to 3.  Press SETUP and note that red patches (that will defect) and blue patches (cooperate) are scattered across the  .  Press GO to make the patches interact with their eight neighboring patches.  First, they count the number of neighboring patches that are cooperating.  If a patch is cooperating, then its score is number of neighboring patches that also cooperated.   If a patch is defecting, then its score is the product of the number of neighboring patches who are cooperating and the Defection-Award multiple.



¿CÓMO FUNCIONA?
------------
Cada patch cooperará (azul) o no (rojo) como inicio del juego. En cada ciclo, cada patch interactúa con sus 8 vecinos y se determina la puntuación de su interacción. Si un patch ha cooperado, su puntuación será el nº de vecinos que también han cooperado. Si un patch no coopera, su puntuación será el producto de Recompensa-No-Cooperacion por el nº de vecinos que han cooperado (esto es, el patch se aprovecha de la cooperación ajena).

En la siguiente ronda, cada patch almacena su accción en ha-cooperado?. Para la siguiente partida adoptará la estrategia de uno de los vecinos que haya obtenido mator puntuación en la ronda anterior.

Si un patch aparece azul, entonces es que ha cooperado en la ronda previa y en la actual.
Si aparece rojo, es que no cooperó ni en la ronda previa ni en la actual.
Si aparece verde, es que cooperó en la previa, pero no en la actual.
Y si aparece amarillo, es que no cooperó en la previa, pero si ha cooperado en la actual.



COSAS A TENER ENCUENTA
----------------
Observa el efecto que Recompensa-No-Cooperacion juega en el número de patches que cooperarán siempre (azules) o nunca (rojos). ¿Para qué valor es indiferente para un patch cooperar o no?, ¿para qué valor hay una dinámica cambiante entre rojo, azul, verde y amarilla, donde no hay un color que domine finalmente el mundo?

Observa el porcentaje de cooperacion-inicial. Suponiendo que el valor Recompensa-No-Cooperacion es bajo (< 1), si cooperacion-inicial es alto, ¿habrá eventualmente más cooperantes o no cooperantes?, ¿qué ocurre cuando Recompensa-No-Cooperacion es alto?, ¿afecta el valor de cooperacion-inicial?, si es así, ¿cómo?



COSAS A INTENTAR
-------------
Incrementa el valor de Recompensa-No-Cooperacion mientras el modelo se ejecuta y observa cómo el histograma de cada color cambia. En particular, presta atención a las barras de rojos y azules. ¿Puedes apreciar alguna tendencia en ellas? ¿Y si el valor de Recompensa-No-Cooperacion lo decrementas?

En cada comienzo de simulación, ajusta la cooperacion-inicial a valores más extremos, y mueve Recompensa-No-Cooperacion en la misma dirección. ¿Qué color domina el mundo cuando ambos valores son altos?, ¿y cuando son bajos?



EXTENDIENDO EL MODELO
-------------------
Modifica el código para implementar estrategias. Por ejemplo, en vez de decidir en función del mejor vecino, permite que cada patch tenga una historia de sus decisiones y que decida en función de los resultados que ha obtenido.

Implementa estas 4 estrategias:
1.  Coopera-siempre.
2.  Ojo-por-ojo: únicamente coopera con los vecinos si nunca ha sido defraudado. En caso contrario, no coopera.
3.  Ojo-por-ojo-olvidadizo: coopera si en la ronda anterior el otro patch cooperó. Si no, no coopera.
4.  No-coopera-nunca.

¿Cómo se distribuyen los patches cooperantes y no cooperantes? ¿Qué estrategia obtiene la mejor puntuación? ¿En qué condiciones será esta estrategia peor?


HOW TO CITE
-----------
If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:
- Wilensky, U. (2002).  NetLogo PD Basic Evolutionary model.  http://ccl.northwestern.edu/netlogo/models/PDBasicEvolutionary.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:
- Copyright 2002 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/PDBasicEvolutionary for terms of use.


COPYRIGHT NOTICE
----------------
Copyright 2002 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.

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
