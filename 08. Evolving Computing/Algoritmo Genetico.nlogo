;; Cada soluci�n potencial est� representada por una tortuga

turtles-own [
  bits           ;; lista de 0's y 1's
  fitness
]

globals [
  ganador         ;; tortuga que actualmente tiene la mejor soluci�n
]

to setup
  ca
  reset-ticks
  create-turtles poblacion [
    set bits n-values world-width [one-of [0 1]]
    calcular-fitness
    hide-turtle  ;; No se usa la representaci�n de las tortugas, as� que las ocultamos
  ]
  actualizar-visualizacion
  dibujar
  reset-ticks
end

to go
  if [fitness] of ganador = world-width
    [ stop ]
  crear-siguiente-generacion
  actualizar-visualizacion
  tick
  dibujar
end

to actualizar-visualizacion
  set ganador max-one-of turtles [fitness]
  ask patches [
    ifelse item pxcor ([bits] of ganador) = 1
      [ set pcolor white ]
      [ set pcolor black ]
  ]
end

;; ===== Generar Soluciones

;; Cada soluci�n tiene su valor de fitness calculado.
;; Valores m�s altos representan mejor adaptados.
;; Por tanto, cuanto mayor es su fitness, mayor es la probabilidad
;;   de que ser� seleccionada para reproducirse y crear una nueva
;;   generaci�n de posibles soluciones.
;;
to calcular-fitness       ;; procedimiento de tortuga
  ;; En este caso, la funci�n de fitness mide cu�ntos 1's tiene la posible soluci�n.
  ;; Basta modificar esta funci�n para resolver problemas m�s interesantes.
  set fitness length (remove 0 bits)
end

;; Este procedimiento hace el trabajo principal del algoritmo gen�tico.
;; Se parte de la generaci�n anterior de soluciones.
;; Se seleccionan las soluciones que tienen buen fitness para reproducirse
;; por medio del cruzamiento (recombinaci�n sexual), y para ser clonadas
;; (reproducci�n asexual) en la siguiente generaci�n.
;; Hay tambi�n una opci�n de mutaci�n en cada individuo.
;; Tras generar completamente la nueva generaci�n, la generaci�n previa muere.
to crear-siguiente-generacion
  ; Hacemos una copia de las tortugas que hay en este momento.
  let generacion-anterior turtles with [true]

  ; Algunas de las soluciones actuales se conseguir� por medio del cruzamiento,
  ; Se divide entre 2 porque en cada paso del bucle se generan 2 nuevas soluciones.
  let numero-cruzamientos  (floor (poblacion * razon-cruzamiento / 100 / 2))

  repeat numero-cruzamientos
  [
    ; Se ha usado una selecci�n por torneo, con un tama�o de 3 elementos.
    ; Es decir, se toman aleatoriamente 3 soluciones de la generaci�n previa
    ; y nos quedamos con el mejor de esos 3 para la reproducci�n.

    let padre1 max-one-of (n-of 3 generacion-anterior) [fitness]
    let padre2 max-one-of (n-of 3 generacion-anterior) [fitness]

    let bits-hijo cruzamiento ([bits] of padre1) ([bits] of padre2)

    ; crea 2 hijos con sus informaciones gen�ticas
    ask padre1 [ hatch 1 [ set bits item 0 bits-hijo ] ]
    ask padre2 [ hatch 1 [ set bits item 1 bits-hijo ] ]
  ]

  ; el resto de la poblaci�n se crea por clonaci�n directa
  ; de algunos miembros seleccionados de la generaci�n anterior
  repeat (poblacion - numero-cruzamientos * 2)
  [
    ask max-one-of (n-of 3 generacion-anterior) [fitness]
      [ hatch 1 ]
  ]

  ; Eliminamos toda la generaci�n anterior
  ask generacion-anterior [ die ]

  ; y sobre el resto de tortugas (generaci�n reci�n generada)...
  ask turtles
  [
    ; realizamos la mutaci�n (es un proceso probabil�stico)
    mutar
    ; y actualizamos su valor de fitness
    calcular-fitness
  ]
end

;; ===== Cruzamientos y Mutaciones

