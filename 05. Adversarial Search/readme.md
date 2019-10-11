# MCTS
**Uso:** Aplicar **Monte Carlo Tree Search** para resolver problemas de búsqueda con adversario.

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
