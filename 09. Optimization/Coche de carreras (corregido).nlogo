__includes ["PSO.nls"]

;----------------SETUP Y GO-----------------------

globals[
  posInicialX
  posInicialY
  anguloInicial
  checkPoints
  lineaMeta
  extremoDer
  extremoIzq
]

breed [vehiculos vehiculo]
vehiculos-own[
  velocidad
  combustibleGastado
]

to setup
  ca
  set lineaMeta []
  set extremoDer []
  set extremoIzq []
  set checkPoints []
  print "¡Ya puedes empezar a configurar el circuito!"
end

to dibujarVolido
  if-else (mouse-down? and (member? (patch mouse-xcor mouse-ycor) lineaMeta))
    [ ;; first make sure there's a turtle (if the user just pressed
      ;; the mouse button, there won't be yet)
      if not any? turtles
        [ ask patch mouse-xcor mouse-ycor
            [ sprout 1
                [ pen-down
                  set pen-size 2 ] ] ]
      ;; now that we're sure we have a turtle, we ask it to move
      ;; towards the mouse
      ask turtles
        [ if distancexy mouse-xcor mouse-ycor > 0
            [ facexy mouse-xcor mouse-ycor
            set anguloInicial (heading)
            set posInicialX (xcor)
            set posInicialY (ycor)
              ] ]
      print "¡Vólido recogido!"
 ]

    ;; once the user releases the mouse button, we don't need the
    ;; turtle anymore
  [clear-turtles]
end

to dibujarLineaMeta
  if mouse-down?     ;; reports true or false to indicate whether mouse button is down
    [
      ;; mouse-xcor and mouse-ycor report the position of the mouse --
      ;; note that they report the precise position of the mouse,
      ;; so you might get a decimal number like 12.3, but "patch"
      ;; automatically rounds to the nearest patch
      ask patch mouse-xcor mouse-ycor
        [ set pcolor red
          set lineaMeta lput self lineaMeta
          display ]
    ]
end

to dibujarExtremoDer
  if mouse-down?     ;; reports true or false to indicate whether mouse button is down
    [
      ;; mouse-xcor and mouse-ycor report the position of the mouse --
      ;; note that they report the precise position of the mouse,
      ;; so you might get a decimal number like 12.3, but "patch"
      ;; automatically rounds to the nearest patch
      ask patch mouse-xcor mouse-ycor
        [ set pcolor blue
          set extremoDer lput self extremoDer
          display ]
    ]
end

to dibujarExtremoIzq
  if mouse-down?     ;; reports true or false to indicate whether mouse button is down
    [
      ;; mouse-xcor and mouse-ycor report the position of the mouse --
      ;; note that they report the precise position of the mouse,
      ;; so you might get a decimal number like 12.3, but "patch"
      ;; automatically rounds to the nearest patch
      ask patch mouse-xcor mouse-ycor
        [ set pcolor green
          set extremoIzq lput self extremoIzq
          display ]
    ]
end

to dibujarNuevoPuntoControl
  let nuevoPuntoControl []
  while [not mouse-down?] []
  while [mouse-down?]     ;; reports true or false to indicate whether mouse button is down
    [
      ;; mouse-xcor and mouse-ycor report the position of the mouse --
      ;; note that they report the precise position of the mouse,
      ;; so you might get a decimal number like 12.3, but "patch"
      ;; automatically rounds to the nearest patch
      ask patch mouse-xcor mouse-ycor
        [ set pcolor brown
          set nuevoPuntoControl lput self nuevoPuntoControl
          display ]
    ]
  set checkPoints lput nuevoPuntoControl checkPoints
end

to borrarUltimoPuntoControl
  let indice ((length checkPoints) - 1)
  if ((length checkPoints) != 0)[
    foreach (item indice checkPoints) [ [p] -> ask p [set pcolor black]]
    set checkPoints remove-item (indice) checkPoints
  ]
end

to go
  no-display
  ; VAMOS A LIMPIAR ANTES DE NADA LAS LISTAS GLOBALES
  set checkPoints remove-duplicates checkPoints
  set lineaMeta remove-duplicates lineaMeta
  set extremoDer remove-duplicates extremoDer
  set extremoIzq remove-duplicates extremoIzq

  AI:Create-particles numAbejas (2 + 2 * (length checkPoints))
  let res (AI:PSO numeroIteraciones inerciaAbejas atraccionPersonal atraccionGlobal limVelocidadAbejas)
  let mejorRecorrido (item 1 res)
  print ("Mejor fitness: ")
  print (item 0 res)
  display
  mostrarRecorrido mejorRecorrido
end