;; La siguiente funci�n realiza un cruzamiento (en un punto) de dos
;; listas de bits: a,b. Estos es, selecciona aleatoriamente un punto en
;; ambas listas: a1|a2, b1|b2, donde long(ai)=long(bi)
;; y devuelve: a1|b2, b1|a2
to-report cruzamiento [bits1 bits2]
  let punto-corte 1 + random (length bits1 - 1)
  report list (sentence (sublist bits1 0 punto-corte)
                        (sublist bits2 punto-corte length bits2))
              (sentence (sublist bits2 0 punto-corte)
                        (sublist bits1 punto-corte length bits1))
end

;; El siguiente procedimiento povoca la mutaci�n aleatoria de los bits de una
;; soluci�n. La probabilidad de modificar cada bit se controla por medio del
;; slider RAZON-MUTACION.
to mutar   ;; procedimiento de tortuga
  set bits map [ b -> ifelse-value (random-float 100.0 < razon-mutacion) [1 - b] [b] ]
               bits
end

;; ===== Medidas de diversidad

;; La medida de diversidad que se proporciona es la media de las distancias de
;; Hamming entre todos los pares de soluciones.
to-report diversidad
  let distancias []
  ask turtles [
    let bits1 bits
    ask turtles with [self > myself] [
      set distancias fput (distancia-hamming bits bits1) distancias
    ]
  ]
  ; Necesitamos conocer la mayor posible distancia de Hamming entre pares de
  ; bits de este tama�o. La siguiente f�rmula se intepreta de la siguient forma:
  ; Imaginemos una poblaci�n de N tortugas, con N par, y cada tortuga tiene un
  ; �nico bit (0 o 1). La mayor diversidad se tiene si la mitad de la poblaci�n
  ; tiene 0, y la otra mitad tiene 1 (se puede calcular por c�lculo diferencial).
  ; En este caso, hay (N / 2) * (N / 2) pares de bits que difieren.
  ; Se puede probar que esta f�rmula (tomando parte entera) tambi�n vale cuando
  ; N es impar.
  let max-posibles-distancias floor (count turtles * count turtles / 4)

  ; A partir del valor anterior podemos normalizar la medida de diversidad para que
  ; tome un valor entre 0 (poblaci�n completamente homog�nea) y 1 (heterogeneidad
  ; m�xima)
  report (sum distancias) / max-posibles-distancias
end

;; La distancia de Hamming entre dos sucesiones de bits es la fracci�n de
;; posiciones en las que difieren. Se usa MAP para comparar las sucesiones,
;; posteriormente REMOVE para quitar los resultados de igualdad, y LENGTH
;; para contar los que quedan (las diferencias).
to-report distancia-hamming [bits1 bits2]
  report (length remove true (map [ [b1 b2] -> b1 = b2 ] bits1 bits2)) / world-width
end

;; ====== Plotting

to dibujar
  let lista-fitness [fitness] of turtles
  let mejor-fitness max lista-fitness
  let media-fitness mean lista-fitness
  let peor-fitness min lista-fitness
  set-current-plot "Fitness"
  set-current-plot-pen "media"
  plot media-fitness
  set-current-plot-pen "mejor"
  plot mejor-fitness
  set-current-plot-pen "peor"
  plot peor-fitness
  if plot-diversidad?
  [
    set-current-plot "Diversidad"
    set-current-plot-pen "diversidad"
    plot diversidad
  ]
end


; Copyright 2008 Uri Wilensky. All rights reserved.
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
190
135
471
154
-1
-1
2.73
1
10
1
1
1
0
1
1
1
0
99
0
3
1
1
1
ticks
30.0

BUTTON
100
50
185
83
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
1

BUTTON
12
10
185
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
1

SLIDER
12
90
184
123
poblacion
poblacion
5
200
100.0
5
1
NIL
HORIZONTAL

PLOT
190
10
473
130
Fitness
gen #
fitness
0.0
20.0
0.0
101.0
true
true
"" ""
PENS
"mejor" 1.0 0 -2674135 true "" ""
"media" 1.0 0 -10899396 true "" ""
"peor" 1.0 0 -13345367 true "" ""

BUTTON
12
50
97
83
Un paso
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

SLIDER
12
170
184
203
razon-mutacion
razon-mutacion
0
10
0.5
0.1
1
NIL
HORIZONTAL

