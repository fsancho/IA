+ [English](#adversarial-search)
+ [Spanish](#Búsqueda-con-adversario)

---------------------

# Adversarial Search

In this folder we can find several models related to searches in situations with adversaries (also usable in situations with uncertainty):

+ `MCTS Nim.nlogo` : Implementation of a Nim player using MCTS.
+ `MCTS OXO.nlogo` : Implementation of a Tic Tac toe player using MCTS.
+ `MCTS.nls` : Library that includes the procedures to implement players with MCTS.
+ `Minimax Test.nlogo` : Minimax demo on a complete random graph.
+ `Minimax.nls` : Library that includes the procedures to apply Minimax on a complete game tree.

## Minimax

A `minimax.nls` library that implements the procedures associated to the Minimax algorithm for the case in which we have the complete game tree (it is easy to extend it to consider a heuristic evaluation in non-terminal nodes). 

Now, there are two implementations in the same library: 
+ `minimax`: for the complete propagation from the leaves to the root (no pruning), 
+ `alphabeta`: the usual alpha-beta pruning algorithm.

In this time, it is not implemented on dynamical building of game states.


## MCTS

**Use:** Apply **Monte Carlo Tree Search** to solve search problems with adversary. For this purpose the `MCTS.nls` library is provided, and some examples of how it can be used to solve conventional 2 players games (it is assumed that one of them would be the human player, the machine player would make use of MCTS to decide the ideal move).

The library built to run the MCTS algorithm makes use of the following structures:

**state:** any structure that responds to the following interface:
+ `get-content state` : reads the content of `state` (the real data of the game)
+ `get-playerJustMoved state` : Player (1 or 2) who generated this state
+ `create-state content player` : returns a `state` with that information
	
**rules:** structure that allows to execute actions on states that responds to the following interface:
+ `apply rule state` : returns a new state, the result of applying `rule` to `state`.
+ `get-rules state` : returns a list of applicable rules to `state`
+ `get-result state player` : returns the result of the game in `state` according to the point of view of `player` 
	
Together with these structures, the algorithm needs some additional structures for the construction of the search tree by means of the algorithm. The user does not have to make any use of these structures:

**MCTSnode:** agent that maintains the node structure of the MCTS game tree for the execution of the algorithm. It has the following structure:
+ `state` : the state that stores the node (the previous structure)
+ `wins` : cumulative weight of winnings reached in the tree from that node
+ `visits` : number of plays in the tree that have used that node
+ `untriedRules` : rules applicable to `state` that have not yet been used to generate children
	
And it responds to the following interface:
+ `create-node state` : returns an `MCTSnode` as root with `state`with properties `wins=0`, `visits=0`, `unTriedRules=get-rules state`.
+ `UCTSelectChild` : returns the child of the node with the best **UCT**.
+ `AddChild r` : creates a new child node by applying the `r` rule to the current node, and returns it.
+ `Update result` : update node values considering a new `result` win.
+ `parent` : returns the parent of the current node

**MCTSrule:** links that connect the nodes of the game tree, MCTSnode. It has the following structure:
+ `rule` : stores the rule to be applied in this transition.

The main function provided by this library is **UCT**:

+ `UCT root-state iter`: executes a UCT search during `iter` iterations starting with the `root-state` node. Returns the best movement found. The results of the moves must be in the range $[0.0, 1.0]$.

Broadly speaking, the UCT algorithm consists of the following steps:

UCT: The main procedure. It consists of the repetition of N times of:

From the root node:
  1. Selection of node with possibility of expansion.
  2. Expansion of the selected node.
  3. Simulation from the expanded node.
  Return the best child of the root node according to the results of the simulations.
  4. Propagation of simulation results.

--------------------------------

# Búsqueda con Adversario

En esta carpeta podemos encontrar varios modelos relacionados con las búsquedas en situaciones con adversarios (también usable en situaciones con incertidumbre):

+ `MCTS Nim.nlogo` : Implementación de un jugador de Nim usando MCTS.
+ `MCTS OXO.nlogo` : Implementación de un jugador de 3 en raya usando MCTS.
+ `MCTS.nls` :  Librería que incluye los procedimientos para implementar jugadores con MCTS.
+ `Minimax Test.nlogo` : Test Minimax sobre un grafo completo al azar.
+ `Minimax.nls` : Librería que incluye los procedimiento para aplicar Minimax sobre un árbol completo de juego.

## Minimax

Una librería `minimax.nls` que implementa los procedimeintos asociados al algoritmo Minimax para el caso en que tenemos el árbol de jugadas completo (es fácil ampliarlo para que considere una evaluación heurística en nodos no terminales). Por ahora no tiene implementada la **Poda Alfa-Beta**.


## MCTS

**Uso:** Aplicar **Monte Carlo Tree Search** para resolver problemas de búsqueda con adversario. Para ello se proporciona la librería `MCTS.nls`, y algunos ejemplos de cómo se puede usar para resolver juegos convencionales de 2 usuarios (se supone que uno de ellos sería el jugador humano,  el jugador máquina haría uso de MCTS para decidir la jugada idónea.

La librería montada para ejecuar el algoritmo MCTS hace uso de las sigiuentes estructuras:

**state:** cualquier estructura que responde a la siguiente interfaz:
+ `get-content state`           : lee el contenido de `state` (el dato real del juego)
+ `get-playerJustMoved state`   : Jugador (1 o 2) que ha generado este estado
+ `create-state content player` : devuelve un `state` con esa información
	
**rules:** estructura que permite ejecutar acciones sobre estados que responde a la siguiente interfaz:
+ `apply rule state`        : devuelve un nuevo estado, el resultado de aplicar `rule` a `state`
+ `get-rules state`         : devuelve una lista de reglas aplicables a `state`
+ `get-result state player` : devuelve el resultado del juego en `state` según el punto de vista de `player` 
	
Junto a estas estructuras, el algoritmo necesita algunas estructuras adicionales para la construcción del árbol de búsqueda por medio del algoritmo. El usuario no ha de hacer ningún uso de estas estructuras:

**MCTSnode:** agente que mantiene la estructura de nodos del árbol de juego MCTS para la ejecución del algoritmo. Tiene la siguiente estructura:
+ `state`        : el estado que almacena el nodo (la estructura anterior)
+ `wins`         : peso acumulado de ganancias alcanzadas en el árbol desde ese nodo
+ `visits`       : número de jugadas en el árbol que han usado ese nodo
+ `untriedRules` : reglas aplicables a `state` que no han sido usadas todavía para generar hijos
	
Y responde a la siguiente interfaz:
+ `create-node state` : devuelve un `MCTSnode` como root con `state`con propiedades `wins=0`, `visits=0`, `unTriedRules=get-rules state`.
+ `UCTSelectChild`   : devuelve el hijo del nodo con mejor **UCT**.
+ `AddChild r`       : crea un nuevo nodo hijo aplicando la regla `r` al nodo actual, y lo devuelve
+ `Update result`    : actualiza los valores del nodo considerando una ganancia nueva de `result`
+ `parent`           : devuelve el padre del nodo actual

**MCTSrule:** enlaces que conectan entre sí los nodos del árbol de juego, MCTSnode. Tiene la estructura siguiente:
+ `rule`    : almacena la regla que debe ser aplicada en estra transición

La función principal que proporciona esta librería es **UCT**:

+ `UCT root-state iter`: ejecuta una búsqueda UCT durante `iter` iteraciones comenzando por el nodo `root-state`. Devuelve el mejor movimiento encontrado. Los resultados de las jugadas debe estar en el rango $[0.0, 1.0]$.

A grandes rasgos, el algoritmo UCT consta de los siguientes pasos:

UCT: El procedimiento principal. Consta de la repetición de N veces de:

A partir del nodo raíz:
  1. Selección de nodo con posibilidad de expansión
  2. Expansión del nodo seleccionado
  3. Simulación a partir del nodo expandido
  Devolver el mejor hijo del nodo raíz según los resultados de las simulaciones.
  4. Propagación de los resultados de la simulación