; FUNCIÓN MOSTRAR RECORRIDO (MUY PARECIDA A FUNCIÓN FITNESS)
to mostrarRecorrido [mejorRecorrido]
  reset-ticks
  let volido nobody
  create-vehiculos 1 [set volido self]
  ;let volido one-of vehiculos
  inicializarVolido volido
  let maniobras mejorRecorrido
  let i 0
  let aceleracion 0
  let aceleracionAnterior 0
  let giro 0
  let t 1
  let fitness 0.0
  let siguientePuntoControl (item 0 checkPoints)

  let sw true
  while [sw]
  [
    set aceleracionAnterior aceleracion
    set aceleracion (item (i) maniobras)
    set giro (item (i + 1) maniobras)

    print [heading] of volido
    print giro
    ; EJECUCIÓN DE LA MANIOBRA:
    ejecutarManiobraLineal volido aceleracion giro

    if (finCarrera? volido siguientePuntoControl) ; SI ACABA LA CARRERA, SALIMOS DEL BUCLE
    [
      set sw false
    ]

    if (pisaPuntoControl? volido siguientePuntoControl) [
      set i (i + 2) ; SELECCIONAMOS LA SIGUIENTE MANIOBRA
      let indicePuntoControl (i / 2)
      ask volido [set heading (heading + (90 - (giro * 180)))] ; APLICAMOS UN GIRO INSTANTÁNEO
      if-else (indicePuntoControl < (length checkPoints))
      [
        set siguientePuntoControl (item (indicePuntoControl) checkPoints) ; SI HAY MÁS PUNTOS DE CONTROL, APUNTAMOS AL SIGUIENTE...
      ]
      [
        set siguientePuntoControl [] ; ...  DE LO CONTRARIO, MARCAMOS EL SIGUIENTE COMO VACÍO. ES DECIR, ES LA LÍNEA DE META
        print "¡Último tramo!"
      ]
    ]
    if (t > maxTiempo)[
        set sw false
      print "ERROR TIEMPO"
      ]


    ; RESTRICCIÓN 1
    if ((t > minTiempo) and (not (velocidadAdecuada? volido)))[
      print "ERROR VELOCIDAD"
    ]

    ; RESTRICCIÓN 2
    if (marchaAtras? volido)[
      print "ERROR DIRECCIÓN"
      set sw false
    ]

    ; RESTRICCIÓN 3
    if (pisaExtremo? volido)[
      print "ERROR POSICIÓN"
      set sw false
    ]

    set t (t + 1)
    tick
  ]
  ask vehiculos [die] ; MATAMOS AL VÓLIDO DE LA ABEJA
end

;----------------ALGORITMO PROPIO-------------------

; INICIALIZACIÓN DEL VÓLIDO DE CADA ABEJA
to inicializarVolido [volido]
  ask volido [
    set velocidad 0
    set heading anguloInicial
    set xcor posInicialX
    set ycor posInicialY
  ]
end


to ejecutarManiobraLineal [volido aceleracion giro] ; PARA PROBAR
  let velocidadAnterior ([velocidad] of volido)
  let aceleracionReal ((aceleracion * 2) - 0.1)
  let nuevaVelocidad (velocidadAnterior + aceleracionReal)
  if (nuevaVelocidad < 0.25) [set nuevaVelocidad 0.25]
  if (nuevaVelocidad > 1) [set nuevaVelocidad 1]
  let nuevaVelocidadX (([dx] of volido) * nuevaVelocidad) ; EL MALDITO NETLOGO ME OBLIGA A HACER LA PRESENTE BLASFEMIA
  let nuevaVelocidadY (([dy] of volido) * nuevaVelocidad)
  ask volido [
    set xcor (xcor + nuevaVelocidadX)
    set ycor (ycor + nuevaVelocidadY)
    set velocidad nuevaVelocidad
  ]
end