PLOT
190
180
472
300
Diversidad
gen #
diversidad
0.0
20.0
0.0
1.0
true
false
"" ""
PENS
"diversidad" 1.0 0 -8630108 true "" ""

SWITCH
12
212
184
245
plot-diversidad?
plot-diversidad?
0
1
-1000

SLIDER
12
130
184
163
razon-cruzamiento
razon-cruzamiento
0
100
70.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
�QU� ES?

Este modelo muestra el uso de un algoritmo gen�tico en un problema muy simple. Los algotismo gen�ticos (GA) son t�cnicas de computaci�n bio-inspiradas que combinan nociones de gen�tica de Mendel con la teor�a evolutiva de Darwin para buscar buenas soluciones a problemas (incluso problemas complicados). Los GA funcionan generando una poblaci�n aleatoria de soluciones a un problema, evaluando dichas soluciones y usando clonaci�n, recombinaci�n y mutaci�n para crear nuevas soluciones al problema.

En este ejemplo se usa el problema "TODOS-UNOS" para demostrar su uso: encontrar una cadena que sea todo unos, "111111...111".

C�MO FUNCIONA

El Algoritmo Gen�tico esta formado por los siguientes pasos.

1) Se crea una poblaci�n aleatoria de soluciones. Cada soluci�n est� formada por una cadena aleatoria de "1"s y "0"s.

2) Cada soluci�n se eval�a en en funci�n de lo bien que resuelve el problema. Esta medida de la "bondad" de la soluci�n se llama "fitness". En este modelo el objetivo es encontrar una soluci�n que tenga todo "1"s.  (En aplicaciones en el mundo real los objetivos son mucho m�s complejos, pero las soluciones suelen estar codificadas tambi�n como cadenas binarias.)

3) Se crea una generaci�n nueva de soluciones a partir de la generaci�n anterior, donde aquellas soluciones que tengan un fitness m�s alto tienen m�s probabilidad de ser escogidos como padres de las nuevas soluciones.

A) El m�todo de selecci�n usado en el modelo es el de torneo de tama�o 3, lo que significa que se toman aleatoriamente 3 soluciones de la generaci�n anterior, y de entre ellos se toma el que tenga mejor fitness para ser uno de los padres de la siguiente generaci�n.

B) Se toman uno o dos padres para crear un hijo nuevo. Con un padre, el hijo es un clon exacto de su padre. Con dos padres, se produce una recombinaci�n de su informaci�n gen�tica para obtener dos hijos.

C) Tambi�n hay una probabilidad de mutaci�n en cada una de las soluciones, de forma que algunos de los bits son cambiados.

4) Los pasos 2 y 3 anteriores se repiten hasta que se encuentra una soluci�n que satisface el problema.

C�MO SE USA

Pulsa SETUP para crear una poblaci�n aleatoria inicial de soluciones.

Pulsa UN PASO para obtener una nueva generaci�n a partir de la generaci�n actual.

Pulsa GO para aplicar el algoritmo gen�tico hasta que se encuentre una soluci�n.

Se muestra la mejor soluci�n de cada geenraci�n en la ventana VIEW. Cada columna blanca representa un bit "1", y cada columna negra es un bit "0".

Par�metros:

El slider POBLACION controla el n�mero de soluciones que est�n presentes en cada generaci�n.

La RAZON-CRUZAMIENTO controla el porcentaje de individuos de la nueva generaci�n que ser�n creados por medio de reproducci�n sexual (usando 2 padres) y el porcentaje que lo har� por medio de reproducci�n asexual (clonaci�n directa).

La RAZON-MUTACION controla el porcentaje de cambio por mutaci�n. Esta cantidad se aplica a cada posici�n de cada cadena de los nuevos individuos. Por ejemplo, si la cadena tiene longitus de 100 bits, y la mutaci�n es del 1%, entonces en media se cambiar� 1 bit durante la creaci�n de cada nuevo individuo.

El switch PLOT-DIVERSIDAD? controla si la cantidad de diversidad en la poblaci�n de soluciones debe ser calculada y representada en cada generaci�n. Es un proceso que requiere mucho c�lculo, por lo que al desactivarlo se incrementa considerablemente la velocidad del modelo.

