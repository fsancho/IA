globals
[
  grano-max    ; maxima cantidad de grano que un patch puede tener
]

patches-own
[
  grano-aqui      ; cantidad de grano en el patch
  max-grano-aqui  ; máxima cantidad de grano que este patch puede tener
]

turtles-own
[
  edad             ; edad de la tortuga
  riqueza          ; cantidad de grano que tiene la tortuga
  esperanza-vida   ; máxima edad que la tortuga puede alcanzar
  metabolismo      ; cuánto grano come cada vez
  vision           ; cuántos patches delante suya puede ver
]

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP Y AUXILIARES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ca
  ;; establecemos las variables globales
  set grano-max 50
  ;; llamamos a cada uno de los procedimientos que crean los componentes
  crear-terreno
  crear-tortugas
  crear-plots
  ;; Representa los plots al inicio de la simulación
  actualiza-plots
  reset-ticks
end

;; Creamos la distribución de grano en los patches
to crear-terreno
  ;; A la porción de patches dada por %-tierra-mejor les asignamos la
  ;; mayor cantidad de grano posible
  ask patches
    [ set max-grano-aqui 0
      if (random-float 100.0) <= %-tierra-mejor
        [ set max-grano-aqui grano-max
          set grano-aqui max-grano-aqui ] ]
  ;; Se esparce el grano alrededor y se vuelve a añadir un poco en la tierra mejor,
  ;; antes de disundirlo
  repeat 5
    [ ask patches with [max-grano-aqui != 0]
        [ set grano-aqui max-grano-aqui ]
      diffuse grano-aqui 0.25 ]
  repeat 10
    [ diffuse grano-aqui 0.25 ]          ;; se vuelve a extender un poco el grano
  ask patches
    [ set grano-aqui floor grano-aqui    ;; se convierten a enteros
      set max-grano-aqui grano-aqui      ;; y se sitúa el maxmo grano de cada patch como el inicial
      recolor-patch ]
end

to recolor-patch  ;; procedimiento de patch -- se adapta el color para indicar el nivel de grano
  set pcolor scale-color yellow grano-aqui 0 grano-max
end

;; Creamos la distribución de tortugas
to crear-tortugas
  set-default-shape turtles "person"
  crt poblacion
    [ move-to one-of patches  ;; se pone en el centro de un patch
      set size 1.5
      iniciar-var-tortugas
      set edad random esperanza-vida ]
  recolor-tortugas
end

to iniciar-var-tortugas
  set edad 0
  face one-of neighbors4
  set esperanza-vida esperanza-vida-min + random (esperanza-vida-max - esperanza-vida-min + 1)
  set metabolismo 1 + random metabolismo-max
  set riqueza metabolismo + random 50
  set vision 1 + random vision-max
end

;; Se colorean las tortugas en función de su riqueza:
;; riqueza < 1/3 max.riqueza -> rojo
;; riqueza < 2/3 max.riqueza -> verde
;; riqueza > 2/3 max.riqueza -> azul
to recolor-tortugas
  let max-riqueza max [riqueza] of turtles
  ask turtles
    [ ifelse (riqueza <= max-riqueza / 3)
        [ set color red ]
        [ ifelse (riqueza <= (max-riqueza * 2 / 3))
            [ set color green ]
            [ set color blue ] ] ]
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; GO Y AUXILIARES ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ask turtles
    [ orienta-hacia-grano ]  ;; selecciona el patch en su visión con más grano
  cosecha
  ask turtles
    [ mueve-come-envejece-muere ]
  recolor-tortugas

  ;; cada intervalo-crecimiento-grano ticks, el grano crece
  if ticks mod intervalo-crecimiento-grano = 0
    [ ask patches [ crece-grano ] ]

  tick
  actualiza-plots
end

;; determina la dirección en la que es más beneficioso para moverse (dependiendo
;; de su visión)
to orienta-hacia-grano  ;; procedimiento de tortuga
  set heading 0
  let mejor-direccion 0
  let mejor-cantidad grano-delante
  set heading 90
  if (grano-delante > mejor-cantidad)
    [ set mejor-direccion 90
      set mejor-cantidad grano-delante ]
  set heading 180
  if (grano-delante > mejor-cantidad)
    [ set mejor-direccion 180
      set mejor-cantidad grano-delante ]
  set heading 270
  if (grano-delante > mejor-cantidad)
    [ set mejor-direccion 270
      set mejor-cantidad grano-delante ]
  set heading mejor-direccion
end

to-report grano-delante  ;; procedimiento de tortuga
  let total 0
  let profundidad 1
  repeat vision
    [ set total total + [grano-aqui] of patch-ahead profundidad
      set profundidad profundidad + 1 ]
  report total