; FUNCIÓN FITNESS DE LA ABEJA
to-report funcionFitness
  ; SUPONDRÉ QUE ESTÁ FUNCIÓN ES UNA SECCIÓN CRÍTICA PARA LAS ABEJAS
  let volido nobody
  hatch-vehiculos 1 [set volido self]
  ;let volido one-of vehiculos
  inicializarVolido volido
  let maniobras pos
  let i 0
  let aceleracion 0
  let aceleracionAnterior 0
  let giro 0
  let t 1
  let fitness 0.0
  let siguientePuntoControl (item 0 checkPoints)

  let sw true
  ask volido [set combustibleGastado 0]

  while [sw]
  [
    set aceleracionAnterior aceleracion
    set aceleracion (item (i) maniobras)
    set giro (item (i + 1) maniobras)

    ; EJECUCIÓN DE LA MANIOBRA:
    ejecutarManiobraLineal volido aceleracion giro

    ; CONSUMO DE COMBUSTIBLE
    ask volido[set combustibleGastado (combustibleGastado + (consumoCombustible aceleracion aceleracionAnterior))] ; VAMOS ACUMULANDO EL CONSUMO DE COMBUSTIBLE

    ; RESTRICCIÓN 1
    if ((t > minTiempo) and (not (velocidadAdecuada? volido)))[
      set fitness (fitness + 10 ^ 3)
    ]

    ; RESTRICCIÓN 2
    if (marchaAtras? volido)[
      set fitness (fitness + (10 ^ 9))
      set sw false
    ]

    ; RESTRICCIÓN 3
    if (pisaExtremo? volido)[
      set fitness (fitness + (10 ^ 6))
      set sw false
    ]

    if-else (finCarrera? volido siguientePuntoControl) ; SI ACABA LA CARRERA, SALIMOS DEL BUCLE
    [
      set fitness ([combustibleGastado] of volido) ; SI ACABA LA CARRERA, EL FITNESS SERA DIRECTAMENTE EL COMBUSTIBLE GASTADO Y PUNTO
      ; DE LO CONTRARIO, EL FITNESS SERA LA SUMA DE LA PUNTUACION POR METER LA PATA
      set sw false
    ]
    [
      if (t > maxTiempo)[ ; RESTRICCIÓN 4
        set fitness (fitness + (10 ^ 3))
        set sw false
      ]
    ]

    if (pisaPuntoControl? volido siguientePuntoControl) [
      set i (i + 2) ; SELECCIONAMOS LA SIGUIENTE MANIOBRA
      let indicePuntoControl (i / 2)
      ask volido [set heading (heading + (90 - (giro * 180)))] ; APLICAMOS UN GIRO INSTANTÁNEO
      set fitness (fitness - 1000) ; CUANDO LLEGAMOS A UN PUNTO DE CONTROL RECOMPENSAMOS AL VÓLIDO
      if-else (indicePuntoControl < (length checkPoints))
      [
        set siguientePuntoControl (item (indicePuntoControl) checkPoints) ; SI HAY MÁS PUNTOS DE CONTROL, APUNTAMOS AL SIGUIENTE...
      ]
      [
        ;set i (i - 2)
        set siguientePuntoControl [] ; ...  DE LO CONTRARIO, MARCAMOS EL SIGUIENTE COMO VACÍO. ES DECIR, ES LA LÍNEA DE META
      ]
    ]
    set t (t + 1)
    ;tick
  ]
  print "Terminado el recorrido"
  ask vehiculos [die] ; MATAMOS AL VÓLIDO DE LA ABEJA
  ;reset-ticks ; REINICIAMOS EL CONTADOR DE TICKS
  report fitness
end

; FUNCIONES AUXILIARES DE LA FUNCIÓN FITNESS

; FUNCIÓN CONSUMO DE COMBUSTIBLE
to-report consumoCombustible [aceleracion aceleracionAnterior]
  let tasaAceleracion 1
  let consumoTotal consumoBase
  if (aceleracion >= aceleracionAnterior)[
    if-else (aceleracionAnterior = 0) [set tasaAceleracion 1] [set tasaAceleracion (aceleracion / aceleracionAnterior)]
  ]
  set consumoTotal ((tasaAceleracion * aceleracion * penalizacionCombustible) + consumoTotal)
  report consumoTotal
end

; FUNCIÓN ¿VELOCIDAD ADECUADA?
to-report velocidadAdecuada? [volido]
  let v ([velocidad] of volido)
  let res false
  if ((minVelocidad <= v) and (v <= maxVelocidad)) [set res true]
  report res
end

; FUNCIÓN ¿MARCHA ATRÁS?
to-report marchaAtras? [volido]
  ; BUSCAMOS LOS EXTREMOS DEL CIRCUITO QUE SE ENCUENTREN EN LA RECTA PERPENDICULAR AL VÓLIDO... AUNQUE ES SUFICIENTE CON EL EXTREMO DERECHO
  let ilegalmenteColocado? (not (estaExtremoDerEnDer? volido))
  report ilegalmenteColocado?
end

