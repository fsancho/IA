+ [English](#evolutionary-computation)
+ [Spanish](#computación-evolutiva)

---------------------------

# Evolutionary Computation

Approximate content of the files in this folder:

+ `Biomorphs Girasol.nlogo`: Basic model of sexual and asexual reproduction demonstration to analyze how offspring can be directed.
+ `Sharks and evolutionary small fishes.nlogo`: An example of optimization by natural selection in hostile environments.
+ `Evolutionary Landscape.nlogo`: Shows how population optimization methods can be efficient when problem conditions change dynamically.
+ `Genetic Algorithm.nlogo`: Very basic example of a genetic algorithm for the optimization of a problem. It does not make use of the specific library developed for this topic.
+ `GeneticAlgorithm.nls`: **NetLogo Source file ** that contains the library to solve optimization problems making use of **GeneticAlgorithms**.
+ `Genetic Algorithm Simple Example.nlogo`: Very simple example of demonstration of use of the `GeneticAlgorithm` library. Functionally, it is the same problem as the one solved by `GeneticAlgorithm.nlogo`.
+ `Genetic Algorithm N Queens.nlogo` : Example of demonstration of use of the `GeneticAlgorithm` library that solves the N queens problem.
+ `Genetic Algorithm Functions.nlogo` : Example of demonstration of use of the `GeneticAlgorithm` library for the approximation of real functions in the interval [0,1]. It is a first step to the area of genetic programming.

## GeneticAlgorithm Instructions:

The **individuals** of the population are elements of the _AI:individuals_ family of turtles, which must contain (at least) the following properties:

+ Content` : Stores the content (value) of the state
+ `fitness?` : Stores the individual's Fitness value

The main function of the **GeneticAlgorithm** library is the `AI:GeneticAlgorithm` procedure, which repeats the main loop of iterations for the creation of the new generation of individuals from the current population. In addition, this procedure allows that after the creation of the new generation an external procedure is executed (that can be customized for each problem) in order to update the visualizations of the model or to make the pertinent calculations that correspond with the existing generation. This function returns one of the highest fitness individuals in the final population.

The input data that this procedure expects is:

+ `#num-iters` : Number of iterations (generations) that the algorithm will give
+ `#population` : Population (number) of individuals that each generation will have (in the current version, it does not change from one generation to another)
+ `#crossover-ratio` : % of crosses to be made in each iteration
+ `#mutation-ratio` : Probability of mutation of each individual DNA information unit

For the correct functioning of this library in the main model, the following procedures must be defined (which will allow it to be adapted to the specific problem to be solved with genetic algorithms):
   
+ `AI:Initial-Population [#population]` : Creates the initial population of individuals, establishing their content (_genetic code_).

+ `AI:Compute-fitness`: Report of AI:individual that calculates the value of _fitness_ that it has (according to its content).

+ `AI:Crossover [c1 c2]` : Custom crossing procedure. Receives as input data the contents of 2 parents and returns a list with the contents of the children after crossing. When the content can be expressed as a list, it is normal to use as a crossover the **one point random split**, so that if `a1|a2`, `b1|b2` are the two lists and a cut is chosen so that `long(ai)=long(bi)`, then the new lists are returned: `a1|b2`, `b1|a2`.

+ `AI:mutate [#mutation-ratio]` : Mutation procedure. It is executed by individuals, and receives as a parameter the probability that each unit of its content mutates.

+ `AI:ExternalUpdate` : Auxiliary procedure that will be executed after each iteration of the main loop. Normally, it will contain instructions to show or update model information.

In the example models you can see some valid definitions for different problems.

In addition, this library includes some procedures to calculate the **diversity** existing in the population from a predefined and customizable distance. Diversity is defined as the mean of all possible distances between individuals in the population. In the case of contents in the form of a list, it is usual to work with the **Hamming distance**, which is predefined in the library.

-----------------------------

# Computación Evolutiva

Contenido aproximado de los ficheros de esta carpeta:

+ `Biomorphs Girasol.nlogo`: Modelo básico de demostración de reproducción sexual y asexual para analizar cómo se puede dirigir la descendencia.
+ `Tiburones y pececillos evolutivos.nlogo`: Un ejemplo de optimizción por selección natural en entornos hostiles.
+ `Paisaje Evolutivo.nlogo`: Muestra cómo los métodos de optimización por poblaciones pueden ser eficientes cuando las condiciones del problema cambian dinámicamente.
+ `Algoritmo Genético.nlogo`: Ejemplo muy básico de algoritmo genético para la optimización de un problema. No hace uso de la librería específica desarrollada para este tema.
+ `GeneticAlgorithm.nls`: **Fichero Fuente de NetLogo (NetLogo Source)** que contiene la librería para resolver problemas de optimización haciendo uso de **Algoritmos Genéticos**.
+ `Genetic Algorithm Simple Example.nlogo`: Ejemplo muy simple de demostración de uso de la librería `GeneticAlgorithm`. Funcionalmente, es el mismo problema que el resuelto por `Algoritmo Genético.nlogo`.
+ `Genetic Algorithm N Queens.nlogo` : Ejemplo de de demostración de uso de la librería `GeneticAlgorithm` que resuelve el problema de las N reinas.
+ `Genetic Algorithm Funciones.nlogo` : Ejemplo de de demostración de uso de la librería `GeneticAlgorithm` para la aproximación de funciones reales en el intervalo [0,1]. Es un primer paso al área de la programación genética.

## Instrucciones de Uso de GeneticAlgorithm:

Los **individuos** de la población son elementos de la familia de tortugas _AI:individuals_, que deben contener (al menos) las siguientes propiedades:

+ `content`   : Almacena el contenido (valor) del estado
+ `fitness?`  : Almacena el valor de Fitness del individuo

La función principal de la librería **GeneticAlgorithm** es el procedimiento `AI:GeneticAlgorithm`, que se encarga de repetir el bucle principal de iteraciones para la creación de la nueva generación de inviduos a partir de la población actual. Además, este procedimiento permite que tras la creación de la nueva generación se ejecute un procedimiento externo (que puede ser personalizado para cada problema) con el fin de actualizar las visualizaciones del modelo o de hacer los cálculos pertinentes que corresponden con la generación existente. Esta función devuelve uno de los individuos com mayor fitness de la población final.

Los datos de entrada que espera este procedimiento son:

+ `#num-iters`       : Número de iteraciones (generaciones) que dará el algoritmo
+ `#population`      : Población (número) de individuos que tendrá cada generación (en la versión actual, no cambia de una generación a otra)
+ `#crossover-ratio` : % de cruzamientos que se harán en cada iteración
+ `#mutation-ratio`  : Probabilidad de mutación de cada únidad informativa del ADN de los individuos

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir los siguientes procedimientos (que permitirán adaptarla al problema concreto que se quiera resolver con algoritmos genéticos):
   
+ `AI:Initial-Population [#population]` : Crea la población inicial de individuos, estableciendo su contenido (_código genético_).

+ `AI:Compute-fitness`: Report de AI:individual que calcula el valor de _fitness_ que tiene (en función de su contenido).

+ `AI:Crossover [c1 c2]` : Procedimiento personalizado de cruzamiento. Recibe como dato de entrada el contenido de 2 padres y devuelve una lista con los contenidos de los hijos tras haber realizado el cruzamiento. Cuando el contenido se puede expresar en forma de lista, es normal usar como cruzamiento el **corte aleatorio por un punto**, de forma que si `a1|a2`, `b1|b2` son las dos listas y se elige un corte de forma que `long(ai)=long(bi)`, entonces se devuelven las nuevas listas: `a1|b2`, `b1|a2`.

+ `AI:mutate [#mutation-ratio]` : Procedimiento de mutación. Lo ejecutan los individuos, y recibe como parámetro la probabilidad de que cada unidad de su contenido mute.

+ `AI:ExternalUpdate` : Procedimiento auxiliar que se ejecutará tras cada iteración del bucle principal. Normalmente, contendrá instrucciones para mostrar o actualizar información del modelo.

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

Además, esta librería incluye algunos procedimientos para calcular la **diversidad** existente en la población a partir de una distancia predefinida y que se puede personalizar. La diversidad se define como la media de todas las posibles distancias entre lso individuos de la población. Para el caso de contenidos en forma de lista suele ser habitual trabajar con la **distancia de Hamming**, que viene predefinida en la librería.