end

to crece-grano ;; procedimiento de patch
  ;; Si un patch no está en su máxima capacidad, se añade
  ;; cantidad-crecimiento-grano a su capacidad actual, sin
  ;; sobrepasar su capacidad máxima
  if (grano-aqui < max-grano-aqui)
    [ set grano-aqui grano-aqui + cantidad-crecimiento-grano
      if (grano-aqui > max-grano-aqui)
        [ set grano-aqui max-grano-aqui ]
      recolor-patch ]
end

;; Cada tortuga cosecha en su patch. Si hay varias tortugas en el mismo
;; patch se divide el grano entre ellas
to cosecha
  ask turtles
    [ set riqueza floor (riqueza + (grano-aqui / (count turtles-here))) ]
  ;; tras la cosecha, el patch en el que están las tortugas se queda sin grano
  ask turtles
    [ set grano-aqui 0
      recolor-patch ]
end

to mueve-come-envejece-muere ;; procedimiento de tortuga
  fd 1                                         ;; Movimiento
  set riqueza (riqueza - metabolismo)          ;; Consume algo de grano en función de su metabolismo
  set edad (edad + 1)                          ;; Envejece
  if (riqueza < 0) or (edad >= esperanza-vida) ;; Si pasa la edad posible o se queda sin riqueza, muere
    [ iniciar-var-tortugas ]                   ;;   y renace una tortuga nueva
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; REPRESENTACIÓN PLOTS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to crear-plots
  set-current-plot "Clases"
  set-plot-y-range 0 poblacion
  set-current-plot "Histograma Clases"
  set-plot-y-range 0 poblacion
end

to actualiza-plots
  actualiza-plot-clases
  actualiza-histograma-clases
  actualiza-plots-lorenz-gini
end

to actualiza-plot-clases
  set-current-plot "Clases"
  set-current-plot-pen "Baja"
  plot count turtles with [color = red]
  set-current-plot-pen "Media"
  plot count turtles with [color = green]
  set-current-plot-pen "Alta"
  plot count turtles with [color = blue]
end

to actualiza-histograma-clases
  set-current-plot "Histograma Clases"
  plot-pen-reset
  set-plot-pen-color red
  plot count turtles with [color = red]
  set-plot-pen-color green
  plot count turtles with [color = green]
  set-plot-pen-color blue
  plot count turtles with [color = blue]
end

to actualiza-plots-lorenz-gini
  set-current-plot "Curva de Lorenz"
  clear-plot

  ;; dibuja una línea recta diagonal
  set-current-plot-pen "equal"
  plot 0
  plot 100

  set-current-plot-pen "lorenz"
  set-plot-pen-interval 100 / poblacion
  plot 0

  let riquezas-ordenadas sort [riqueza] of turtles
  let riqueza-total sum riquezas-ordenadas
  let acum-riqueza  0
  let indice 0
  let indice-Gini 0

  ;; A la vez que dibujamos la curva de Lorenz, calculamos el
  ;; índice de Gini. (Ver Information tab para una descripción)
  repeat poblacion [
    set acum-riqueza (acum-riqueza + item indice riquezas-ordenadas)
    plot (acum-riqueza / riqueza-total) * 100
    set indice (indice + 1)
    set indice-Gini indice-Gini + (indice / poblacion) - (acum-riqueza / riqueza-total)
  ]

  ;; Dibuja el índice de Gini en el tiempo
  set-current-plot "Indice Gini / Tiempo"
  plot (indice-Gini / poblacion) / 0.5
end


; Copyright 1998 Uri Wilensky. All rights reserved.
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
184
10
600
427
-1
-1
8.0
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
30.0

BUTTON
8
256
79
289
setup
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
108
256
175
289
go
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
8
72
176
105
vision-max
vision-max
1
15
5.0
1
1
NIL
HORIZONTAL

SLIDER
8
301
176
334
intervalo-crecimiento-grano
intervalo-crecimiento-grano
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
8
106
176
139
metabolismo-max
metabolismo-max
1
25
15.0
1
1
NIL
HORIZONTAL

SLIDER
8
38
176
71
poblacion
poblacion
2
1000
250.0
1
1
NIL
HORIZONTAL

SLIDER
8
208
176
241
%-tierra-mejor
%-tierra-mejor
5
25
10.0
1
1
%
HORIZONTAL

SLIDER
8
174
176
207
esperanza-vida-max
esperanza-vida-max
1
100
83.0
1
1
NIL
HORIZONTAL