; FUNCIONES ¿ESTÁ EXTREMO DERECHO EN DERECHA? Y ¿ESTÁ EXTREMO IZQUIERDO EN IZQUIERDA?
to-report estaExtremoDerEnDer? [volido]
   let anguloOriginal ([heading] of volido)
  ; CALCULAMOS EL ÁNGULO PERPENDICULARE AL VECTOR DIRECCIÓN DEL VÓLIDO
  let anguloDer (anguloOriginal + 90) ; GIRAMOS HACIA LA DERECHA
  if(anguloDer >= 360) [set anguloDer (anguloDer - 360)]
  ask volido [set heading anguloDer]
  let vectorUnitario (list ([dx] of volido) ([dy] of volido)); EL MALDITO NETLOGO ME OBLIGA A HACER LA PRESENTE BLASFEMIA
  ask volido [set heading anguloOriginal] ; RECUPERAMOS LOS CAMBIOS
  let posicion (list ([xcor] of volido) ([ycor] of volido))
  let res false
  let baldosaActual [0 0]
  ; RECORREMOS LA RECTA PERPENDICULAR POR LA DERECHA HASTA ENCONTRAR EL EXTREMO, SEA DERECHO O IZQUIERDO EN REALIDAD
  let sw true
  while [sw][
    set baldosaActual (patch (item 0 posicion) (item 1 posicion))
    if (member? baldosaActual extremoDer) [
      set res true
      set sw false
    ]
    if (member? baldosaActual extremoIzq) [
      set res false
      set sw false
    ]
    set posicion (list ((item 0 posicion) + (item 0 vectorUnitario)) ((item 1 posicion) + (item 1 vectorUnitario)))
  ]
  report res
end

; FUNCIÓN ¿PISA UNO DE LOS EXTREMOS DEL CIRCUITO?
to-report pisaExtremo? [volido]
  let baldosaActual (patch ([xcor] of volido) ([ycor] of volido))
  let res false
  if ((member? baldosaActual extremoDer) or (member? baldosaActual extremoIzq)) [set res true]
  report res
end

; ¡OJO! VIGILAR COMO EVITAR SOLAPAMIENTO EN ESTAS DOS FUNCIONES -> SOLUCIÓN: TENER EN CUENTA EL SIGUIENTE PUNTO DE CONTROL

; FUNCIÓN ¿HA ACABADO LA CARRERA?
to-report finCarrera? [volido siguientePuntoControl]
  let baldosaActual (patch ([xcor] of volido) ([ycor] of volido))
  let res false
  if ((member? baldosaActual lineaMeta) and (siguientePuntoControl = [])) [set res true]
  report res
end

; FUNCIÓN ¿PISA UN PUNTO DE CONTROL?
to-report pisaPuntoControl? [volido siguientePuntoControl]
  let baldosaActual (patch ([xcor] of volido) ([ycor] of volido))
  let res false
  if (member? baldosaActual siguientePuntoControl) [set res true]
  report res
end

;---------------------PSO---------------------------
to-report AI:Evaluation
  report funcionFitness
end

to AI:PSOExternalUpdate
  print "¡Nueva iteración!"
  print global-best-value
  print global-best-pos
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1063
864
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
40
77
166
110
NIL
dibujarLineaMeta
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
14
219
192
252
NIL
dibujarNuevoPuntoControl
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
19
272
191
305
NIL
borrarUltimoPuntoControl
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
38
122
173
155
NIL
dibujarExtremoDer
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
37
174
170
207
NIL
dibujarExtremoIzq
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
79
21
142
54
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
55
358
157
391
NIL
dibujarVolido
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
1142
10
1326
43
penalizacionCombustible
penalizacionCombustible
0
1
0.28
0.01
1
NIL
HORIZONTAL

SLIDER
1140
53
1312
86
minVelocidad
minVelocidad
0
1
0.11
0.01
1
m/s
HORIZONTAL

SLIDER
1141
94
1313
127
maxVelocidad
maxVelocidad
0
1
0.85
0.01
1
m/s
HORIZONTAL

SLIDER
1142
138
1314
171
consumoBase
consumoBase
0
1
0.27
0.01
1
NIL
HORIZONTAL

SLIDER
1141
186
1313
219
minTiempo
minTiempo
0
10000
200.0
100
1
ticks
HORIZONTAL

SLIDER
1141
233
1313
266
maxTiempo
maxTiempo
0
10000
4400.0
100
1
ticks
HORIZONTAL

SLIDER
1140
286
1312
319
numeroIteraciones
numeroIteraciones
1
50
6.0
1
1
NIL
HORIZONTAL

SLIDER
1141
330
1313
363
inerciaAbejas
inerciaAbejas
0
1
0.87
0.01
1
NIL
HORIZONTAL

SLIDER
1140
377
1312
410
atraccionPersonal
atraccionPersonal
0
1
0.31
0.01
1
NIL
HORIZONTAL

SLIDER
1141
427
1313
460
atraccionGlobal
atraccionGlobal
0
1
0.34
0.01
1
NIL
HORIZONTAL

SLIDER
1141
475
1313
508
limVelocidadAbejas
limVelocidadAbejas
0
100
5.1
0.01
1
NIL
HORIZONTAL

SLIDER
1144
527
1316
560
numAbejas
numAbejas
1
25
12.0
1
1
NIL
HORIZONTAL

BUTTON
67
406
130
439
NIL
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

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
0
@#$#@#$#@
