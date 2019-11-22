+ [Spanish](#búsqueda-no-informada)
+ [English](#uninformed-search)

--------------------------

# Búsqueda No Informada

Lista de ficheros asociados a Búsquedas no Informadas:

+ `BFS.nls`:	Fichero Fuente de NetLogo con los algoritmos genéricos asociados a la Búsqueda en Anchura.
+ `LayoutSpace.nls`:	Fichero Fuente de NetLogo que contiene la librería para visualizar espacios de estados calculados (para BFS y otras librerías que hacen uso de estructuras similares).
+ `Uninformed Explorations.nlogo`: Modelo de demostración en el que se muestran diversos recorridos no informados sobre un espacio de estados en forma de árbol.
+ `BFS agents - Basic.nlogo`:	Modelo de solución BFS del problema del _puzle numérico_.
+ `BFS agents - Basic Sorted.nlogo`:	Modelo de solución BFS del problema del _puzle numérico_ en el que se introduce la variante de poder hacer el recorrido y representación de forma ordenada (numerando los estados de forma consecutiva) y por etapas.
+ `BFS agents - Farmer.nlogo`:	Modelo de solución BFS del _problema del granjero_.
+ `BFS agents - Hanoi Towers.nlogo`:	Modelo de solución BFS del problema de las _Torres de Hanoi_.
+ `BFS agents - jugs.nlogo`:	Modelo de solución BFS del _problema de las jaras_.
+ `BFS Lists (español) - Basic.nlogo`: 	Demostración de BFS haciendo uso exclusivo de listas (sin agentes) para resolver el problema del _puzle numérico_.
+ `BFS Lists (español) - Diccionario.nlogo`:	Demostración de BFS haciendo uso exclusivo de listas (sin agentes) para resolver el problema del _diccionario_.

# Instrucciones de uso de BFS

Esta librería es realmente una extensión de la librería BSS explicada en el apartado de [State Space Search](https://github.com/fsancho/IA/tree/master/01.%20State%20Space%20Search), en consecuencia, tanto los estados (_AI:states_) como las transiciones (_AI:transitions_) siguen un comportamiento similar y se muestran aquí únicamente las diferencias.

Los estados se representan por medio de la familia de tortugas _AI:states_, que deben contener (al menos) las siguientes propiedades:

+ `content` : Almacena el contenido (valor) del estado
+ `explored?` : Indica si el estado ha sido explorado/creado o no
+ `depth` : Indica la profundidad del estado dentro respecto del estado inicial (de uso en algunas de las funcionalidades de LayoutSpace para la representación).
+ `path` : Contendrá la lista de estados por los que la búsqueda ha pasado para llegar desde el estado inicial hasta el actual.

Las transiciones, que permiten convertir estados entre sí, vienen representados por medio de la familia de links _AI:transitions_, que deben contener (el menos) las siguientes propiedades:

+ `rule` : Almacena información varia acerca de la transición. Debe tener una estructura determinada que se explica a continuación.

Al igual en la librería BSS, en este caso necesitamos que las reglas usen una forma de lista que debe tener en su primera componente una representación imprimible de la regla, ya que esta componente será usada para dar una versión comprensible por el humano de las transiciones usadas en los procesos. En los modelos de ejemplo anteriores se pueden ver usos válidos de las reglas.

La función principal de la librería **BFS** es el procedimiento `BFS`, que construye el grafo de estados que se obtiene a partir de un estado inicial dado (siguiendo los constructores en anchura definidos por el usuario) y comprueba si el estado objetivo ha sido alcanzado o no. 

Esencialmente, el algoritmo calcula recursivamente los estados sucesores de los estados actuales (_AI:states_) y los conecta por medio de links (_AI:transitions_). Este proceso se repite hasta alcanzar el estado objetivo o si se ha terminado de recorrer el espacio completo y no se ha alcanzado el objetivo. `BFS` es por tanto un report, que devolverá:

+ `False` si no ha habido éxito en la búsqueda.
+ El *estado final* alcanzado, si dicho estado es un estado final válido que resuelve el problema.

Ha de tenerse en cuenta que la búsqueda podría dar como resultado un proceso infinito, lo que en NetLogo puede provocar problemas de estabilidad en el motor de ejecución.

Los datos de entrada que espera este procedimiento son:

+ `#initial-state` : Contenido del estado inicial que dará comienzo a la construcción.
+ `#final-state` : Contenido del estado final que se busca. En caso de que el estado final venga dado por una condición de parada, pero no por un estado concreto (como en el problema de las _N reinas_), esa condición de parada vendrá dada por un report que se explicará a continuación, y en este caso podemos pasarle cualquier dato como estado final, ya que no lo considerará.
+ `#debug?` : `True / False` - Indica si se mostrará el contenido en los estados, y las reglas en las transiciones.
+ `#visible?` : Muestra/Oculta estados y transiciones en el interfaz.

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir las siguientes funciones:

+ `children-states` : Lo pueden ejecutar los estados, y devuelve una lista con información sobre los posibles sucesores del estado que lo ejecuta. En este sentido, cada estado devuelto deber ser un par [s r], donde s es el contenido del nuevo estado, y r es una regla con la estructura vista anteriormente (["rep" ...]).

+ `final-state?` : Lo pueden ejecutar los estados y devuelve si el estado actual debe ser considerado un estado final. Este procedimeinto recibe como entrada un parámetro que, por ejemplo, permita comparar el estado actual con el `#final-state` en caso de que dicho estado final sea un estado concreto. Si no fuera así, el parámetro pasado no tiene utilidad y la verificación de si es final o no solo se basará en propiedades internas al estado actual.

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

Adicionalmente, debido a que `BFS` devuelve el estado final completo, del que podemos obtener el `path` que ha permitido construirlo, la librería proporciona un report, `extract-transitions-from-path`, que al ser ejecutado por un estado devuelve, a partir de la información almacenada en el estado, la sucesión (lista) de transiciones que se han aplicado para llegar desde el estado inicial hasta él. Obsérvese que este procedimiento no necesita ningún dato de entrada, ya que lo ejecuta el propio estado y él puede acceder a toda su información de manera directa.

# Instrucciones de uso de LayoutSpace

Véase el [apartado equivalente en BSS](https://github.com/fsancho/IA/blob/master/01.%20State%20Space%20Search/README.md).

-------------------

# Uninformed Search

List of files associated with uninformed searches:

+ `BFS.nls`: NetLogo Source File with the generic algorithms associated with Breadth First Search.
+ `LayoutSpace.nls`: NetLogo Source File that contains the library to visualize calculated state spaces (for BFS and other libraries that make use of similar structures).
+ `Uninformed Explorations.nlogo`: Sample model showing several uninformed traversals over a tree-shaped state space.
+ `BFS agents - Basic.nlogo`: Model of BFS solution of the _numerical puzzle_ problem.
+ `BFS agents - Basic Sorted.nlogo`: Model of BFS solution of the _numerical puzzle_ problem where the variant of being able to make the route and representation in an orderly way (numbering the states consecutively) and by stages is introduced.
+ `BFS agents - Farmer.nlogo`: Model of BFS solution of the _farmer's problem_.
+ `BFS agents - Hanoi Towers.nlogo`: Model of BFS solution of the _Hanoi Towers_ problem.
+ `BFS agents - jugs.nlogo`: Model of BFS solution of the _jugs problem _.
+ `BFS Lists (english) - Basic.nlogo`: Sample of BFS making exclusive use of lists (without agents) to solve the problem of the _numerical puzzle_.
+ `BFS Lists (English) - Diccionario.nlogo`: Demonstration of BFS making exclusive use of lists (without agents) to solve the _dictionary problem_.

# Instructions for BFS

This library is really an extension of the BSS library explained in the [State Space Search](https://github.com/fsancho/IA/tree/master/01.%20State%20Space%20Search) section , therefore, both the states (_AI:states_) and the transitions (_AI:transitions_) follow a similar behaviour and only the differences are shown here.

The states are represented by the _AI:states_ family of turtles, which must contain (at least) the following properties:

+ `content` : Stores the content (value) of the state
+ `explored?` : Indicates whether the state has been explored/created or not
+ `depth` : Indicates the depth of the state with respect to the initial state (of use in some of the LayoutSpace functionalities for representation).
+ `path` : It will contain the list of states through which the search has gone to reach from the initial state to the current one.

Transitions, which allow converting states between each other, are represented by the _AI:transitions_ links family, which must contain (at least) the following properties:

+ `rule` : Stores various information about the transition. It must have a certain structure that is explained below.

As in the BSS library, in this case we need the rules to use a list format that must have in its first component a printable representation of the rule, since this component will be used to give a human-comprehensible version of the transitions used in the processes. In the example models above you can see valid uses of the rules.

The main function of the **BFS** library is the `BFS` procedure, which builds the state graph obtained from a given initial state (following the constructors defined by the user) and checks whether the target state has been reached or not. 

Essentially, the algorithm recursively calculates the successor states of the current states (_AI:states_) and connects them by means of links (_AI:transitions_). This process is repeated until the target state has been reached or if the entire space has been covered and the target has not been reached. `BFS` is therefore a report, which will return:

+ 'False' if the search has not been successful.
+ The *final state* reached, if that state is a valid final state that solves the problem.

Keep in mind that the search could result in an infinite process, which in NetLogo can cause stability problems in the execution engine.

The input data that this procedure expects is:

+ `#initial-state` : Contents of the initial state that will start the construction.
+ `#final-state` : Content of the final state to be searched. In case the final state is given by a stop condition, but not by a specific state (as in the problem of _N queens_), that stop condition will be given by a report that will be explained next, and in this case we can pass any data to it as a final state, since it will not consider it.
+ `#debug?` : `True / False` - Indicates if the content will be shown in the states, and the rules in the transitions.
+ `#visible?` : Shows/hides states and transitions in the interface.

For the correct functioning of this library in the main model, the following functions must be defined:

+ `children-states` : It can be executed by states, and it returns a list with information about the possible successors of the state that executes it. In this sense, each returned state must be a pair [s r], where s is the content of the new state, and r is a rule with the structure previously seen (["rep" ...]).

+ `final-state?` : It can be executed by states and returns if the current state is to be considered a final state or not. This procedure receives as input a parameter that, for example, allows comparing the current state with the `#final-state` in case this final state is a concrete state. If not, the passed parameter is useless and the verification of whether it is final or not will only be based on internal properties of the current state.

In the example models you can see some valid definitions for different problems.

Additionally, because `BFS` returns the complete final state, from which we can obtain the `path` that allowed us to build it, the library provides a report, `extract-transitions-from-path`, that when executed by a state returns, from the information stored in the state, the sequence (list) of transitions that have been applied to reach from the initial state to it. Note that this procedure does not need any input data, since it is executed by the state itself and it can access all its information directly.

# Instructions for LayoutSpace

See [equivalent section in BSS](https://github.com/fsancho/IA/blob/master/01.%20State%20Space%20Search/README.md).

