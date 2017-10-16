# Búsquedas Locales

Lista de ficheros asociados a Búquedas Locales:

+ `SimulatedAnnealing.nls`:	Fichero Fuente de NetLogo3D con los algoritmos genéricos asociados al Templado Simulado.
+ `Simulated Annealing Sorting Lists.nlogo`:	Modelo de solución del problema de ordenación de listas haciendo uso de la librería general de Templado Simulado.
+ `Simulated Annealing N Queens.nlogo`:	Modelo de solución del problema de las N reinas haciendo uso de la librería general de Templado Simulado.
+ `SimulatedAnnealingNonogram.nlogo`: Modelo de solución de puzles Nonogramas haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku.nlogo`: Modelo de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior).
+ `SimulatedAnnealingSudoku2.nlogo`: Variante de solución de puzles Sudoku haciendo uso de Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior). La diferencia con el anterior es que este modelo permite prefijar unos cuantos elementos, tal y como vienen en los periódicos.
+ `Templado Simulado.nlogo`:	Modelo de ejemplo básico del Templado Simulado (atención: este modelo incluye un algoritmo propio de Templado Simulado, no hace uso de la librería general anterior). 
+ `Ascenso Colina.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores. 
+ `Ascenso Colina 3D.nlogo3d`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, versión 3D. 
+ `HilClimbingPatches.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre patches. 
+ `HillClimbingNetwork.nlogo`:	Modelo de ejemplo básico del Ascenso de la Colina con uno o varios buscadores, trabajando sobre grafos genéricos. 

# Instrucciones de uso de SimulatedAnnealing

Esta librería es realmente una extensión de la librería BFS explicada en el apartado de [Uninformed Search](https://github.com/fsancho/IA/tree/master/02.%20Uninformed%20Search), en consecuencia, tanto los estados (_AI:states_) como las transiciones (_AI:transitions_) siguen un comportamiento similar y se muestran aquí únicamente las diferencias.

Los estados se representan por medio de la familia de tortugas _AI:states_, que deben contener (al menos) las siguientes propiedades:

+ `content` : Almacena el contenido (valor) del estado
+ `depth` : Indica la profundidad del estado dentro respecto del estado inicial (de uso en algunas de las funcionalidades de LayoutSpace para la representación).

Las transiciones, que permiten convertir estados entre sí, vienen representados por medio de la familia de links _AI:transitions_, que deben contener (el menos) las siguientes propiedades:

+ `rule` : Almacena información varia acerca de la transición. Debe tener una estructura determinada que se explica a continuación.
+ `cost-link` : Almacena el coste de la transición.

Al igual en la librería BFS, en este caso necesitamos que las reglas usen una forma de lista `["rep" coste ..]`,  que debe tener en su primera componente una representación imprimible de la regla, ya que esta componente será usada para dar una versión comprensible por el humano de las transiciones usadas en los procesos, y en la segunda componente el coste de aplicar dicha regla. En los modelos de ejemplo anteriores se pueden ver usos válidos de las reglas.

Además, el algoritmo A* almacena toda la información la búsqueda en una familia adicional de agentes denominada AI:searchers, que tienen las siguientes propiedades:

+ `memory` : Almacena el camino de nodos que ha recorrido A* desde el estado inicial hasta el nodo en el que se encuentra este buscador
+ `cost` : Almacena el coste real del camino recorrido desde el estado inicial.
+ `total-expected-cost` : Almacena el coste total esperado desde el estado inicial hasta el objetivo.
+ `current-state`: Almacena el estado (_AI:state_) en el que se encuentra este buscador
+ `active?` : Establece si este buscador esta activo, es decir, si los estados vecinos al suyo han sido explorados o no.

La función principal de la librería **A-star** es el procedimiento `A*`, que construye el grafo de estados que se obtiene a partir de un estado inicial dado (siguiendo la selección heurística definida por el usuario) y comprueba si el estado objetivo ha sido alcanzado o no. El grafo de estados subyacente se va construyendo de forma dinámica a medida que va siendo necesario. 

Esencialmente, el algoritmo calcula recursivamente los estados sucesores del estado que la heurística dice que hay que expandir y los conecta por medio de links (_AI:transitions_). Este proceso se repite hasta alcanzar el estado objetivo y estamos seguros de que es el camino óptimo (por lo que, quizás, tras haberlo alcanzado, haya que cerrar algunos nodos más) o si se ha terminado de recorrer el espacio completo y no se ha alcanzado el objetivo. `A*` es por tanto un report, que devolverá:

+ `False` si no ha habido éxito en la búsqueda.
+ La memoria del buscador que ha alcanzado un estado final.

Ha de tenerse en cuenta que la búsqueda podría dar como resultado un proceso infinito, lo que en NetLogo puede provocar problemas de estabilidad en el motor de ejecución.

Los datos de entrada que espera este procedimiento son:

+ `#initial-state` : Contenido del estado inicial que dará comienzo a la construcción.
+ `#final-state` : Contenido del estado final que se busca. En caso de que el estado final venga dado por una condición de parada, pero no por un estado concreto (como en el problema de las _N reinas_), esa condición de parada vendrá dada por un report que se explicará a continuación, y en este caso podemos pasarle cualquier dato como estado final, ya que no lo considerará.
+ `#debug?` : `True / False` - Indica si se mostrará el contenido en los estados, y las reglas en las transiciones.
+ `#visible?` : Muestra/Oculta estados y transiciones en el interfaz.

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir las siguientes funciones:

+ `children-states` : Lo pueden ejecutar los estados, y devuelve una lista con información sobre los posibles sucesores del estado que lo ejecuta. En este sentido, cada estado devuelto deber ser un par `[s r]`, donde `s` es el contenido del nuevo estado, y `r` es una regla con la estructura vista anteriormente (`["rep" c ...]`).

+ `final-state?` : Lo pueden ejecutar los estados y devuelve si el estado actual debe ser considerado un estado final. Este procedimeinto recibe como entrada un parámetro que, por ejemplo, permita comparar el estado actual con el `#final-state` en caso de que dicho estado final sea un estado concreto. Si no fuera así, el parámetro pasado no tiene utilidad y la verificación de si es final o no solo se basará en propiedades internas al estado actual.

+ `heuristic` : lo pueden ejecutar los buscadores. Recibe como entrada el objetivo buscado, y devuelve el valor de la heurística que se usará para medir la distancia entre el estado en el que se encuentra el buscador y el objetivo.

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

# Instrucciones de uso de LayoutSpace

Véase el [apartado equivalente en BSS](https://github.com/fsancho/IA/blob/master/01.%20State%20Space%20Search/README.md).
