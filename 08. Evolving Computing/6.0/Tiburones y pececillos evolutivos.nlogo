breed [tiburones tiburon]
breed [peces pez]

globals [
    Muertos-por-inanicion
    comidos
    mutaciones]

patches-own [
    plancton]

;; Parámetros comunes a todos los tipos de tortugas
turtles-own [
    Velocidad-Crucero
    Velocidad-Arranque
    Angulo-Cabeceo
    Angulo-Giro
    Campo-Vision
    Profundidad-Vision
    Energia
    Genoma
    Edad
    Saciado]

;; Parámetros exclusivos de los peces
peces-own [ Angulo-evitar Angulo-Escape Rango-Seguridad ]

;; Parámetros exclusivos de los tiburones
tiburones-own [ energia-por-comida ]

;; Procedimiento principal de preparación
;;
to setup
    ca
    ;; lista de las tasas de mutación de cada gen. Si se modifica, puede conllevar diferentes direcciones
    ;; de evolucionar
    set mutaciones (list  0.1 0.1 5 0.5 0.1 2 2 2 )
    ;; Creación de peces. Define los parámetros de los peces de forma aleatoria, y a partir de ellos, el Genoma.
    create-peces poblacion-peces [
        setxy random-xcor random-ycor
        set shape "Pez"
        set Angulo-Cabeceo  10
        set Velocidad-Crucero random-float 1
        set Velocidad-Arranque 1 + random-float 1
        set Campo-Vision random-float 360
        set Profundidad-Vision 2 + random-float 15
        set Rango-Seguridad random-float 2
        set Angulo-Giro random-float 30
        set Angulo-evitar random-float 30
        set Angulo-Escape random-float 30
        set Energia Energia-Nacimiento + random-float Energia-Nacimiento
        set Edad random 200
        set Saciado random 4
        set Genoma (list Velocidad-Crucero Velocidad-Arranque Campo-Vision Profundidad-Vision Rango-Seguridad
                                                        Angulo-Giro Angulo-evitar Angulo-Escape )
        if shade-of? turquoise color or shade-of? gray color [set color red]
        Crece]
    ;; Creación de Tiburones
    repeat poblacion-tiburones [Crea-Tiburones random-xcor random-ycor]
    ;; Creación de Plancton
    ask patches [ set plancton random 3 ]
    repeat 5 [diffuse plancton 1 ]
    ask patches [ set pcolor scale-color turquoise plancton 0 12 ]
    ;; Variables globales
    set Muertos-por-inanicion 0
    set comidos 0
    reset-ticks
end

;; Procedimiento principal de ejecución

to go

   ;; Crecimiento de plancton. Si hay menos que un cierto umbral, recrece con una probabilidad determinada por el
   ;; parámetro de tasa de crecimiento, además, se difumina por los alrededores de cada patch.
   ask patches [
       if plancton < 5 [
           if random-float 100 < Tasa-crec-plancton  [
              set plancton plancton  + 1  ] ]  ]
   diffuse plancton 1
   ask patches [ set pcolor scale-color turquoise plancton 0 12]

   ;; Procedimietos de peces
    ask peces [ without-interruption [
        nada
        alimenta
        set Edad Edad + 1
        Crece ] ]
    ask peces [ without-interruption [nacimiento muerte ] ]

    ;; Si se pulsa en la pantalla, se crea un tiburón nuevo
    if mouse-down? [
       Crea-Tiburones mouse-xcor mouse-ycor
       wait 0.5]

    ;; Procedimiento de Tiburones
    ask tiburones [ without-interruption [caza ]  ]

    tick

    ;; Actualización de los plots
    actualiza-plots
end


;; Crea tiburones con los parámetos fijos. Se podrían poner en el interfaz, pero lo complicarían
;; considerablemente
to Crea-Tiburones [x y]
        create-tiburones 1 [
            set heading random 360
            setxy x y
            set color grey
            set size 4
            set shape "tiburon"
            set Velocidad-Crucero 1.5
            set Velocidad-Arranque 2.5
            set Angulo-Cabeceo 5
            set Angulo-Giro 30
            set Campo-Vision 120
            set Profundidad-Vision 20
            set Energia random 200
            set energia-por-comida 20
            set Edad random 200
            set Saciado 0 ]
end

;; Procedimiento para gobernar los peces y pérdida de energía
to nada
        set Energia Energia - metabolismo
        let peligro tiburones in-cone Profundidad-Vision Campo-Vision
        ifelse (any? peligro)
          [ evita (min-one-of peligro [distance myself ]) Angulo-Escape
            fd Velocidad-Arranque
            set Energia Energia - Velocidad-Arranque * Energia-Arranque ]
          [ banco ]
