+ [English](#informed-search)
+ [Spanish](#búsquedas-informadas)

---------------------------

# Informed Search

List of files associated with Informed Search: The following is a list of files associated with Informed Searches:

+ `A-star.nls`: NetLogo Source File with the generic algorithms associated with the A* Informed Search.
+ `LayoutSpace.nls`: NetLogo Source File that contains the library to visualize calculated state spaces (for BFS and other libraries that make use of similar structures).
+ `A-star Problem Solver - Numerical Puzzle.nlogo`: Model of A* solution of the _numerical _puzle_ problem.
+ `A-star Problem Solver - Sorting Lists.nlogo`: Model of A* solution of the problem of sorting lists.
+ A-star Problem Solver - 8 puzzle.nlogo`: Model of A* solution of the _8 puzzle_ problem.
+ A-star Problem Solver - Hanoi Towers.nlogo`: Model of A* solution of the _Hanoi Towers_ problem.
+ A-star Problem Solver - Figures and Letters.nlogo`: Model of A* solution of the _Numbers and Letters_ problem (only Numbers).
+ A-star Problem Solver - Cards.nlogo`: Model of A* solution of the _deck of cards_ problem.
+ `A-star Turtles Geometric Network.nlogo`: Model of use of the A* algorithm in the search of minimum paths for geometrical networks. It does not make use of the A-star library.
+ `A-star patches.nlogo`: Model of use of the A* algorithm in the search for minimum paths on patches. It does not make use of the A-star library.
+ `a-star_2009.nlogo`: Model of use of the A* algorithm in the search for minimum paths on patches. It does not make use of the A-star library. Shows different heuristics of distances to compare results.

# Instructions for A-star

This library is actually an extension of the BFS library explained in [Uninformed Search](https://github.com/fsancho/IA/tree/master/02.%20Uninformed%20Search), therefore, both the states (_AI:states_) and the transitions (_AI:transitions_) follow a similar behavior and only the differences are shown here.

The states are represented by the _AI:states_ family of turtles, which must contain (at least) the following properties:

+ `content` : Stores the content (value) of the state
+ `depth` : Indicates the depth of the state inside with respect to the initial state (used in some of the functionalities of LayoutSpace for representation).

Transitions, which allow you to convert states to each other, are represented by the _AI:transitions_ family of links, which must contain (at least) the following properties:

+ `rule` : Stores several information about the transition. It must have a certain structure that is explained below.
+ cost-link` : Stores the cost of the transition.

As in the BFS library, in this case we need the rules to use a `["rep" cost ..]` list format, which must have in its first component a printable representation of the rule, since this component will be used to give a human-comprehensible version of the transitions used in the processes, and in the second component the cost of applying the rule. Valid uses of the rules can be seen in the example models above.

In addition, the A* algorithm stores all the search information in an additional family of agents called _AI:searchers_, which have the following properties:

+ `memory` : Stores the path of nodes that has traveled A* from the initial state to the node in which this searcher is located.
+ `cost` : Stores the real cost of the road travelled since the initial state.
+ `total-expected-cost` : Stores the total expected cost from the initial state to the target.
+ `current-state`: Stores the state (_AI:state_) in which this searcher is located.
+ `active?` : Sets whether this searcher is active or not, that is, whether the states neighboring yours have been scanned or not.

The main function of the **A-star** library is the `A*` procedure, which builds the state graph obtained from a given initial state (following the heuristic selection defined by the user) and checks whether the target state has been reached or not. The underlying state graph is built dynamically as needed. 

Essentially, the algorithm recursively calculates the successor states of the state that heuristics says must be expanded and connects them by means of links (_AI:transitions_). This process is repeated until reaching the objective state and we are sure that it is the optimal path (so, perhaps, after having reached it, it is necessary to close some more nodes) or if the complete space has been traveled and the objective has not been reached. A*` is therefore a report, which will return:

+ False' if the search was not successful.
+ The memory of the search engine that has reached a final state.

It should be noted that the search could result in an infinite process, which in NetLogo can cause stability problems in the execution engine.

The input data that this procedure expects are:

+ `#initial-state` : Content of the initial state that will start the construction.
+ `#final-state` : Content of the final state to be searched. In case the final state is given by a stop condition, but not by a specific state (as in the problem of _N queens_), that stop condition will be given by a report that will be explained next, and in this case we can pass any data to it as a final state, since it will not consider it.
+ `#debug?` : `True / False` - Indicates if the content will be shown in the states, and the rules in the transitions.
+ `#visible?` : Shows/hides states and transitions in the interface.

For the correct functioning of this library in the main model, the following functions must be defined:

+ `children-states` : It can be executed by states, and it returns a list with information about the possible successors of the state that executes it. In this sense, each returned state must be a `[s r]` pair, where `s` is the content of the new state, and `r` is a rule with the structure previously seen (`["rep" c ...]`).

+ `final-state?` : It can be executed by states and returns if the current state is to be considered a final state. This procedure receives as input a parameter that, for example, allows to compare the current state with the `#final-state` in case that final state is a concrete state. If not, the passed parameter is useless and the verification of whether it is final or not will only be based on properties internal to the current state.

+ `heuristic` : can be run by searchers. It receives as input the searched target, and returns the value of the heuristic that will be used to measure the distance between the state in which the searcher is and the target.

+ `equal?` : a report that decides when two states are equal. Many times it may simply be the comparator `=`, but if the content of the states is a more complex structure (for example, a set represented by a list) it may be necessary to define a more elaborate equality (for example, in the previous case, which does not depend on the order).

Some valid definitions for different problems can be seen in the example models.

# Instructions for LayoutSpace

See [equivalent section in BSS](https://github.com/fsancho/IA/blob/master/01.%20State%20Space%20Search/README.md).

----------------

# Búsquedas Informadas

Lista de ficheros asociados a Búquedas Informadas:

+ `A-star.nls`:	Fichero Fuente de NetLogo con los algoritmos genéricos asociados a la Búsqueda Informada con A*.
+ `LayoutSpace.nls`:	Fichero Fuente de NetLogo que contiene la librería para visualizar espacios de estados calculados (para BFS y otras librerías que hacen uso de estructuras similares).
+ `A-star Problem Solver - Numerical Puzzle.nlogo`:	Modelo de solución A* del problema del _puzle numérico_.
+ `A-star Problem Solver - Sorting Lists.nlogo`:	Modelo de solución A* del problema de ordenación de listas.
+ `A-star Problem Solver - 8 puzzle.nlogo`:	Modelo de solución A* del _problema del 8 puzle_.
+ `A-star Problem Solver - Hanoi Towers.nlogo`: Modelo de solución A* del _problema de las Torres de Hanoi_.
+ `A-star Problem Solver - Cifras y Letras.nlogo`: Modelo de solución A* del _problema de Cifras y Letras (Cifras)_.
+ `A-star Problem Solver - Cartas.nlogo`: Modelo de solución A* del _problema de la baraja de cartas_.
+ `A-star Turtles Geometric Network.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos de grafos geométricos. No hace uso de la librería A-star.
+ `A-star patches.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos sobre patches. No hace uso de la librería A-star.
+ `a-star_2009.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos sobre patches. No hace uso de la librería A-star. Muestra distintas heurísticas de distancias para poder comparar resultados.

# Instrucciones de uso de A-star

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

+ `equal?` : un report que decide cuándo dos estados son iguales. Muchas veces podrá ser simplemente el comparador `=`, pero en caso de que el contenido de los estados sea una estructura más compleja (por ejemplo, un conjunto representado por una lista) puede ser necesario definir una igualdad más elaborada (por ejemplo, en el caso anterior, que no dependa del orden).

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

# Instrucciones de uso de LayoutSpace

Véase el [apartado equivalente en BSS](https://github.com/fsancho/IA/blob/master/01.%20State%20Space%20Search/README.md).
