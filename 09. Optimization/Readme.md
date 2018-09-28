# [Optimización con Hormigas](http://www.cs.us.es/~fsancho/?e=71) y [PSO](http://www.cs.us.es/~fsancho/?e=70)

Contenido aproximado de los ficheros de esta carpeta:

+ `AntSystem.nlogo`: Resolución clásica del problema TSP haciendo uso de colonias de hormigas.
+ `Particle Swarm Optimization.nlogo`: Un ejemplo de optimización de funciones bidimensionales haciendo uso de enjambres de partículas.
+ `PSO Trafico1D.nlogo`: Uso de PSO para optimización de parámetros de modelos de simulación. En este caso, hace uso de Muestra cómo los métodos de optimización por poblaciones pueden ser eficientes cuando las condiciones del problema cambian dinámicamente.
+ `PSO.nls`: **Fichero Fuente NetLogo (NetLogo Source)** con la librería general para la ejecución del algoritmo PSO.
+ `PSO Sample.nlogo`: Modelo de demostración de uso de la librería `PSO.nls`. El problema que resuelve es equivalente al de `Particle Swarm Optimization.nlogo`.

## Instrucciones de Uso de PSO:

Las **partículas** de la población son elementos de la familia de tortugas _AI:particles_, que deben contener (al menos) las siguientes propiedades:

+ `velocity`   : Almacena la velocidad lineal de la partícula. Es un vector de `N` dimensiones (el espacio paramétrico).
+ `pos`  : Almacena la posición de la partícula en el espacio paramétrico (vector de `N` dimensiones).
+ `personal-best-value` : Almacena el mejor valor por el que ha pasado esta partícula.
+ `personal-best-pos` : Almacena la posición en donde la partícula consiguió el mejor valor.

Además, el sistema usa 2 variables globales para almacenar el mejor valor encontrado por el conjunto de todas las partículas del sistema (`global-best-value`) y la posición en la que fue encontrado (`gloabl-best-pos`).

La función principal de la librería **PSO** es el procedimiento `AI:PSO`, que se encarga de repetir el bucle principal de iteraciones para mover las partículas en cada unidad de tiempo. Además, este procedimiento permite que tras mover las partículas en cada iteración  se ejecute un procedimiento externo (que puede ser personalizado para cada problema) con el fin de actualizar las visualizaciones del modelo o de hacer los cálculos pertinentes que corresponden a la posición actual. La función `AI:PSO` devuelve el mejor valor global encontrado y la posición en la que fue encontrado.

Los datos de entrada que espera el procedimiento `AI:PSO`son:

+ `#iters` : Número de iteraciones que dará el algoritmo.
+ `#inertia-particle` : Interviene en la proporción de velocidad pasada que interviene en el cálculo de la velocidad actual (inercia).
+ `#atraction-best-personal` : Indica cuánta fuerza de atracción siente la partícula hacia el mejor valor encontrado por ella para la actualización de su nueva velocidad.
+ `#atraction-best-global` : Indica cuánta fuerza de atracción siente la partícula hacia el mejor valor encontrado por todas las partículas para la actualización de su nueva velocidad.
+ `#lim-vel-particles` : El valor (módulo) máximo de velocidad que pueden alcanzar las partículas.

Además, previamente, debe indicarse al sistema que cree las partículas que van a ejecutar el algoritmo anterior por medio de `AI:Create-particles`, que recibe como datos de entrada:

+ `#population` : Número de partículas que formarán el sistema.
+ `#dimension` : Número de dimensiones del espacio paramétrico. El sistema considera que, por defecto, las partículas se mueven en el intervalo [0,1] para cada dimensión.

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir los siguientes procedimientos (que permitirán adaptarla al problema concreto que se quiera resolver con algoritmos genéticos):
   
+ `AI:Evaluation` : Lo pueden ejecutar las partículas y devuelve la evaluación que tienen respecto a la función que se quiere optimizar debido a la posición que ocupan en el espacio de parámetros.

+ `AI:ExternalUpdate` : Procedimiento auxiliar que se ejecutará tras cada iteración del bucle principal. Normalmente, contendrá instrucciones para mostrar o actualizar información del modelo. Entre otras cosas, como el algoritmo principal considera que las partículas se mueven en el intervalo [0,1] en cada dimensión, será en este procedimiento donde nos debemos preocupar de convertir la posición de la partícula en [0,1] al valor real según las dimensiones reales del espacio de parámetros (para ello, se proporciona una función `convert x a b` que recibe `x` en [0,1] y devuelve el valor correspondiente en el intervalo `[a,b]`. 

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.