end

;; Procedimiento de peces y tiburones que determina el movimiento aleaorio cuando no hay
;; predadores/presas en las cercanías.
to navega
  ;; Giro aleatorio
   rt random Angulo-Cabeceo
   lt random Angulo-Cabeceo
   ;; Permite a peces y tiburones realizar arranques de velocidad
   ifelse random 10 = 0
   [
     fd Velocidad-Arranque
     set Energia Energia - Velocidad-Arranque * Energia-Arranque]
   [
     fd Velocidad-Crucero
     set Energia Energia - Velocidad-Crucero * Energia-Arranque ]
end

;; Procedimiento de tiburones que gobierna el movimiento y gastod de energía
to caza
    let presa peces in-cone Profundidad-Vision Campo-Vision
    ifelse  (any? presa) and (Saciado < 0)
        [ let objetivos presa in-radius 2  ;; minnows are eaten if they are with a radius of 2
          ifelse any? objetivos
              [
                ask one-of objetivos [die]
                set comidos comidos + 1
                set Energia Energia + energia-por-comida
                ;; Saciado es una forma de impedir q los tiburones coman continuamente. Esperan 3 ticks
                set Saciado 3]
              [
                ;; si no hay peces cerca, se dirige a ellos
                aproxima min-one-of presa [distance myself] Angulo-Giro
                fd Velocidad-Arranque
                set Energia Energia - Velocidad-Arranque * Energia-Arranque ] ]
        [ navega
          set Saciado Saciado - 1 ] ;; si no ve peces, simplemente navega y se vuelve más hambriento
end


;; Procedimiento que gobierna el comportamiento de banco de peces
to banco
  ;; banco-en-mi-campo son los peces que puede ver
    let banco-en-mi-campo peces in-cone Profundidad-Vision Campo-Vision with [(self != myself) ]
    ifelse any? banco-en-mi-campo
        [let mas-cercano min-one-of banco-en-mi-campo [distance myself]
         ifelse distance mas-cercano  < Rango-Seguridad
             ;; Si el más cercano está demasiado cerca, lo evita
             [ evita mas-cercano Angulo-evitar ]
             ;; Si no está tan cerca, se gira a cada uno de los compañeros, por turno, un ángulo que
             ;; decrece exponencialmente con la distancia, para que afecten más los más cercanos.
             ;; Posteriormente, se intentan alinear con ellos de nuevo.
             [ foreach sort banco-en-mi-campo [ p ->
                  let adjusted-turn-angle Angulo-Giro * exp( ((distance mas-cercano) - (distance p) ) )
                  aproxima p adjusted-turn-angle
                  alinea p adjusted-turn-angle ]]
         navega]
        [navega]
end

;; Procedimiento de peces y tiburones para girar en dirección al objetivo con un ángulo máximo de giro.
to aproxima [objetivo angulo-maximo]
   let angulo subtract-headings towards objetivo heading
              ifelse abs (angulo) > angulo-maximo
                  [ ifelse angulo > 0 [right angulo-maximo ][left angulo-maximo] ]
                  [ right angulo ]
end

;; Procedimiento para girar en la dirección a la q apunta el objetivo, con un ángulo máximo de giro.
to alinea [objetivo angulo-maximo]
   let angulo subtract-headings [heading] of objetivo heading
              ifelse abs (angulo) > angulo-maximo
                  [ ifelse angulo > 0 [right angulo-maximo ][left angulo-maximo] ]
                  [ right angulo ]
end

;; Procedimiento de peces para girar alejándose del objetivo, con ángulo máximo de giro.
to evita [objetivo angulo-maximo]
   let angulo subtract-headings ((towards objetivo) + 180) heading
              ifelse abs(angulo) > Angulo-Giro
                  [ ifelse angulo > 0 [right angulo-maximo ][left angulo-maximo] ]
                  [ right angulo ]
end

;; Procedimiento de peces. Si hay plancton en el patch y está hambriento, come para ganar energía y
;; el plancton se reduce. La saciead se aumenta para evitar que coman sin parar.
to alimenta
    ifelse plancton >= 1 and Saciado <= 0
       [ set Energia Energia + pez-energia-comer
         set plancton plancton - 1
         set Saciado Saciado + 4  ]
       [ set Saciado Saciado - 1 ]
end


;; Procedimiento de peces y tiburones. Si la energía excede un umbral, genera un descendiente con energía
;; Energía-Nacimiento, que la pierde el predecesor.
to nacimiento
    if (Energia > 2 * Energia-Nacimiento)   [
        set Energia Energia - Energia-Nacimiento
        hatch 1 [
           set Edad 0
           set Energia Energia-Nacimiento
           set heading random 360
           if mutacion?  [muta] ;; mutate the genome
           fd Velocidad-Crucero ] ]