El plot "Fitness" se usa para mostrar el mejor, medio y peor fitness de los individuos de cada generaci�n.

## COSAS A TENER EN CUENTA

Ve avanzando paso a paso por la ejecuci�n y observa la representaci�n de la mejor soluci�n encontrada en cada generaci�n. �C�mo de frecuente es que la mejor soluci�n del paso x+1 sea descendiente de la mejor soluci�n de la genraci�n x?

A medida que el fitness de la poblaci�n crece, la diversidad decrece, �Por qu� ocurre esto?

## COSAS A INTENTAR

Explora los efectos de poblaciones mayores o menores en el n�mero de generaciones necesarias para resolver el problema completamente. �Qu� ocurre si se mide el tiempo (en segundos) que lleva resolver el problema completamente?

�C�mo se compara la reproducci�n asexual a la sexual en la resoluci�n del problema? (�Qu� ocurre si RAZON-CRUZAMIENTO es 0 o 100?)

�C�mo de beneficiosa es la mutaci�n para el GA?, �puede funcionar perfectamente si la RAZON-MUTACION en 0?, �y si es 10.0?, �puedes encontrar un valor �ptimo de este par�metro?

## EXTENDIENDO EL MODELO

Existen muchas variantes para este GA simple. Por ejemplo, algunos algoritmos gen�ticos incluyen "elitismo"... en este caso, las mejores X% soluciones de la generaci�n anterior se copian directamente en la nueva generaci�n. Modifica este modelo para que haga uso del elitismo.

Otro tipo de selecci�n para la reproducci�n que a veces se usa en GA es la llamada "selecci�n por ruleta". En este caso, a cada soluci�n de la poblaci�n se le asigna una probabilidad que es directamnete proporcional a su valor de fitness. Intenta implementar este tipo de selecci�n y compara su funcionamiento con la selecci�n por torneo que viene implementado en este modelo.

Como ya se ha comentado, el problema que se resuelve en este modelo es de juguete y muy simple. Afortunadamente, para atacar otro problema solo has de modificar una cosa, la funci�n de fitness,  que eval�a c�mo de buena es la cadena de bits para resolver el problema. Por ejemplo, podr�as hacer evolucionar las reglas necesarias para que una tortuga se mueva por el mundo con el fin de maximizar la recolecci�n de comida que se encuentra por el mundo. Para hacerlo, la funci�n que calcula el fitness debe ejecutar una peque�a simulaci�n que haga que una tortuga se mueva en el mundo y mida su eficiencia.

CARACTER�STICAS NETLOGO

Obs�rvese que la sencillez con que se ha implementado la selecci�n por torneo, por ejemplo, se debe a la potencia de NetLogo para implementar ciertas operaciones. Por ejemplo, el c�digo siguiente hace todo el trabajo por nosotros:

      max-one-of (n-of 3 old-generation) [ga-fitness]


## RELATED MODELS

Echo is another model that is inspired by the work of John H. Holland.  It examines issues of evolutionary fitness and natural selection.

There are several NetLogo models that examine principles of evolution from a more biological standpoint, including Altruism, Bug Hunt Camouflage, Cooperation, Mimicry, Peppered Moths, as well as the set of Genetic Drift models.

Sunflower Biomorph uses an artistic form of simulated evolution, driven by aesthetic choices made by the user.

## CREDITS AND REFERENCES

This model is based off of work by John H. Holland, who is widely regarded as the father of the genetic algorithms.  See Holland's book "Adaptation in Natural and Artificial Systems", 1992, MIT Press.

Additional information about genetic algorithms is available from a plethora of sources online.

## HOW TO CITE

If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:  
- Stonedahl, F. and Wilensky, U. (2008).  NetLogo Simple Genetic Algorithm model.  http://ccl.northwestern.edu/netlogo/models/SimpleGeneticAlgorithm.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.  
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  
- Copyright 2008 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/SimpleGeneticAlgorithm for terms of use.

## COPYRIGHT NOTICE

Copyright 2008 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:  
a) this copyright notice is included.  
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.
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
NetLogo 6.0.4
@#$#@#$#@
need-to-manually-make-preview-for-this-model
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
