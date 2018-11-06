; Un modelo para ilustrar la idea de fitness sobre un paisaje dinamico

patches-own
[
  fitness
  cambio
]

turtles-own
[
  edad
]

globals
[
  tiempo
]

to setup
  ca
  reset-ticks
  set tiempo 0
  set-default-shape turtles "circle"
  crear-paisaje
  crear-tortugas
end

; Se genera un paisaje asignado un valor de fitness (suavizado en la superficie)
; con valores en [rango/2, 100-rango/2]. Posteriormente, se colorea para mostrar
; este valor en la escala de color.
to crear-paisaje
  ask patches [ set fitness (random 100) ]
  repeat suavidad [ diffuse fitness 1 ]
  re-escalar
  colorea-paisaje
end

; La población inicial, con edades y colores aleatorios se distribuye espacialmente en el
; paisaje.
to crear-tortugas
  crt poblacion
  [
    set color random 140;red
    move-to one-of patches
    set edad 0
  ]
end


; Las tortugas se seleccionan dependiendo de su edad y su fitness. Las tortugas que sobreviven
; se reproducen reemplazando a las tortugas que se pierden.
; Si el paisaje se ha seleccionado dinámico, éste se cambia preservando el gradio de suavidad
; seleccionado, pero permitiendo que los valles y los picos se vayan desplazando.
; Además, se permite introducir nuevas tortugas por medio del ratón.
to go
  muertes
  nacimientos
  dibuja-plots
  if paisaje-dinamico?
  [
    diffuse cambio 1
    if tiempo > suavidad [actualiza-paisaje set tiempo 0 ]
    set tiempo tiempo + 1
  ]
  if mouse-down?
  [
    ask one-of turtles [die]
    crt 1
    [
      set color red
      setxy mouse-xcor mouse-ycor
    ]
    wait 0.1
  ]
  tick
end


; Una tortuga puede morir de vieja (si su edad es mayor que su fitness), o aleatoriamente si
; hay demasiadas.
to muertes
  ask turtles
  [
    set edad edad + .1
    if edad > random fitness [die]
    if count turtles > poblacion [ die ]
  ]
end


; El nacimiento de nuevas tortugas se hace de dos formas posibles:
; 1.- Si no hay Especiación, la probabilidad de reproducirse es directamente proporcional
;     al fitness de la tortuga
; 2.- Si hay Especiación, se supone que hay competición entre las tortugas  y esta probabilidad
;     se ve reducida por la cantidad de tortugas de la misma especie que hay en su cercanía.
to nacimientos
  ask  turtles
  [
    let c color
    let competicion 0
    if Especiacion? [set competicion count (turtles in-radius  mutacion) ];with [color = c] ]
    if fitness - competicion > random 100
    [
      hatch 1
      [
        jump (random-float mutacion)
        rt random 360
        set edad 0
      ]
    ]
  ]
end


; Procedimiento de re-escalado para convertir el fitness al intervalo [rango/2, 100-rango/2].
to re-escalar
  let maximo max [ fitness ] of patches
  let minimo min [ fitness ] of patches
  ifelse (maximo - minimo) = 0
    [ask patches [set fitness 50] ]
    [ask patches [ set fitness rango * (fitness - minimo) / (maximo - minimo) + (99 - rango) / 2] ]
end

; Colorea los patches a una escala de verdes en función del fitness.
to colorea-paisaje
  ask patches [ set pcolor scale-color green fitness 0 100]
end

; Representación de la dinámica del fitness de las tortugas (mínimo, medio y máximo)
to dibuja-plots
  set-current-plot "Fitness"
  set-plot-y-range 0 100
  set-current-plot-pen "media"
  plot mean [ fitness ] of turtles
  set-current-plot-pen "max"
  plot max [ fitness ] of turtles
  set-current-plot-pen "min"
  plot min [ fitness ] of turtles
end

; Cuando el paisaje es dinámico, este procedimiento permite modificarlo para introducir
; las variantes en sus valores.
to actualiza-paisaje
  ask patches
  [
    set fitness fitness + cambio
    set cambio (random tasa-cambio-paisaje)
  ]
  re-escalar
  colorea-paisaje
end
@#$#@#$#@
GRAPHICS-WINDOW
227
10
721
505
-1
-1
6.0
1
10
1
1
1
0
1
1
1
-40
40
-40
40
1
1
1
ticks
30.0

BUTTON
15
10
120
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

BUTTON
120
10
215
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
1

SLIDER
15
46
215
79
suavidad
suavidad
0
50
35.0
1
1
NIL
HORIZONTAL

SLIDER
15
116
215
149
poblacion
poblacion
0
2000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
15
151
215
184
mutacion
mutacion
0
10
3.1
0.1
1
NIL
HORIZONTAL

PLOT
15
186
215
336
Fitness
tiempo
fitness
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"media" 1.0 0 -16777216 true "" ""
"max" 1.0 0 -2674135 true "" ""
"min" 1.0 0 -10899396 true "" ""

SLIDER
15
375
215
408
tasa-cambio-paisaje
tasa-cambio-paisaje
0
200
200.0
10
1
NIL
HORIZONTAL

SWITCH
15
340
215
373
paisaje-dinamico?
paisaje-dinamico?
0
1
-1000

SLIDER
15
81
215
114
rango
rango
0
100
100.0
1
1
NIL
HORIZONTAL

SWITCH
15
410
125
443
Especiacion?
Especiacion?
0
1
-1000