PLOT
3
454
255
634
Clases
Tiempo
Tortugas
0.0
50.0
0.0
250.0
true
true
"" ""
PENS
"Baja" 1.0 0 -2674135 true "" ""
"Media" 1.0 0 -10899396 true "" ""
"Alta" 1.0 0 -13345367 true "" ""

SLIDER
8
335
176
368
cantidad-crecimiento-grano
cantidad-crecimiento-grano
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
8
140
176
173
esperanza-vida-min
esperanza-vida-min
1
100
54.0
1
1
NIL
HORIZONTAL

PLOT
257
454
469
634
Histograma Clases
Clases
Tortugas
0.0
3.0
0.0
250.0
false
false
"" ""
PENS
"default" 1.0 1 -2674135 true "" ""

PLOT
471
454
672
634
Curva de Lorenz
Poblacion %
Riqueza %
0.0
100.0
0.0
100.0
false
true
"" ""
PENS
"lorenz" 1.0 0 -2674135 true "" ""
"equal" 100.0 0 -16777216 true "" ""

PLOT
674
454
908
634
Indice Gini / Tiempo
Tiempo
Gini
0.0
50.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" ""

@#$#@#$#@
##¿QUÉ ES?

Este modelo simula la distribución de riqueza en una población. "El rico se vuelve más rico, y el pobre se vuelve más pobre" es una expresión común para expresar la desigualdad en la distribución de la riqueza. En esta simulación se pone de manifiesto la Ley de Pareto, en la que hay un gran número de individuos pobres (rojos), menos de clase media (verder) y muchos menos ricos (azules). 

A veces, la Ley de Pareto se escribe como: "un 80% de la población es dueña del 20% de la riqueza, y un 20% de la población posee el 80% de la riqueza."

##¿CÓMO FUNCIONA?

El modelo es una adaptación del modelo "Sugarscape" de Epstein & Axtell, usando grano en vez de azúcar. Cada patch tiene una cantidad de grano y una capacidad de grano (la cantidad máxima que puede proporcionar), la gente recolecta grano de los patches, y come este grano para sobrevivir. La riqueza de una persona será la cantidad de grano que tiene.

El modelo empieza con una distribución uniforme de la riqueza. Entonces, los individuos empiezan a moverse por el terreno intentando almacenar tanto grano como puedan, moviéndose en la dirección en la que vean más grano. En cada paso, para seguir viviendo, han de alimentarse también con una cierta cantidad de grano (que viene determinada por su metabolismo). También tiene una esperanza de vida, si la superan o se quedan sin grano para alimentarse mueren y se genera otro individuo, con características aleatorias, tanto de metabolismo como de riqueza (es decir, no hay herencia).

Para observar la igualdad (o desigualdad) de la distribución de la riqueza se usa la curva de Lorenz: ordenamos la población según su riqueza, y entonces se representa el porcentaje de población que posee cada porcentaje de riqueza (p.e. el 30% de la riqueza lo posee el 50% de la población). Por tanto, los rangos de ambos ejes van de 0% a 100%.

Otra forma de entender la curva de Lorenz es imaginar que hay 100€ de riqueza disponible para 100 personas. Por tanto, cada individuo es un 1% de población, y cada € es un 1% de riqueza. Ordenamos los individuos en función de si riqueza, de menor a mayor, y dibujamos la proporción del rango de individuos en el eje y y la porción de riqueza que tiene este individuo y los que son más pobres que él, en el eje x. La diagonal de 45º de inclinación (de pendiente 1) es la curva de Lorenz que representa la igualdad perfecta (cada individuo tiene la misma porción de riqueza). Por otra parte, cuanto más curvada esté esta gráfica, más desigualdad representa (es una curva continua que comienza en (0,0) y acaba en (100,100)).

Para dar una medida numérica de esta desigualdad también se presenta el índice de Gini, que se obtiene calculan el área que hay entre la recta de pendiente 1 y la curva de Lorenz y se divide por el área total del triángulo que forma esa recta. Si la curva de Lorenz es la recta, entonces el índice de Gini es 0, en el caso extremo de que una sola persona acumule toda la riqueza el ídice de Gini resulta 1. Una forma de entender el índice de Gini sin hacer uso de la curva de Lorenz es pensarlo como la diferencia media, en riqueza, entre todos los posibles pares de personas, expresado como una proporción de la riqueza media (ver Deltas, 2003 para más información).

##¿CÓMO SE USA?

El %-TIERRA-MEJOR determina la densidad inicial de patches que serán plantados con la cantidad máxima de grano. Este máximo se ajusta por medio de la variable GRANO-MAX en el procedimiento de SETUP. El INTERVALO-CRECIMIENTO-GRANO determina cómo de frecuente crece el grano, y la CANTIDAD-CRECIMIENTO-GRANO cuánto crece cada vez que lo hace.

