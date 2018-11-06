patches-own [Perfil-Cultural]

to setup
  ca
  set-current-plot "Distribución por Colores"
  set-plot-y-range 0 (max-pxcor + 1) * (max-pycor + 1)
  ;; inicializamos todos los patches
  ask patches
    [
    ;;Crea una lista que almacena los rasgos de cada característica
    ;;   que son simplemente valores numéricos aleatorios
    set Perfil-Cultural n-values caracteristicas [random rasgos]
    ;;Asigna-Color los patches según los valores de su Perfil-Cultural
    Asigna-Color
    ]
  reset-ticks
end

to go
  ;; Actualiza los Perfiles culturales
  ask patches
    [
    Comparte-Perfiles
    Asigna-Color
    ]
  if (ruido > random 1000)
    [
    ask one-of patches [perturba]
    ]
  tick
  ;; Actualiza las Gráficas
  actualiza-graficos
end

;; Cada Patch ejecuta el siguiente código
to Comparte-Perfiles
  ;; Seleccionamos aleatoriamente uno de los vecinos y su perfil cultural
  let vecino one-of neighbors
  let Perfil-Cultural-vecino [Perfil-Cultural] of vecino

  ;; En difieren almacenamos las posiciones de las caracetrísticas en que difieren
  let difieren filter [ ?1 -> ?1 != -1 ]
              (map [ [?1 ?2 ?3] -> diferencia ?1 ?2 ?3 ]
                   Perfil-Cultural
                   Perfil-Cultural-vecino
                   (n-values caracteristicas [ ?1 -> ?1 ]))

  ;; Calculamos el número de coincidencias
  let coincidencias (caracteristicas - length difieren) / caracteristicas

  ;; Si hay coincidencias (pero no son exactos), se el patch copia alguna de las características
  ;; de su vecino que no tiene. Pero con probabilidad proporcional a la similitud entre ambos.
  if ((coincidencias > (random-float 1)) and (coincidencias < 1))
  [
      let indicecambio one-of difieren ;; seleccionamos una de las diferencias
      let Rasgo item indicecambio Perfil-Cultural-vecino ;; Tomamos el valor de esa caracetrística del vecino
      set Perfil-Cultural replace-item indicecambio Perfil-Cultural Rasgo ;; y lo copiamos en el patch
  ]
end

;; El color asignado a cada patch para representarlo se calcula en función de sus 3 primeras características
to Asigna-Color
    set pcolor approximate-rgb
                (255 * (item 0 Perfil-Cultural) / rasgos)
                (255 * (item 1 Perfil-Cultural) / rasgos)
                (255 * (item 2 Perfil-Cultural) / rasgos)
end

; Report usado para calcular los caracteres en que difieren
to-report diferencia [x y z]
  if-else (x = y)
    [report -1]
    [report z]
end

;; Modifica aleatoriamente una característica
to perturba
    ;; Seleccionamos una de las características aleatoriamente
    let indice (random caracteristicas)
    ;; Asignamos a esa característica un valor aleatorio
    set Perfil-Cultural replace-item indice Perfil-Cultural (random rasgos)
end

to actualiza-graficos
  if not Graficos? [ stop ]
  set-current-plot "Distribución por Colores"
  clear-plot
  set-plot-y-range 0 (max-pxcor + 1) * (max-pycor + 1)
  foreach (n-values 140 [ ?1 -> ?1 ])
    [ ?1 -> set-plot-pen-color ?1
    plotxy ?1 count patches with [abs ( pcolor - ?1) <= 1]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
175
10
498
334
-1
-1
15.0
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
20
0
20
1
1
1
ticks
30.0

BUTTON
90
100
165
133
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

BUTTON
5
100
85
133
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

SLIDER
5
65
165
98
rasgos
rasgos
2
15
4.0
1
1
NIL
HORIZONTAL

SWITCH
10
335
134
368
Graficos?
Graficos?
0
1
-1000

SLIDER
5
30
165
63
caracteristicas
caracteristicas
3
15
5.0
1
1
NIL
HORIZONTAL

SLIDER
5
135
165
168
ruido
ruido
0
1000
0.0
1
1
NIL
HORIZONTAL

PLOT
10
370
797
535
Distribución por Colores
NIL
NIL
0.0
140.0
0.0
10.0
false
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

@#$#@#$#@
##¿QUÉ ES?

Si el proceso de imitación local es una característica dominante en la vida cultural, ¿por qué existe tanta diversidad cultural en el mundo? Este modelo muestra la respuesta de Robert Axelrod a esta paradoja acerca de la difusión cultural. Cada patch funciona bajo un proceso de imitación local basado en la homofilia (similitud de rasgos) con sus vecinos.  Mientras que los vecindarios locales convergen a un conjunto de rasgos, bajo ciertas condiciones la población diverge, creando grupos multiculturales.

##¿CÓMO FUNCIONA?

En cada ronda, cada patch mira a uno de sus vecinos (seleccionado aleatoriamente), y calcula la similitud con él. Con una probabilidad igual a esa similitud, modifica uno de sus características para parecerse más a él. En consecuencia, cuanto más similares son dos patches, más similares se volverán.  
Además, el modelo admite introducir ruido: aleatoriamente, dependiendo de la fuerza del ruido, se selecciona un patch en cada ronda y se modifica aleatoriamente alguna de sus características.

##¿CÓMO SE USA?

Las barras deslizantes permiten seleccionar el número de CARACTERISTICAS que tendrá cada patch, así como el número de diferentes valores que dichas características podrán tener (RASGOS). La barra de RUIDO permiter dar la probabilidad de que, en cada ronda, uno de los patches se modifique aleatoriamente. La representación gráfica en forma de colores solo tiene encuenta los valores de las tres primeras características (algo que hay que modificar).

## COSAS A INTENTAR

Intentar determinar para qué parámetros el modelo converge a una situación de multiculturalidad frente a una de monoculturalidad. ¿Cómo afecta el número de rasgos, características, tamaño del mundo?

## EXTENDIENDO EL MODELO

Añadir repulsión (xenofobia) al modelo, de forma que un patch tiende a distanciarse más de los que tienen menos similitud con él.

## CREDITOS Y BIBLIOGRAFIA

Basado en las idea de Robert Axelrod, "Dissemination of Culture", Journal of Conflict Resolution, 1997.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250
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
1
@#$#@#$#@