end

;; Procedimiento de peces para eliminar aquellos que tengan energía negativa
to muerte
    if (Energia < 0) [
        if breed = peces
            [set Muertos-por-inanicion Muertos-por-inanicion + 1]
        die ]
end

;; Procedimiento de peces que cambia tamaño y tonalidad de acuerdo con la edad y energía (respectivamente)
;; Oscuros: energía baja, Claros: Energía alta
to Crece
        ifelse Edad > 300
           [set size 2 ]
           [set size 0.8 + Edad * 0.004 ]
       set color scale-color color (Energia ) 0  (2 * Energia-Nacimiento + 50)
end


;; Modifica los genes aplicando la mutación. Cuidando los límites de cada parámetro.
to muta
    let i 0
    let temp 0
    while [i < ( length Genoma ) ][
      ifelse ((random 2) = 0 )
        [set temp item i Genoma + item i mutaciones ]
        [set temp item i Genoma - item i mutaciones ]
      if (temp <= 0) [set temp item i mutaciones ]
      set Genoma replace-item i Genoma temp
      set i i + 1
    ]
    set Velocidad-Crucero item 0 Genoma
    set Velocidad-Arranque  item 1 Genoma
    if item 2 Genoma > 360 [set Genoma replace-item 2 Genoma 360]
    set Campo-Vision  item 2 Genoma
    set Profundidad-Vision  item 3 Genoma
    if item 4 Genoma > Profundidad-Vision [set Genoma replace-item 4 Genoma Profundidad-Vision]
    set Rango-Seguridad  item 4 Genoma
    set Angulo-Giro  item 5 Genoma
    set Angulo-evitar  item 6 Genoma
    set Angulo-Escape  item 7 Genoma
end

to actualiza-plots
    set-current-plot-pen "Peces"
    plot count peces
end
@#$#@#$#@
GRAPHICS-WINDOW
355
10
836
492
-1
-1
11.54
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
10
10
78
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
10
45
155
78
poblacion-peces
poblacion-peces
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
85
10
155
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

MONITOR
15
470
83
515
Peces
count peces
3
1
11

SLIDER
10
150
155
183
Tasa-crec-plancton
Tasa-crec-plancton
0
1
0.4
0.05
1
NIL
HORIZONTAL

SLIDER
10
80
155
113
poblacion-tiburones
poblacion-tiburones
0
20
1.0
1
1
NIL
HORIZONTAL

PLOT
10
290
350
469
Población
Tiempo
Población
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"tiburones" 1.0 0 -7500403 true "" ""
"Peces" 1.0 0 -16777216 true "" ""

MONITOR
95
470
166
515
Inanición
Muertos-por-inanicion
3
1
11

MONITOR
175
470
255
515
Total Comidos
comidos
3
1
11

