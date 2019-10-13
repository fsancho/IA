# Planificación

Lista de ficheros asociados a Planificación:

+ `A-star.nls`, `BFS.nls`. `LayoutSpace.nls`:	Ficheros Fuente de NetLogo con algoritmos genéricos asociados a Búsqueda BFS y A*, así como de representación de Espacios de Estados. Son los mismos que hay en otras carpetas, pero se han copiado aquí por comodidad.
+ `Plan agents A-star - Blocksword.nlogo`:	Modelo de solución del problema _Blocksword_ con planificación usando A*.
+ `Plan agents A-star - Hanoi.nlogo`:	Modelo de solución del problema Hanoi_ con planificación usando A*.
+ `Plan agents A-star - Sokoban1.nlogo`:	Modelo de solución del problema 1 de _Sokoban_ con planificación usando A*.
+ `Plan agents A-star - Sokoban2.nlogo`:	Modelo de solución del problema 2 de _Sokoban_ con planificación usando A*. Demuestra las limitaciones de la librería.
+ `Plan agents BFS - Blocksword.nlogo`:	Modelo de solución del problema _Blocksword_ con planificación usando BFS.
+ `Plan agents BFS - Sokoban1.nlogo`:	Modelo de solución del problema 1 de _Sokoban_ con planificación usando BFS.
+ `Plan agents BFS - Sokoban2.nlogo`:	Modelo de solución del problema 2 de _Sokoban_ con planificación usando BFS. Demuestra las limitaciones de la librería.


# Instrucciones de uso de Planning

Esta librería proporciona una conversión relativamente general para pasar de un problema de planificación (que se proporciona usando un lenguaje similar a STRIPS) a un problema de búsqueda en Espacio de Estados. Está preparado para hacer uso de las librerías BFS y A-star que se pueden encontrar en este mismo repositorio. Debido a que trabaja con las estructuras definidas en esas librerías, aquí solo es necesario indicar por medio de variables globales específicas los componentes de nuestro problema de planificación:

+ **Universo** (conjunto de dominios que determinan los objetos del mundo)
+ **Predicados**
+ **Acciones** (formadas por un **nombre**, **precondición**, **efecto** y **dominio**)
+ **Coste de las acciones** (para A*)
+ **Estado Inicial**
+ **Estado Objetivo**

El siguiente ejemplo muestra cómo definir un problema adecuadamente:

    set Plan:Universe [["A" "B" "C" "D" "E"]]
    set Plan:Predicates ["on" "ontable" "clear" "handempty" "holding"]
    set Plan:actions [
      ["(pickup ?x)"
        ["(clear ?x)" "(ontable ?x)" "(handempty)"]
        ["-(ontable ?x)" "-(clear ?x)" "-(handempty)" "(holding ?x)"]
        [0]
        ]
      ["(putdown ?x)"
        ["(holding ?x)"]
        ["-(holding ?x)" "(clear ?x)" "(handempty)" "(ontable ?x)"]
        [0]
        ]
      ["(stack ?x ?y)"
        ["(holding ?x)" "(clear ?y)"]
        ["-(holding ?x)" "-(clear ?y)" "(clear ?x)" "(handempty)" "(on ?x ?y)"]
        [0 0]
        ]
      ["(unstack ?x ?y)"
        ["(on ?x ?y)" "(clear ?x)" "(handempty)"]
        ["(holding ?x)" "(clear ?y)" "-(clear ?x)" "-(handempty)" "-(on ?x ?y)"]
        [0 0]
        ]
    ]
    set Plan:actions-costs [["pickup" 1] ["putdown" 1] ["stack" 1] ["unstack" 1]]
    set Plan:Initial ["(clear C)" "(clear E)" "(ontable A)" "(ontable D)" "(on C B)" "(on B A)" "(on E D)" "(handempty)"]
    set Plan:Goal ["(on B A)" "(on C B)" "(on D C)" "(on E D)" "(clear E)" "(ontable A)" "(handempty)"]
  
Tras esta definición, el primer paso es preparar las acciones de Herbrand asociadas al sistema (son, simplemente, todas las acciones posibles que se pueden dar entre los objetos del universo):

      set Plan:Herbrand-actions map [a -> (list (first a) a)] Plan:build-actions

Con lo que ya podríamos llamar al proceso de búsqueda para que ejecute las acciones de forma adecuada hasta encontrar una solución al problema (A*, o BFS):

    let plan A* Plan:Initial Plan:Goal false true
    let plan BFS Plan:Initial Plan:Goal false true

En caso de usar A* es necesario dar también una función heurística que sirva de guía al algoritmo.

**Problemas conocidos**: la aproximación que se ha hecho en esta librería es muy burda, por lo que si el sistema de reglas asociadas (las acciones de Herbrand) es muy grande, la probabilidad de que no sea capaz de resolver un plan es muy elevada, por lo que solo vale para demostrar pequeños ejemplos.
