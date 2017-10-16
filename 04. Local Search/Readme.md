# Búsquedas Locales

Lista de ficheros asociados a Búquedas Locales:

+ `SimulatedAnnealing.nls`:	Fichero Fuente de NetLogo3D con los algoritmos genéricos asociados al Templado Simulado.
+ `Simulated Annealing Sorting Lists.nlogo`:	Modelo de solución del problema de ordenación de listas haciendo uso de la librería general de Templado Simulado.
+ `Simulated Annealing N Queens.nlogo`:	Modelo de solución del problema de las N reinas haciendo uso de la librería general de Templado Simulado.
+ `SimulatedAnnealingNonogram.nlogo`: Modelo de solución de puzles Nonogramas haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku.nlogo`: Modelo de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku2.nlogo`: Variante de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior). La diferencia con el anterior es que este modelo permite prefijar unos cuantos elementos, tal y como vienen en los periódicos.
+ `HilClimbingPatches.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre patches. También muestra un experimento para comparar la eficiencia real del sistema de búsqueda cuando se incrementa el número de buscadores.
+ `HillClimbingNetwork.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre grafos genéricos. 

Además, en la versión 5.3.1 se puede encontrar la extensión `rnd`, de la que hace uso la librería, pero que va incluida de serie a partir de la versión 6.0.

# Instrucciones de uso de SimulatedAnnealing

Esta librería permite aplicar el algoritmo de Templado Simulado general sobre problemas representados de forma abstracta que verifiquen algunas ligeras restricciones. Para ello, la librería trabaja con las siguientes variables globales reservadas:

Los estados se representan por medio de la familia de tortugas _AI:states_, que deben contener (al menos) las siguientes propiedades:

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