BUTTON
180
240
323
273
Sacar Tiburón
ask one-of tiburones [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
185
10
296
43
mutacion?
mutacion?
0
1
-1000

MONITOR
255
45
350
90
Vel. Arranque
mean [Velocidad-Arranque] of peces
3
1
11

MONITOR
160
90
255
135
Campo Visión
mean [Campo-Vision] of peces
3
1
11

MONITOR
255
90
350
135
Prof.Vision
mean [Profundidad-Vision] of peces
3
1
11

MONITOR
255
180
350
225
Ang.Giro
mean [Angulo-Giro] of peces
3
1
11

MONITOR
160
135
255
180
Ang.Evitar
mean [Angulo-evitar] of peces
3
1
11

MONITOR
160
180
255
225
Ang.Escapa
mean [Angulo-Escape] of peces
3
1
11

MONITOR
255
135
350
180
Rango Seguridad
mean [Rango-Seguridad] of peces
3
1
11

SLIDER
10
185
155
218
Energia-Nacimiento
Energia-Nacimiento
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
10
115
155
148
pez-energia-comer
pez-energia-comer
0
10
5.0
0.1
1
NIL
HORIZONTAL

MONITOR
160
45
255
90
Vel. Crucero
mean [Velocidad-Crucero] of peces
3
1
11

MONITOR
260
470
350
515
Tasa Mortandad
(Comidos + Muertos-por-inanicion) / ticks
3
1
11

SLIDER
10
220
155
253
Energia-Arranque
Energia-Arranque
0
1
0.2
0.05
1
NIL
HORIZONTAL

SLIDER
10
255
155
288
metabolismo
metabolismo
0
1
0.3
0.05
1
NIL
HORIZONTAL

@#$#@#$#@
¿QUÉ ES?
-----------
Es un modelo de predador-presa, con tiburones y peces, que ilustra el principio de evolución. Los peces están programados con ciertos comportamientos, tales como movimiento, alimentación, reproducción, evasión de tibuones y algunos más complejos que llevan a la formación de bancos de peces bajo ciertas condiciones. Los tiburones cazan peces y se alimentan de ellos. Los parámetros que determinan el comportamiento de los peces eolucionan a medida de los peces mueren y nacen.


¿CÓMO FUNCIONA?
------------
En el modelo, los parámetros que gobiernan los comportamientos de los peces se almacenan en un "genoma" para cada pez. Inicialmente, cada pez tiene un genoma asignado aleatoriamente y consecuentemente no exhiben ningún comportamiento especialmente eficiente para evadir a los tiburones o formar bancos. Sin embargo, los tiburones cazan y comen peces y los que sobreviven se reproducen. Además, hay algunos peces que se reproducen más rápidamente, dependiendo de cuánta energía consumen y cuánta consumen. Los nuevos peces heredan el genoma de sus padres, pero con algunas pequeñas mutaciones (dependiente del rasgo). A medida que el tiempo pasa, el comportamiento de los peces evoluciona hacia uno que incrementa sus opciones de supervivencia. El comportamiento exacto puede depender de la simulación concreta, no siendo siempre el mismo. 

CÓMO SE USA
-------------
Selecciona la población inicial de peces. A continuación fija los parámetros globales por medio de los sliders y ejecuta la simulación. Para algunas combinaciones la población de peces muere rápidamente, porque no son suficientemente aptas para escapar de los tiburones o bien porque consumen más energía de la que pueden ganar con el plancton. Pulsa el botón "Sacar Tiburón" para eliminar uno de los tiburones del mundo, y pulsa sobre el mundo para crear un nuevo tiburón en esa zona.

COSAS A TENER EN CUENTA E INTENTER
----------------- 

Ajusta los parámetros para que la población de peces no muera. Una vez que tengas la dinámica relativamente estable, permíteles evolucionar para que adquieran características adecuadas para sobrevivir a los tiburones. Eventualmente, un color predominará sobre el resto, que representará al genoma más apto. 
Intenta modificar el número de tiburones presentes. El comportamiento que evoluciona en los peces es diferente dependiendo del número de tiburones presentes.

Ocasionalmente, los peces adquieren un comportamiento de banco y se mueven en grupo para evitar a los tiburones. En otras ocasiones, evolucionarán para moverse más rápido que los tiburones, pero sin exhibir un comportamiento grupal. A veces observarás que los peces no evolucionan de manera especialmente eficiente para evitar los tiburones, sino para reproducirse rápidamente. Por supuesto, esta tendencia puede estar determinada por los parámetros. Por ejemplos, si la Energía de Arranque es baja, es más probable que los peces se muevan rápidamente. Se debe tener presente que, aunque los parámetros globales sean fijos, los peces no tienen porqué evolucionar siempre en la misma dirección.

Si corres la simulación por un tiempo suficientemente largo, la tasa de muerte decrecerá, y la población de peces acabará estabilizándose.


EXTENDIENDO EL MODELO
-------------------
En este modelo únicamente los peces evolucionan para, eventualmente, evitar ser cazados por los tiburones, pero en la vida real también los depredadores evolucionan para cazar con mayor eficacia. Actualmente, los genes de los tiburones son invariantes, por lo que no se les permite evolucionar. Para ello habría que introducir algunos mecanismos que los hicieran morirse (en caso de no conseguir suficiente caza). No debería ser excesivamente complicado modificar el modelo para introducir estas ideas, y es muy probable que con ello se consiguiera una evolución de ambas especies en busca de técnicas que beneficiasen a ambas especies en sus objetivos. 


COPYRIGHT NOTICE
----------------------

   Copyright 2006 David McAvity

This model was created at the Evergreen State College, in Olympia Washington
as part of a series of applets to illustrate principles in physics and biology. 

Funding was provided by the Plato Royalty Grant.
 
The model may be freely used, modified and redistributed provided this copyright is included and it not used for profit.

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

pez
true
0
Polygon -7500403 true true 150 15 136 32 118 80 105 90 90 120 105 120 115 145 125 208 131 259 120 285 135 285 165 285 150 261 167 208 177 141 180 120 195 120 195 105 178 80 162 32

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

tiburon
true
0
Polygon -7500403 true true 150 15 164 32 182 80 204 98 210 113 189 117 185 145 175 208 169 259 200 277 168 276 135 298 150 261 133 208 123 141 123 116 99 123 104 106 122 80 138 32

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
