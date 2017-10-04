__includes ["PSO.nls"]

; Raza de tortugas que depende del modelo concreto que vamos a optimizar
breed [cars car]

; Propiedades de los coches del modelo que se optimiza
cars-own [
  speed       ; Velocidad instantánea del coche
  speed-limit
  speed-min ]


globals
[
  ; Variables globales usadas por el modelo de coches que se optimiza:
  ; Parámetros que se pueden modificar para optimizar la velocidad media de los coches
  acceleration        ; aceleración instantánea de los coches
  deceleration        ; deceleración instantánea de los coches
]

; Genera los coches que serán usados en cada experimento de cada partícula.
; Lo ejecuta cada partícula para cacular el valor de función asociado a ella.
to setup-cars
  ask cars [die]
  hatch-cars num-cars [
    set color blue
    ;ht ; se ocultan para no interferir con la visualización de las partículas
    pu
    set xcor random-xcor
    set ycor 0
    set heading  90
    ;;; set initial speed to be in range 0.1 to 1.0
    set speed  0.1 + random-float .9
    set speed-limit  1
    set speed-min  0
    set breed cars
    set shape "car"
    set size 1
    separate-cars
  ]
end

; this procedure is needed so when we click "Setup" we
; don't end up with any two cars on the same patch
to separate-cars  ;; turtle procedure
  if any? other cars-here
    [ fd 1
      separate-cars ]
end

to go-modelo
   ;; if there is a car right ahead of you, match its speed then slow down
  ask cars [
    let car-ahead one-of cars-on patch-ahead 1
    ifelse car-ahead != nobody
      [ set speed [speed] of car-ahead
        slow-down-car ]
      ;; otherwise, speed up
      [ speed-up-car ]
    ;;; don't slow down below speed minimum or speed up beyond speed limit
    if speed < speed-min  [ set speed speed-min ]
    if speed > speed-limit   [ set speed speed-limit ]
    fd speed ]
end

to slow-down-car  ;; turtle procedure
  set speed speed - deceleration
end

to speed-up-car  ;; turtle procedure
  set speed speed + acceleration
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PSO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; El siguiente procedimiento prepara el experimento de PSO
to setup
  clear-all

  ; crear partículas
  AI:Create-particles num-particulas 2
  reset-ticks
end

to-report AI:evaluation
  report funcion-caja-negra (first pos) (last pos)
end

; Función que permite usar el modelo de coches para relizar el cálculo.
; Esta es la función que realmente se optimiza.
to-report funcion-caja-negra [x y]
  ; Para que vaya más rápido, se impide la actualización gráfica
  no-display
  ; Generación de los coches para este experimento
  setup-cars
  ; Se fijan los valores de aceleración y deceleración asociados a esta partícula
  set acceleration x
  set deceleration y
  ; Se deja correr el modelo de coches 500 pasos
  repeat 100 [go-modelo]
  display

  ; Se devuelve la función que se quiere optimizar: la velocidad media de los coches
  report abs mean [speed] of cars
end

; La siguiente función muestra cómo se podría usar la funcion-caja-negra
; para repetir un experimento un número determinado de veces (n) y quedarnos con
; la media de los resultados
to-report f-repetida [n x y]
  report mean (n-values n [funcion-caja-negra x y])
end

; Procdimiento principal del agoritmo de optimización PSO
to go
  let best AI:PSO 20
                  inercia-particula
                  atraccion-a-mejor-personal
                  atraccion-al-global-mejor
                  lim-vel-particulas
end

to AI:PSOExternalUpdate
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
220
10
631
48
25
0
7.863
1
10
1
1
1
0
1
0
1
-25
25
0
0
1
1
1
ticks
30.0

BUTTON
16
174
88
215
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
116
174
187
214
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

PLOT
16
247
216
397
Valor del Mejor encontrado
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot global-best-value"

MONITOR
16
397
118
442
Mejor aceleracion
first global-best-pos
3
1
11

MONITOR
118
397
216
442
Mejor decelaracion
last global-best-pos
3
1
11

SLIDER
16
10
188
43
inercia-particula
inercia-particula
0
1
0.98
.01
1
NIL
HORIZONTAL

SLIDER
16
43
188
76
lim-vel-particulas
lim-vel-particulas
0
10
0.05
.01
1
NIL
HORIZONTAL

SLIDER
16
76
188
109
atraccion-a-mejor-personal
atraccion-a-mejor-personal
0
2
1
.01
1
NIL
HORIZONTAL

SLIDER
16
108
188
141
atraccion-al-global-mejor
atraccion-al-global-mejor
0
2
2
.01
1
NIL
HORIZONTAL

