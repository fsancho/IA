# Búsquedas Informadas

Lista de ficheros asociados a Búquedas no Informadas:

+ `A-star.nls`:	Fichero Fuente de NetLogo con los algoritmos genéricos asociados a la Búsqueda Informada con A*.
+ `LayoutSpace.nls`:	Fichero Fuente de NetLogo que contiene la librería para visualizar espacios de estados calculados (para BFS y otras librerías que hacen uso de estructuras similares).
+ `A-star Problem Solver - Numerical Puzzle.nlogo`:	Modelo de solución A* del problema del _puzle numérico_.
+ `A-star Problem Solver - Sorting Lists.nlogo`:	Modelo de solución A* del problema de ordenación de listas.
+ `A-star Problem Solver - 8 puzzle.nlogo`:	Modelo de solución A* del _problema del 8 puzle_.
+ `A-star Turtles Geometric Network.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos de grafos geométricos. No hace uso de la librería A-star.
+ `A-star patches.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos sobre patches. No hace uso de la librería A-star.
+ `a-star_2009.nlogo`:	Modelo de uso del algoritmo A* en la búsqueda de caminos mínimos sobre patches. No hace uso de la librería A-star. Muestra distintas heurísticas de distancias para poder comparar resultados.

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
+ El **estado final* alcanzado, si dicho estado es un estado final válido que resuelve el problema.

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
