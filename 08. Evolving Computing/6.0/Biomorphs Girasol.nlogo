;; Los germenes son tortugs ocultas en el centro de cada "flor" que generan
;; continuamente p�talos (que son los visibles)
breed [germenes germen]
breed [petalos petalo]

globals [
  primer-padre     ;; El pimer padre, en caso de q la reproducci�n sea sexual
]

germenes-own [
  numero-colores  ;; Cu�ntos colores tendr�n los p�talos
  inc-paso        ;; C�mo de r�pido se mueven los p�talos hacia afuera (crecimiento de la flor)
  inc-giro        ;; Cu�nto se gira un p�talo antes de ser movido hacia afuera
  inc-tamano      ;; C�mo de r�pido crecen los p�talos al alejarse
]

petalos-own [
  inc-paso        ;; Igual que con los g�rmenes
  inc-tamano      ;; Igual que con los g�rmenes
  padre           ;; germen origen del p�talo actual (la distancia entre ellos
                  ;;  permite calcula, por ejemplo, las variaciones de tama�o)
]

to setup
  ca
  reset-ticks
  create-germenes filas * columnas
  [
    set numero-colores random 14 + 1
    set inc-paso random-float 0.5
    set inc-giro random-float 4.0
    set inc-tamano random-float 2.0
    hide-turtle        ;; los g�rmenes permanecen ocultos
  ]
  ordena-germenes
  set primer-padre nobody
end

to ordena-germenes
  ;; ordena los g�rmenes en el mundo en una malla
  let i 0
  while [i < filas * columnas]
  [
    ask turtle i
    [
      let x-int world-width / columnas
      let y-int world-height / filas
      setxy (-1 * max-pxcor + x-int / 2 + (i mod columnas) * x-int)
            (max-pycor + min-pycor / filas - int (i / columnas) * y-int)
    ]
    set i i + 1
  ]
end

to go
  ask germenes
  [
    hatch-petalos 1
    [
      set padre myself
      set color 10 * (ticks mod ([numero-colores] of padre + 1)) + 15
      rt ticks * [inc-giro] of padre * 360
      set size 0
      show-turtle  ;; el p�talo hereda la invisibilidad del padre g�rmen, por lo
                   ;; que hemos de hacerlo visible de nuevo
    ]
  ]
  ask petalos
  [
    fd inc-paso
    set size inc-tamano * sqrt distance padre
    ;; mata los p�talos cuando comienzan a interferir a p�talos de otras flores
    if abs (xcor - [xcor] of padre) > max-pxcor / (columnas * 1.5) [ die ]
    if abs (ycor - [ycor] of padre) > max-pycor / (filas * 1.5) [ die ]
  ]
  tick
  if mouse-down? [ manejar-pulsacion-raton ]
end

to repoblar-a-partir-de-dos [padre1 padre2]
  ask petalos [ die ]
  ask germenes
  [
    ;;Si mutacion-controlada? entonces la mutaci�n que experimenta una flor es relativa al valor de who de su germen
    if mutacion-controlada? [set mutacion who * 1 / (filas * columnas)]

    ;; selecciona un valor de uno de los padre para cada una de las cuatro variables (genes)
    set numero-colores ([numero-colores] of one-of list padre1 padre2) + int random-normal 0 (mutacion * 10) mod 15 + (1)
    set inc-paso ([inc-paso] of one-of list padre1 padre2) + random-normal 0 (mutacion / 5)
    set inc-giro ([inc-giro] of one-of list padre1 padre2) + random-normal 0 (mutacion / 20)
    set inc-tamano ([inc-tamano] of one-of list padre1 padre2) + random-normal 0 mutacion

    ;;Se acotan los valores de inc-tamano para que las flores no sean demasiado grandes
    if inc-tamano > 1.5 [set inc-tamano 1.5]
  ]
end