SLIDER
16
141
188
174
num-particulas
num-particulas
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
16
214
216
247
num-cars
num-cars
0
50
25
1
1
NIL
HORIZONTAL

@#$#@#$#@
Uno de los problemas más habituales cuando se construye un modelo para simular un proceso es que, tras haber definido un buen número de parámetros para darle más flexibilidad y generalidad con el fin de abarcar las situaciones más variopintas del proceso, no sabemos qué valores de esos parámetros serán los que puedan generar un comportamiento que resulte interesante. Para resolverlo, la primera tarea que abordamos es recorrer el espacio de parámetros como si fuera un bizcocho, pinchando aquí y allá para ver cómo se comporta el modelo en esos puntos aislados y esperando reconocer qué relación hay entre las zonas exploradas y los comportamientos observados. Éste problema de búsqueda en el espacio paramétrico, aunque bastante común, no está resuelto en general, ya que la dimensión del espacio suele ser alta (tanta como parámetros hayamos introducido), muchos de los parámetros pueden tomar valores continuos (habitualmente, muchos parámetros suelen tomar valores en un intervalo de **R**, y con una estructura de interrelaciones entre los diversos parámetros que muchas veces es compleja y alejada de un comportamiento lineal.

En esta ocasión vamos a ver un ejemplo muy particular de cómo ajustar estos parámetros para conseguir un fin concreto, que es el que se deriva de la optimización de alguna medición (en forma de variable medible) que podemos realizar sobre nuestro modelo. Aunque se presentará en forma de ejemplo concreto, esperamos que se pueda extraer una metodología relativamente general que puede ser aplicada a muchos otros casos.

Nuestro objetivo no es presentar una herramienta o metodología de carácter general, sino solo mostrar una idea de cómo combinar adecuadamente diversos modelos para facilitar la exploración de los comportamientos de uno de ellos. Una "composición" de modelos que, en este caso particular, se hará adaptando implementaciones de ellos realizadas previamente en NetLogo. Sin duda, no es el lenguaje más apropiado para realizar este tipo de composiciones de forma general, ya que no permite nada parecido al encapsulado de procedimientos ni a la utilización de espacios de trabajo independientes, pero a cambio NetLogo requiere muy poco esfuerzo para crear, adaptar y visualizar los resultados de nuestros modelos.

En particular, y solo por el hecho de seleccionar un sistema de optimización que es fácilmente implementable en NetLogo, vamos a mostrar cómo podemos aplicar una optimización basada en enjambres de partículas (PSO) sobre un segundo modelo (M). Para fijar ideas vamos a hacer las siguientes suposiciones:

M dispone de varios parámetros que se pueden ajustar, y que determinan la evolución del modelo.

  - En el mismo modelo podemos tomar varias medidas como resultado de su ejecución.
  - M dispone de un procedimiento (Setup) para inciar el modelo, y de un procedimiento (Go) para ejecutar cada paso de evolución del mismo.
   - n M fijamos algunos de sus parámetros y dejamos libres algunos otros: p_1,...,p_n;
  - En M fijamos uno de sus resultados medibles: r_1.
  - Como resultado, podemos interpretar el modelo como una función que recibe como dato de entrada (p_1,...,p_n) y devuelve r_1: notaremos la función por la misma letra M(p_1,...,p_n)=r_1.

La idea de optimizar el modelo M (respecto a r_1) es ver para qué valores de los parámetros obtenemos el máximo de esa medida... o lo que es lo mismo, optimizar la función anterior asociada a M.

Cualquier curso básico de optimización (o una búsqueda rápida acerca de recursos de optimización en internet) muestra muchos y diversos métodos de optimización de funciones. Como hemos comentado, utilizaremos para este ejemplo un algoritmo PSO para optimizar la función que calcula M debido a que tiene un comportamiento muy sencillo y lo tenemos ya implementado en NetLogo. Como en general la función que calcula M no la podemos calcular directamente por medio de una expresión matemática, tendremos que ejecutar el modelo asociado y medir el valor de r_1 de forma directa sobre el modelo tras haber permitido su evolución. Para poder hacer esto en NetLogo hemos de unir los modelos PSO y M para poder ejecutarlos en un espacio de programación común; es más, debemos poder ejecutar M desde el modelo PSO, y para conseguirlo se debe tener cuidado con unos pocos detalles:

Deben separarse ambos modelos desde el punto de vista de programación. Es decir, no deben tener objetos en común: ni razas de tortugas, ni variables globales, ni variables de patches (que es el único conjunto de agentes que no podemos personalizar completamente), ni nombres de procedimientos.

Como la evaluación de la función se debe llevar a cabo desde cada partícula, se deben añadir los parámetros que hemos dejado libres del modelo M como propiedades de las partículas. De hecho, en el caso concreto de PSO, estas variables serán las que se usarán como coordenadas de las partículas, ya que representan el espacio de movimiento de las mismas. Si solo son 2, podemos reutilizar adecuadamente xcor/ycor para que el movimiento de las partículas en el espacio de parámetros se corresponda con el movimiento de la raza de tortugas asociada al PSO en el mundo de NetLogo.

Se debe definir una función de evaluación(que será ejecutada por las partículas) que haga lo siguiente:

  - Ejecuta el Setup de M de acuerdo a los parámetros almacenados en la partícula, de forma que prepara un estado inicial de M acorde a la información que tiene la partícula.
  - Ejecuta el modelo M a partir de ese estado inicial. Para ello, normalmente se ejecutará el Go de M un número de pasos preestablecido, o hasta que se cumpla una cierta condición.
  - Una vez que M se ha detenido (o lo hemos detenido) se mide y devuelve el valor de r_1. En algunos casos podríamos estar interesados en devolver como medida algún agregado considerado a lo largo de la ejecución del modelo, por ejemplo, la media de valores de una cierta variable a lo largo de la ejecución.
  - Si el modelo incluye algún tipo de aleatoriedad, quizás es deseable hacer que este paso se repita algunas veces y la función devuelva el valor medio de los r_1 medidos (y quizás también desviación estándar o cualquier medida adicional).

Al igual que ocurre con los Algoritmos Genéticos, a la hora de aplicar PSO a un problema de optimización hay dos pasos clave: la representación del espacio de soluciones, y la función de bondad (fitness). Una de las ventajas que presenta PSO es que puede trabajar de forma natural con números reales, y las partículas se mueven por tanto en el espacio paramétrico sin necesidad de codificaciones intermedias. No ocurre así en el caso de los Algoritmos Genéticos, donde es necesario usar codificaciones de los problemas en cadenas (normalmente binarias) que puedan ser manipuladas por operadores genéticos. Por ejemplo, si intentamos encontrar una optimización de la función f(x) = x_1^2 + x_2^2+x_3^2, las partículas se definen inmediatamente como ternas (x_1, x_2, x_3), y la función de fitness es directamente la propia f(x). En consecuencia, el proceso de búsqueda se convierte en un proceso iterado muy cercano al problema real que se pretende resolver, donde la condición de parada vendrá dada por haber alcanzado el número máximo de iteraciones, o hemos satisfecho una condición de error mínimo.

Esta proyección natural de muchos problemas a las partículas que se usan en PSO hace que no haya muchos parámetros que deban ser ajustados para conseguir buenos resultados y, como veremos a continuación, la mayoría de ellos o bien quedan determinados por el propio problema que se está optimizando, o bien pueden prefijarse de forma independiente al problema en cuestión y se conocen (experimentalmente) valores que dan buenos resultados. Los más típicos son:

  - El número de partículas: el rango típico es entre 20 y 40. Realmente, para la mayoría de los problemas basta con 10 partículas para tener buenos resultados, y para los casos más difíciles se puede intentar con rangos entre 100 y 200 (muy por debajo de la "población" necesaria para otros métodos de optimización basados en poblaciones, como los algortimos genéticos).
  - Dimensión de las partículas: viene determinado por la dimensión del espacio paramétrico del problema a optimizar (número de parámetros).
  - Rango de las partículas (valores que toman): también viene determinado directamente por el problema, y tenemos la ventaja de poder especificar diferentes rangos para cada una de las dimensiones (o parámetros) de las partículas.
  - Vmax: determina la máxima variación que puede sufrir la posición de una partícula (sus parámetros) en cada iteración.
  - Factores de aprendizaje/atracción: Normalmente, y por razones experimentales, suelen tomarse como c_1=c_2=2 (recordemos que c_1 es la atracción al mejor personal de la historia de la partícula, y c_2 la atracción al mejor global encontrado por todas las partículas hasta el momento). Sin embargo, se tiene libertad para acomodarlos a las necesidades del problema. En la mayoría de los trabajos se suelen tomar c_1=c_2 y ambos en [0, 4].
  - Condición de parada: habitualmente suele venir dada por la combinación de un máximo número de iteraciones y un error mínimo que se debe alcanzar, que depende del problema a resolver.
  - Comunicación Global / Comunicación local: la comunicación global (que el máximo global se considere entre todas las partículas) es mucho más rápida, pero tiene el problema de que cae fácilmente en óptimos locales en algunos problemas. La comunicación local (que el máximo global para cada partícula se calcula únicamente entre unas cuantas partículas, el "entorno" de la partícula) es más lenta, pero no queda atrapada con tanta facilidad en esos óptmos locales. Puede usarse una combinación de ambas, usando la global para encontrar resultados rápidamente, y la local para refinar la búsqueda.
  - Factor de inercia: se comporta como un parámetro similar a los factores de aprendizaje, varía en [0,1] y si es próximo a 1 da mayor independencia a las partículas, permitiendo explorar más secciones del espacio paramétrico, pero a cambio de obtener las soluciones de forma más lenta.

Como demostración de lo anterior sobre un modelo sencillo, vamos a usar Traffic Basic (que se puede encontrar en la biblioteca de modelos de NetLogo bajo el nombre /Social Science/Traffic Basic).

Este modelo muestra el movimiento de coches en una carretera. Cada coche sigue un conjunto de reglas muy simple: frena si ve un coche cerca delante suya y acelera en caso contrario (tienen una visión de 1 patch). El modelo demuestra que pueden producirse atascos sin necesidad de accidentes en la carretera, cortes o vehículos excesivamente lentos... decir, no es necesaria una causa centralizada para la existencia de atascos, sino que surje por los efectos de la aceleración y deceleración de los propios coches. El modelo depende de 3 parámetros:

  - Número de coches: como el espacio es limitado, a mayor número de coches mayor probabilidad de tener que frenar cada coche.
  - Aceleración: indica la aceleración que hace cada coche si no tiene otro delante.
  - Deceleración: indica la frenada que hace cada coche si encuentra otro delante.

Vamos a trabajar solo con 2 parámetros en el PSO: aceleración/deceleración con unos rangos permitidos de [0,0.01]x[0,0.1], y como resultado mediremos la velocidad media de todos coches al cabo de 500 pasos. Por tanto, la función que vamos a optimizar es:

    M(a,d) = mean [speed] of cars

Fijamos previamente el número de coches, y el número de iteraciones que permitimos hacer al modelo que estamos optimizando. El hecho de quedarnos solo con 2 parámetros es simplemente por facilitar la visualización del proceso de optimización, ya que así podemos asociar las coordenadas de las partículas (xcor, ycor) con los parámetros que definen cada ejecución del modelo de tráfico. Para ello, habremos de tener en cuenta que hemos de transformar las coordenadas que la partícula tiene en el mundo en los valores adecuados del espacio paramétrico. Concretamente, nuestro mundo tiene unas dimensiones de [-25,25]x[-25,25], por tanto, para las coordenadas (x,y) de las partículas en el mundo hemos de aplicar la transformación:

    (x,y) -> ((25 + x) / 5000, (25 + y) / 500)

Tras haber unido en un solo fichero ambos modelos (el de tráfico y el de PSO) teniendo en cuenta los detalles a los que haciamos mención antes, creamos una función (que pueden ejecutar las partículas) que les permite simular el modelo de tráfico y devolver la media de velocidad de los coches:

    to-report funcion-caja-negra [x y]
      ; Para que vaya más rápido, se impide la actualización gráfica
      no-display
      ; Generación de los coches para este experimento
      setup-cars
      ; Se fijan los valores de aceleración y deceleración asociados a esta partícula
      set acceleration x
      set deceleration y
      ; Se deja correr el modelo de coches 500 pasos
      repeat 500 [go-modelo]
      display
      ; Se devuelve la función que se quiere optimizar: la velocidad media de los coches
      report mean [speed] of cars
    end

donde setup-cars es el nombre del procedimiento que inicia el modelo de tráfico, y go-modelo es el procedimiento que permite dar un paso en ese modelo. Debido a que el modelo de tráfico no se muestra (se ejecuta en segundo plano, pero sin visualizarse) su código ha sido limpiado de todo lo que afecta a la visualización y reducido a aquellos procedimientos que son imprescindibles para el cálculo del resultado.

Posteriormente, en los procedimientos que ejecutan el  PSO, cada vez que una partícula quiere calcular el valor asociado a sus coordenadas/parámetros debe ejecutar:

    let val funcion-caja-negra  ((xcor + 25) / 5000) ((ycor + 25) / 500)

En el código que se adjunta a esta entrada también se puede encontrar un reporte que permite calcular la media de __n__ repeticiones de la funcion-caja-negra. En la llamada anterior se puede sustituir funcion-caja-negra por f-repetida:

    to-report f-repetida [n x y]
      report mean (n-values n [funcion-caja-negra x y])
    end

Observa que, por lo demás, ambos modelos, el de tráfico y el de PSO, son prácticamente iguales a los de los modelos originales.
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
NetLogo 5.3.1
@#$#@#$#@
setup
repeat 180 [ go ]
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
