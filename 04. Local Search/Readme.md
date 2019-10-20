+ [English](#local-search)
+ [Spanish](#búsquedas-locales)

------------------------

# Local Search

List of files associated with Local Search:

+ `SimulatedAnnealing.nls`: NetLogo Source File with the generic algorithms associated to the Simulated Annealing.
+ `Simulated Annealing Sorting Lists.nlogo`: Model to solve the problem of sorting lists using the general library of Simulated Annealing.
+ `Simulated Annealing N Queens.nlogo": N queens problem solution model using the general library of Simulated Annealing.
+ ' SimulatedAnnealingNonogram.nlogo`: Nonograms puzzle solution model making use of Simulated Tempering (attention: this model includes its own Simulated Annealing algorithm, it does not make use of the previous general library).
+ `SimulatedAnnealingSudoku.nlogo`: Sudoku puzzle solution model making use of Simulated Annealing (note: this model includes its own Simulated Annealing algorithm, it does not make use of the previous general library).
+ `SimulatedAnnealingSudoku2.nlogo`: Sudoku puzzle solution variant making use of Simulated Annealing (note: this model includes its own Simulated Annealing algorithm, it does not make use of the previous general library). The difference with the previous one is that this model allows prefixing a few elements, as they come in the newspapers.
+ `HilClimbingPatches.nlogo`: Basic example model of the Ascent of the Hill with one or several search engines, working on patches. It also shows an experiment to compare the real efficiency of the search system when the number of search engines increases.
+ `HillClimbingNetwork.nlogo`: Basic example model of the Ascent of the Hill with one or several search engines, working on generic graphs. 

# Instructions for SimulatedAnnealing

This library allows to apply the general Simulated Annealing algorithm on abstractly represented problems that verify some slight restrictions. To do this, the library works with the following global reserved variables:

As only one randomly modified state is maintained, it is not necessary to use a family of agents to store it, but it is necessary to maintain a set of global values that indicate the evolution and configuration of the process in each iteration. To do this, the following global variables will be used:

+ `AI:SimAnnGlobalEnergy`: Stores the energy of the current state.
+ `AI:SimAnnTemperature`: Stores the current temperature of the system.
+ `AI:accept-equal-changes?`: Indicates if the algorithm would accept to change the current state in case of energy equality.

The main function of the **SimulatedAnnealing** library is the `AI:SimAnn` procedure, which performs the search among the states of the space following the Simulated Annealing algorithm. Essentially, it generates random states from the current state and performs the state change in favorable case (which decreases the energy of the system, or randomly with a probability equal to the temperature of the system).

The input data that this procedure expects is:

+ `#Initial-state`: Initial state from which the search begins.
+ `#tries-by-cycle`: Number of states that will be built in each cycle of the main loop (all of them with the same temperature).
+ `#mim-Temp`: Minimum temperature at which it will stop searching (if no null energy has been found before).
+ '#cooling-rate`: Ratio of cooling of the temperature in each cycle.
+ `#aec`: True/False ... if we accept changes with the same energy.

For the correct operation of this library in the main model, the following functions must be defined:

+ `AI:get-new-state`: that receives a state and generates another one from it (normally, at random between the possible transitions).
+ `AI:EnergyState`: that receives a state and returns the energy associated with it.
+ `AI:SimAnnExternalUpdates`: additional auxiliary procedure that will be executed in each cycle of the main algorithm, for example, to show information during the execution or to update the values of agents of the world.

In the example models you can see some valid definitions for different problems.

---------------------------

# Búsquedas Locales

Lista de ficheros asociados a Búquedas Locales:

+ `SimulatedAnnealing.nls`:	Fichero Fuente de NetLogo con los algoritmos genéricos asociados al Templado Simulado.
+ `Simulated Annealing Sorting Lists.nlogo`:	Modelo de solución del problema de ordenación de listas haciendo uso de la librería general de Templado Simulado.
+ `Simulated Annealing N Queens.nlogo`:	Modelo de solución del problema de las N reinas haciendo uso de la librería general de Templado Simulado.
+ `SimulatedAnnealingNonogram.nlogo`: Modelo de solución de puzles Nonogramas haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku.nlogo`: Modelo de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku2.nlogo`: Variante de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior). La diferencia con el anterior es que este modelo permite prefijar unos cuantos elementos, tal y como vienen en los periódicos.
+ `HilClimbingPatches.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre patches. También muestra un experimento para comparar la eficiencia real del sistema de búsqueda cuando se incrementa el número de buscadores.
+ `HillClimbingNetwork.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre grafos genéricos. 

# Instrucciones de uso de SimulatedAnnealing

Esta librería permite aplicar el algoritmo de Templado Simulado general sobre problemas representados de forma abstracta que verifiquen algunas ligeras restricciones. Para ello, la librería trabaja con las siguientes variables globales reservadas:

Como solo se mantiene un estado que va modificándose aleatoriamente, no es necesario el uso de una familia de agentes para almacenarlo, pero se debe mantener un conjunto de valores globales que indiquen la evolución y configuración del proceso en cada iteración. Para ello, se hará uso de las siguientes variables globales:

+ `AI:SimAnnGlobalEnergy`: Almacena la energia del estado actual.
+ `AI:SimAnnTemperature`: Almacena la temperatura actual del sistema.
+ `AI:accept-equal-changes?`: Indica si el algoritmo aceptara cambiar el estado actual en caso de igualdad de energía.

La función principal de la librería **SimulatedAnnealing** es el procedimiento `AI:SimAnn`, que realiza la búsqueda entre los estados del espacio siguiendo el algoritmo de Templado Simulado. Esencialmente, va generando estados al azar a partir del estado actual y se realiza el cambio de estado en caso favorable (que disminuya la energía del sistema, o al azar con una probabildiad igual a la tempertaura del sistema)

Los datos de entrada que espera este procedimiento son:

+ `#Initial-state`: Estado inicial desde el que comienza la búsqueda.
+ `#tries-by-cycle`: Número de estados que se construirán en cada ciclo del bucle principal (todos ellos con la misma temperatura).
+ `#mim-Temp`: Temperatura mínima a la que parará a búsqueda (si no se ha encontrado energía nula antes).
+ `#cooling-rate`: Ratio de enfriamiento de la temperatura en cada ciclo.
+ `#aec`: True/False ... si aceptamos cambios con la misma energía .

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir las siguientes funciones:

+ `AI:get-new-state`: que recibe un estado y genera otro a partir de él (normalmente, al azar entre las transiciones posibles).
+ `AI:EnergyState`: que recibe un estado y devuelve la energía asociada a él.
+ `AI:SimAnnExternalUpdates`: procedimiento adicional auxiliar que se ejecutará en cada ciclo del algoritmo principal, por ejemplo, para mostrar información durante la ejecución o actualizar los valores de agentes del mundo.

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.