to repoblar-a-partir-de-uno [padre1]
  ; Equialente al anterior, pero tomando los caracteres del �nico padre que tiene
  ask petalos [ die ]
  ask germenes
  [
    if mutacion-controlada? [ set mutacion who * 1 / (filas * columnas) ]
    set numero-colores ([numero-colores] of padre1 + int random-normal 0 (mutacion * 10)) mod 15 + 1
    set inc-paso [inc-paso] of padre1 + random-normal 0 (mutacion / 5)
    set inc-giro [inc-giro] of padre1 + random-normal 0 (mutacion / 20)
    set inc-tamano [inc-tamano] of padre1 + random-normal 0 mutacion

    if inc-tamano > 1.5 [ set inc-tamano 1.5 ]
  ]
end

to manejar-pulsacion-raton
  ;; se queda con el germen m�s cercano al lugar en que se ha pulsado
  let new-padre min-one-of germenes [distancexy mouse-xcor mouse-ycor]
  ifelse asexual?
  [ repoblar-a-partir-de-uno new-padre ]
  [
    ifelse primer-padre != nobody
    [
      repoblar-a-partir-de-dos primer-padre new-padre
      set primer-padre nobody
      ask patches [ set pcolor black ]
    ]
    [
      set primer-padre new-padre
      ask patches
      [
        ;; Como  algunos patches pueden estar equidistantes de m�s de un
        ;; germen, no podemos preguntar por el m�s cercano, sino que
        ;; tenemos que preguntar por todos los m�s cercanos y ver si
        ;; el germen sobre el que se ha pulsado est� entre ellos
        if member? new-padre germenes with-min [distance myself]
          [ set pcolor gray - 3 ]
      ]
    ]
  ]
  ;; hay que esperar a que el usuario suelte el bot�n del rat�n
  while [mouse-down?] [ ]
end


; Copyright 2006 Uri Wilensky. All rights reserved.
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
198
10
750
563
-1
-1
15.543
1
10
1
1
1
0
0
0
1
-17
17
-17
17
1
1
1
ticks
30.0

BUTTON
11
107
94
140
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

BUTTON
102
107
182
140
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

SLIDER
10
33
182
66
filas
filas
1.0
10.0
7.0
1.0
1
NIL
HORIZONTAL

SLIDER
10
67
182
100
columnas
columnas
1.0
10.0
7.0
1.0
1
NIL
HORIZONTAL

SLIDER
10
145
182
178
mutacion
mutacion
0.0
1.0
0.7346938775510204
0.02
1
NIL
HORIZONTAL

SWITCH
10
193
161
226
asexual?
asexual?
1
1
-1000

SWITCH
10
227
161
260
mutacion-controlada?
mutacion-controlada?
0
1
-1000

@#$#@#$#@
�QU� ES?

Este proyecto presenta un modelo de evoluci�ndonde el usuario realiza el proceso selectivo por medio del rat�n. Para ello, debe pulsar sobre una o dos de los individuos (flores) de la malla que muestra la poblaci�n actual. Las flores seleccionadas se convierten en los "padres" de la siguiente generaci�n, de esta forma, puede ir dirigiendo las caracter�sticas que la poblaci�n resultante ir� teniendo.

�C�MO FUNCIONA?

Cada flor tiene 4 genes que determinan su forma. Por ejemplo, una flor puede tener los p�talos m�s grandes o ser m�s colorida que otra. Cuando el usuario selecciona el padre, o padres, la siguiente generaci�n que se forma a partir de ellos se muestra en el mundo. Si el usuario quiere, por ejemplo, que la poblaci�n sea muy colorida, puede ir seleccionando padres que tengan muchos colores.

En el centro de cada "flor" hay un "g�rmen" invisible, que permanece siempre en el centro de la misma, produciendo p�talos que se mueven hacia el exterior de la flor. Cada g�rmen tiene 4 variables: numero-colores, inc-paso, inc-giro, inc-tama�o (algunas de estas variables se copian en los p�talos para que se puean ir moviendo). En cada turno, cada g�rmen crea un nuevo p�talo, y poteriormente todos los p�talos ajustan su posici�n y tama�o en funci�n de las propiedades de su g�rmen. Si un p�talo se mueve fuera de la zona que corresponde a su flor, se elimina (para que no interfiera a otra flor).