MONITOR
130
410
215
455
Diversidad:
length remove-duplicates [color] of turtles
17
1
11

@#$#@#$#@
¿QUÉ ES?

Este modelo ilustra el principio de evolución como un movimiento de algunas especies a través de un pasaje a lo largo del tiempo. 

Por ahora, ver el código, que está comentado 
   
## HOW IT WORKS

The fitness is indicated on the world view by color, with white being high and dark low. The x and y axis represent the two variables that specify the phenotype of the turtles. The landscape in this model is generated by randomly assigning each patch a fitness value and then smoothing the landscape to the desired degree of smoothness by   
diffusing the fitness variable between patches a number of times specified by the smoothness slider on the interface. The range variable on the interface specifies the difference between the maximum fitness and minimum fitness -- this effectively sets the steepness of the fitness slopes.

At the start of the simulation a number of turtles are generated in a small circle near the center of the landscape. The radius of the circle represents the initial variation of the phenotypic variables (For example if these variables represent beak size and body mass then each turtle has slightly different natural beak size and bodymass). The turtles age by one each time step and have a probability of dying which depends on their age and their fitness as determined by the patch they are on. Specifically, if they are older than a random number between 0 and their fitness then they die. Thus as they age they are more likely to die, but if they have high fitness they are less likely to die. If the population is reduced due to death then turtles are selected at random to reproduce until the population recovers. The new turtles are hatched a small distance from the parent in the fitness landscape -- this distance represents a slight mutation in the phenotypic variables of the parent. 

There is an option to have the landscape change slowly in time. In the natural world the fitness corresponding to particular values of the phenotypic variables change over time, due to changes in the environment. For example, if changing climate destroys the main food source of birds with long beaks, then long beaked birds would have a reduced fitness. The landscape changes by adding a random number to the fitness, then smoothing and rescaling, so that the range and smoothness are retained. The effect is to have the fitness peaks gradually moving around over time.

There is also an option to include a feedback mechanism where the fitness of individuals is reduced if there are too many other individuals with the same, or similar geneome. The result of this type of feed back is speciation so the button to activiate this is called speciation.

## HOW TO USE IT

Choose values for the smoothness and range of the landscape. Select the number of turtles and the mutation, which indicates both the variation in the initial population and the distance that new turtles hatch from their parent. Click setup and go. You should see the population gradually drifting through the landscape in the general direction of the nearest peak in fitness. Individuals do not move through the landscape. Rather, turtles that are fitter are less likely to die and hence have more opportunities to reproduce. The offspring are hatched a small distance in phenotype space from their parent (the distance being a measure of the amount of mutation) and it is in this way that the population drifts up the fitness peaks. 

If you want the landscape to change in time turn on "changing landscape" and choose the rate at which you want it to change.

## THINGS TO NOTICE

With a constant landscape, the first thing to notice is that the population of turtles does gradually drift up the fitness landscape to local fitness peaks, although there are frequently groups of turtles that survive for a time away from the peaks. These are less than optimally fit subgroups who survive by random chance. The graph will show average fitness increasing, but with some fluctuations. 

You will notice that the initial turtle population is randomly colored, but after some time one color comes to dominate. There is no selection pressure on the color of the turtles. The fact that one color ends up dominating is a result of what is known as genetic drift. If two species are equally fit in an environment with limited resources, then over time, due to random fluctuations in population size one species will end up taking over. Sometimes you will see genetic drift acting when the population splits into two groups, one will die out, even if both groups have similar fitness. (Indeed occasionally a "fitter" but smaller group will die out for the same reason.)

## THINGS TO TRY

As the simulation runs try increasing the mutation. As a result the average fitness of the population will usually decrease, but over time it will increase again as the population settles on a higher peak. One way to get to a high peak of fitness is to have the mutation high initially and then gradually decrease it. This illustrates how mutation rates determine the rate and degree of evolution. A higher mutation rate allows more possibility to explore phenotype space over time, but in the short term a smaller mutation rate allows for a higher average fitness.

Allow the population to drift to a fitness peak and then drop the mutation rate low (around 0.2). Now allow the landscape to change. You will see that if the landscape changes rapidly the fitness of the population drops as the peak moves a way. This illustrates how phenotypic variables that are not susceptible to mutation can be detrimental to a species in the event catastrophic changes to environment.

Try reducing the range of the landscape to zero. Then all turtles are equally fit. Turtles should spread out somewhat but will still be localized in a group. The group will randomly drift around the landscape. Notice that one color ends up taking over; which is another demonstration of genetic drift.  

## EXTENDING THE MODEL

One extension to the model would be to allow groups of individuals which are sufficiently far apart in phenotype space to be independent of each, in that they no longer compete for the same resources. This is one way that speciation can occur in nature.  This might be achieved by restricting the number of new turtles born in a way that depends on the number of turtles in the neighbourhood of the turtles that die. Turtles that are a long way in phenotype space may have such different features that they no longer compete (for example, long and short beaked birds might learn to eat different food sources, and hence will no longer be in direct competition for limited resources -- they will only compete with birds who eat the same food.

## RELATED MODELS

See other Evolution based models in this series

## CREDITS AND REFERENCES

   Copyright 2006 David McAvity

This model was created at the Evergreen State College, in Olympia Washington  
as part of a series of applets to illustrate principles in physics and biology. 

Funding was provided by the Plato Royalty Grant.
   
The model may be freely used, modified and redistributed provided this copyright is included and the resulting models are not used for profit.

Contact David McAvity at mcavityd@evergreen.edu if you have questions about its use.
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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