La POBLACION determina la cantidad inicial de individuos. ESPERANZA-VIDA-MIN el menor número de pasos que puede vivir, y ESPERANZA-VIDA-MAX el mayor. METABOLISMO-MAX establece la máxima cantidad de grano que una persona necesita para sovbrevivir cada paso, y VISION-MAX la máxima distancia que puede ver cuando busca una nueva zona de recolección.

## COSAS A TENER EN CUENTA

Observa la distribución de riqueza, ¿son iguales las clases?

Este modelo demuestra la Ley de Pareto, ¿porqué ocurre este hecho?

¿Comienzan los individuos pobres siendo pobres?, ¿y los de la clase media y ricos?

Observa cuánto tardan en estabilizarse las clases.

A medida que el tiempo pasa, ¿la distribución se iguala o se acentúan las diferencias?

¿Hay alguna tendencia en el índice de Gini con respecto al tiempo?, ¿se estabiliza u oscila permanentemente?

## COSAS A INTENTAR

¿Hay alguna combinación de parámetros que no lleve a la ley de Pareto?

Juega con CANTIDAD-CRECIMIENTO-GRANO y mira cómo afecta a la distribución de riqueza.

¿Cómo afecta la ESPERANZA-VIDA-MAX?

Cambia el valor de GRANO-MAX (en el procedimiento SETUP). ¿Hay alguna diferencia?

Experimenta con %-TIERRA-MEJOR y POBLACION, ¿cómo afecta a la distribución de riqueza?

Intenta comenzar con toda la población en una sola localización y mira qué ocurre.

Intenta crear a todos los individuos con la misma riqueza inicial. ¿Se llega así a una distribución equitativa de la riqueza?, ¿hay alguna diferencia con respecto al método que se presenta aquí?

Empieza con todos los individuos con la misma visión y riqueza. ¿Hay diferencias ahora?

## EXTENDIENDO EL MODELO

Haz que las nuevas generaciones hereden un porcentaje de la riqueza de su progenitor.

Añade un switch (o slider) que haga que todos, o un porcentaje de los patches vuelvan a su capacidad original, más que ir añadiendo unidades por tiempo.

Permite que el grano proporcione alguna ventaja, o desventaja, a su dueño... por ejemplo, que genere polución al consumirlo o recolectarlo, o que el movimiento o la visión se modifique.

¿Sería este modelo el mismo si la riqueza se distribuyera completamente al azar en el terreno (y no por gradientes)? Intenta con otros tipo de terrenos, generando botones SETUP para cada uno de ellos.

Intenta hacer que la visión o el metabolismo sean hereditarios. ¿Podremos ver así algún tipo de evolución?

Intenta añadir estaciones al modelo (es decir, épocas en las que varían las velocidades de crecimiento del grano).

¿Cómo cambiarías el modelo para obtener distribución equitativa de riqueza?

Por la forma en que están hechos los procedimientos algunas persona siguen a otras (puedes ver que es así bajando la población y ampliando la esperanza de vida). ¿Porqué ocurre esto? Intenta añadir algún código que evite este hecho (Ayuda: ¿Cuándo y cómo la gente comprueba qué dirección es mejor para moverse?)

##CARACTERÍSTICAS NETLOGO

Examina cómo se crea el terreno (se usa el reporter "scale-color"). Se le asigna a cada patch un valor, y scale-color proporciona un color que refleja dicho valor en una escala posible.

Observa el uso de listas a la hora de dibujar la Curva de Lorenz y el índice de Gini.

## CREDITS AND REFERENCES

This model is based on a model described in Epstein, J. & Axtell R. (1996). Growing Artificial Societies: Social Science from the Bottom Up. Washington, DC: Brookings Institution Press.

For an explanation of Pareto's Law, see http://www.xrefer.com/entry/445978.

For more on the calculation of the Gini index see:  
Deltas, George (2003).  The Small-Sample Bias of the Gini Coefficient:  Results and Implications for Empirical Research.  The Review of Economics and Statistics, February 2003, 85(1): 226-234.  
In particular, note that if one is calculating the Gini index of a sample for the purpose of estimating the value for a larger population, a small correction factor to the method used here may be needed for small samples.

## HOW TO CITE

If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:  
- Wilensky, U. (1998).  NetLogo Wealth Distribution model.  http://ccl.northwestern.edu/netlogo/models/WealthDistribution.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.  
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  
- Copyright 1998 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/WealthDistribution for terms of use.

## COPYRIGHT NOTICE

Copyright 1998 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:  
a) this copyright notice is included.  
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
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
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225
@#$#@#$#@
0
@#$#@#$#@