El usuario puede escoger entre reproducci�n sexual (2 padres) o asexual (1 padre), y la siguiente generaci�n de g�rmenes se crear� por mutaci�n de los valores de los padres en los 4 genes.

�C�MO SE USA?

Antes de pulsar SETUP se deben seleccionar el n�mero de columnas y filas que se desee, que determinar�n cu�ntas flores hay en cada generaci�n.

Posteriormente, se establece el valor de mutaci�n que se quiera, cuanto mayor sea, menos parecidas podr�n ser las descendientes a su/s padre/s. Si MUTACION-CONTROLADA? est� activo, el modelo controla la mutaci�n modific�ndolo en la poblaci�n, de manera que sea proporcional al valor que ocupe en la malla. As�, las flores que est�n m�s cerca de la esquina superior izquierda ser�n m�s similares a los padres.

Si se ha seleccionado la reproducci�n asexual, entonces cada generaci�n har� uso de una �nica flor para definir sus caracteres, si no, habr� que pulsar sucesivamente sobre dos flores para definir la siguiente generaci�n.

## COSAS A INTENTAR

Prefije cierto objetivo, e intenta conseguir flores que se ajusten a �l por medio del ensayo y error.

## EXTENDIENDO EL MODELO

Podr�a ser interesante que la malla fuese modificable en tiempo de ejecuci�n, de forma que si estamos ejecutando un mundo 2x2 y el usuario cambia a 3x3, en la siguiente generaci�n aparezca ese n�mero de flores.

Cambia o a�ade genes con otros comportamientos. As� como la forma en que los genes de los padres se expresan en los hijos.

CARACTER�STICAS NETLOGO

Este modelo usa g�rmenes invisibles para mantener la informaci�n de las flores.

Hay algunos detalles interesantes acerca de la geometr�a necesaria para espaciar correctamente las flores en el mundo.

## RELATED MODELS

Sunflower

## CREDITS AND REFERENCES

This model is loosely based on the Biomorphs discussed at length in Richard Dawkins' "The Blind Watchmaker" (1986).

In Dawkins' original model, the user was presented with a series of "insects" that were drawn based on nine separate values.  For example, if insect A has a "leg-length" value of 2 and insect B has a "leg-length" value of 1, then insect A would be drawn with longer legs.  These 9 variables were thus the genotype of each insect-like creature, and the drawing based on those numbers was the phenotype.  If the user clicked on an insect (or "biomorph"), then all the insects would be erased and the chosen biomorph would be used as the basis for a new population of biomorphs.  Each variable would be mutated slightly in the new generation (representing the inheriting of a slightly higher or lower value for the genotype), and these mutated values would be used in the new population of the biomorphs.  In this manner, the new generation of  biomorphs resembled the previously chosen biomorph, with some variation.  For example, if you chose a biomorph with an exceptionally long abdomen, then, because they are all modified versions of the chosen biomorph, biomorphs in the next generation would tend to have longer abdomens than previously.

In this model, "flowers" are used as the biomorphs instead of the insect-like creatures Dawkins used; furthermore, these biomorphs only vary among four variables--num-color, step-size, size-modifier, and turn-increment--and not nine.  The idea is very similar, though.  The user is presented with a number of flowers.  By clicking on a flower, the user can choose the type of flower that will populate the next generation.  If ASEXUAL? is false, the user picks two biomorphs instead of just one; the next generation will be produced by selecting one the values for each of the four genotype variables from either one of the parents.

Thanks to Nate Nichols for his work on this model.

## HOW TO CITE

If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:  
- Nichols, N. and Wilensky, U. (2006).  NetLogo Sunflower Biomorphs model.  http://ccl.northwestern.edu/netlogo/models/SunflowerBiomorphs.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.  
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  
- Copyright 2006 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/SunflowerBiomorphs for terms of use.

## COPYRIGHT NOTICE

Copyright 2006 Uri Wilensky. All rights reserved.

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
