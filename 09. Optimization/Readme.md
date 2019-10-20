+ [English](#ant-optimization-and-pso)
+ [Spanish](#optimización-con-hormigas-y-pso)

---------------------------------------------------

# Ant Optimization and PSO

Approximate content of the files in this folder:

+ `AntSystem.nlogo`: Classic resolution of the TSP problem using ant colonies.
+ `Particle Swarm Optimization.nlogo`: An example of two-dimensional function optimization using particle swarms.
+ `PSO Traffic1D.nlogo`: Use of PSO for parameter optimization of simulation models. In this case, it is a sample of how population-based optimization methods can be efficient when problem conditions change dynamically.
+ `PSO.nls`: **NetLogo Source file** with the general library for the execution of the PSO algorithm.
+ `PSO Sample.nlogo`: Demonstration model of use of the `PSO.nls` library. The problem it solves is equivalent to that of `Particle Swarm Optimization.nlogo`.

## PSO Instructions:

The **particles** are elements of the _AI:particles_ family of turtles, which must contain (at least) the following properties:

+ `velocity` : Stores the linear velocity of the particle. It is a vector of `N` dimensions (parametric space).
+ `pos` : Stores the position of the particle in the parametric space (vector of `N` dimensions).
+ `personal-best-value` : Stores the best value through which this particle has passed.
+ `personal-best-pos` : Stores the position where the particle got the best value.

In addition, the system uses 2 global variables to store the best value found by the set of all particles in the system (`global-best-value`) and the position in which it was found (`global-best-pos`).

The main function of the **PSO** library is the `AI:PSO` procedure, which repeats the main loop of iterations to move the particles in each time unit. In addition, this procedure allows that after moving the particles in each iteration an external procedure is executed (that can be customized for each problem) in order to update the visualizations of the model or to make the pertinent calculations that correspond to the current position. The `AI:PSO` function returns the best overall value found and the position in which it was found.

The input data that the `AI:PSO` procedure waits for are:

+ `#iters` : Number of iterations that the algorithm will give.
+ `#inertia-particle` : Proportion of past velocity that intervenes in the calculation of the current velocity (inertia).
+ `#atraction-best-personal` : Indicates how much attraction force the particle feels towards the best value found by itself for the update of its new velocity.
+ `#atraction-best-global` : Indicates how much attraction force the particle feels towards the best value found by all particles for the update of its new velocity.
+ `#lim-vel-particles` : The maximum velocity value (modulus) that particles can reach.

In addition, previously, it must be indicated to the system to create the particles that are going to execute the previous algorithm by means of `AI:Create-particles`, which receives as input data:

+ `#population` : Number of particles that will form the system.
+ `#dimension` : Number of dimensions of the parametric space. The system considers that, by default, the particles move in the interval [0,1] for each dimension.

For the correct functioning of this library in the main model, the following procedures must be defined (which will allow it to be adapted to the specific problem to be solved with genetic algorithms):
   
+ `AI:Evaluation` : The particles can execute it and returns the evaluation that they have with respect to the function that is being optimized due to the position that they occupy in the space of parameters.

+ `AI:ExternalUpdate` : Auxiliary procedure that will be executed after each iteration of the main loop. Normally, it will contain instructions for displaying or updating model information. Among other things, as the main algorithm considers that the particles move in the interval [0,1] in each dimension, it will be in this procedure where we must worry about converting the position of the particle in [0,1] to the real value according to the real dimensions of the parameter space (for this, a function is provided `convert x a b` that receives `x` in [0,1] and returns the corresponding value in the interval `[a,b]`). 

In the example models you can see some valid definitions for different problems.

--------------------------------

# Optimización con Hormigas y PSO

Contenido aproximado de los ficheros de esta carpeta:

+ `AntSystem.nlogo`: Resolución clásica del problema TSP haciendo uso de colonias de hormigas.
+ `Particle Swarm Optimization.nlogo`: Un ejemplo de optimización de funciones bidimensionales haciendo uso de enjambres de partículas.
+ `PSO Trafico1D.nlogo`: Uso de PSO para optimización de parámetros de modelos de simulación. Muestra cómo los métodos de optimización por poblaciones pueden ser eficientes cuando las condiciones del problema cambian dinámicamente.
+ `PSO.nls`: **Fichero Fuente NetLogo (NetLogo Source)** con la librería general para la ejecución del algoritmo PSO.
+ `PSO Sample.nlogo`: Modelo de demostración de uso de la librería `PSO.nls`. El problema que resuelve es equivalente al de `Particle Swarm Optimization.nlogo`.

## Instrucciones de Uso de PSO:

Las **partículas** de la población son elementos de la familia de tortugas _AI:particles_, que deben contener (al menos) las siguientes propiedades:

+ `velocity`   : Almacena la velocidad lineal de la partícula. Es un vector de `N` dimensiones (el espacio paramétrico).
+ `pos`  : Almacena la posición de la partícula en el espacio paramétrico (vector de `N` dimensiones).
+ `personal-best-value` : Almacena el mejor valor por el que ha pasado esta partícula.
+ `personal-best-pos` : Almacena la posición en donde la partícula consiguió el mejor valor.

Además, el sistema usa 2 variables globales para almacenar el mejor valor encontrado por el conjunto de todas las partículas del sistema (`global-best-value`) y la posición en la que fue encontrado (`global-best-pos`).

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
