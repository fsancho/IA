# Construcción de Espacios de Estados

Conjunto de ficheros asociados a esta carpeta:

+ `BSS.nls`: **Fichero Fuente de NetLogo** (**NetLogo Source**) que contiene la librería para construir el espacio de estados asociado a un problema (Build Search Space) a partir de un estado inicial y un constructor básico.
+ `LayoutSpace.nls`: **Fichero Fuente de NetLogo** que contiene la librería para visualizar espacios de estados calculados a partir de la librería BSS (y otras librerías que hacen uso de estructuras similares).
+ `Build State Space - Basic.nlogo`: Definiciones para el problema del *puzle numérico*.
+ `Build State Space - Jugs.nlogo`: Definiciones para el *problema de las jarras*.
+ `Build State Space - Farmer.nlogo`: Definiciones para el *problema del granjero*.
+ `Build State Space - Tic Tac Toe.nlogo`: Definiciones para el problema del *3 en raya*.
+ `Build State Space - Towers of Hanoi.nlogo`: Definiciones para el problema de las *Torres de Hanoi*.
+ `Build State Space Repetitions - Nim.nlogo`: Definiciones para el juego del *Nim* (repitiendo nodos).

## Instrucciones de uso de BSS:

Los **estados** se representan por medio de la familia de tortugas _AI:states_, que deben contener (al menos) las siguientes propiedades:

+ `content`   : Almacena el contenido (valor) del estado
+ `explored?` : Indica si el estado ha sido explorado/creado o no
+ `depth`     : Indica la profundidad del estado respecto del estado inicial (de uso en algunas de las funcionalidades de LayoutSpace para la representación).

Las **transiciones**, que permiten convertir estados entre sí, vienen representados por medio de la familia de links  _AI:transitions_, que deben contener (al menos) las siguientes propiedades:

+ `rule`   : Almacena información varia acerca de la transición. Debe tener una estructura determinada que explicamos a continuación.

En esta solución necesitamos que las reglas usen una forma de lista que debe tener en su primera componente una representación imprimible de la regla, ya que esta componente será usada para dar una versión comprensible por el humano de las transiciones usadas en los procesos. En los modelos de ejemplo anteriores se pueden ver usos válidos de las reglas.

La función principal de la librería **BSS** es el procedimiento `BSS`, que construye el grafo de estados que se obtiene a partir de un estado inicial dado (siguiendo los constructores definidos por el usuario). Esencialmente, el algoritmo calcula recursivamente los estados sucesores de los estados actuales (_AI:states_) y los conecta por medio de links (_AI:transitions_). Este proceso se repite un número máximo de veces.

Los datos de entrada que espera este procedimiento son:

+ `#initial-state` : Contenido del **estado inicial** que dará comienzo a la construcción.
+ `#type`          : Tipo de **grafo/estructura** que tendrá el espacio construido:
  + `0` - **Árbol, sin estados repetidos** (si un estado se repite, se ignora).
  + `1` - **Árbol, con estados repetidos** (si un estado se repite, se crea una copia).
  + `2` - **Grafo** (si un estado se va a repetir, se crea un link con el ya existente).
+ `#max-depth`     : **Máxima profundidad** permitida. Número máximo de transiciones aplicadas para calcular los nuevos estados.
+ `#debug?`        : `True / False` - Indica si se mostrará el contenido en los estados, y las reglas en las transiciones.
+ `#visible?`     : Muestra/Oculta estados y transiciones en el interfaz.

Para el correcto funcionamiento de esta librería en el modelo principal se debe definir un _report_:
   
+ `children-states` : Lo pueden ejecutar los estados, y devuelve una lista con información sobre los posibles sucesores del estado que lo ejecuta. En este sentido, cada estado devuelto deber ser un par `[s r]`, donde `s` es el contenido del nuevo estado, y `r` es una regla con la estructura vista anteriormente (`["rep" ...]`).
  
En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

## Ejemplo

Vamos a definir la estructura de datos y reports necesarios para construir (una parte de) el espacio de estados del siguiente juego: 
> Dado dos números, S y G, encontrar una forma de transofrmar S en G por medio de las operaciones permitidas:
>   sumar 3, multiplicar por 7, o restar 2.

Por ejemplo, para llegar del 5 al 20, una solución posible sería la que pasa por los siguientes estados, aplicando las reglas anteriores: 5 -(*3)-> 15 -(+7)-> 22 -(-2)-> 20.

El contenido de los estados será simplemente un valor numérico.

Las reglas aplicables las construiremos directamente por medio de la construcción de listas y reports anónimos:

[ ["*3" regla*3] ["+7" regla+7] ["-2" regla-2] ]

    to-report reglas
      report (list
               (list "*3" ([ x -> x * 3 ]))
               (list "+7" ([ x -> x + 7 ]))
               (list "-2" ([ x -> x - 2 ])))
    end

Una vez definidas las reglas, podemos definir el procedimiento que calcula los estados siguientes por medio del siguiente report:

    to-report AI:children-states
      let res []
      foreach reglas [
        regla -> 
        let app last regla
        let r (run-result app content)
        if r > 0 [set res lput (list r regla) res]
      ]
      report res
    end
    
De forma más general, podemos dar la siguiente definición equivalente, que hace uso de un report auxiliar que indica cuándo es válido un estado, y que además hace uso de una aproximación funcional:

    to-report valid? [x]
      report (x > 0)
    end

    to-report AI:children-states
      report filter [ ?1 -> valid? (first ?1) ]
                    (map [ ?1 -> (list (run-result (last ?1) content) ?1) ]  reglas)
    end

Ahora, para que construya el árbol simple (sin repeticiones) que se consigue a partir de S, con 3 niveles de profundidad, mostrando los estados en nodos y reglas en transiciones, y mostrando la información en el mundo (observa que como estamos construyendo el espacio de estados, no realizando la búsqueda, no es necesario conocer el valor buscado final, G):

    BSS S 0 3 True True

## Instrucciones de uso de LayoutSpace

Esta librería no se usa únicamente en este tipo de ejercicios, sino que se puede utilizar para la representación de cualquier espacio de estados (por lo que será también útil en las búsquedas no informadas, informadas, locales y Minimax). El objetivo de esta librería de representación no es proporcionar un producto final, sino dar las herramientas básicas para poder centrarse en la generación de los espacios de estados, y no en su representación, por lo que podría ser necesario adaptarla a contextos con necesidades más específicas.

Proporciona un procedimiento principal, `layout-space`, que recibe como dato de entrada el tipo de representación y representa el espacio de estados según el tipo seleccionado:

+ `*` : Representación **orgánica** por algoritmo de fuerzas.
+ `o` : Representación **radial** a partir del estado inicial (que supone que es `AI:state 0`).
+ `↓` : Representación como árbol vertical.
+ `→` : Representación como árbol horizontal.

En el caso de los árboles, el algoritmo intenta ordenar adecuadamente los sucesores con el fin de conseguir que el árbol sea equilibrado.

Además, la librería proporciona un procedimiento, `style`, que da un aspecto uniforme al grafo de espacios de estados: fondo blanco, estados circulares azules con etiquetas negras, transiciones con etiquetas verdes.
