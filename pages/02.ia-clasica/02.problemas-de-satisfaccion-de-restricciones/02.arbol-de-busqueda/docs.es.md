---
title: 'Árbol de Búsqueda'
taxonomy:
    category: docs
visible: true
---

[TOC]
## El Árbol de Búsqueda
Las posibles combinaciones de la asignación de valores a las variables en un PSR genera un espacio de búsqueda al que se puede dotar de estructura para ser visto como un **árbol de búsqueda**. De esta forma, después podremos recorrerlo siguiendo la estrategia que queramos. La búsqueda mediante **backtracking**, que es la base sobre la que se soportan la mayoría de algoritmos para PSR, corresponde a la tradicional exploración en [profundidad DFS](http://www.cs.us.es/~fsancho/?e=95) en el árbol de búsqueda.

<img style="float:left;;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2016-09/psr-tree.png" /> La forma más habitual de darle estructura de árbol pasa por asumir que el orden de las variables es estático y no cambia durante la búsqueda, y entonces un nodo en el nivel \(k\) del árbol de búsqueda representará un estado donde las variables \(x_1 ,...,x_k\) están asignadas a valores concretos de sus dominios mientras que el resto de variables, \(x_{k+1} ,...,x_n\), no lo están. Podemos asignar cada nodo en el árbol de búsqueda con la tupla formada por las asignaciones llevadas a cabo hasta ese momento, donde la raíz del árbol de búsqueda representa la tupla vacía, donde ninguna variable tiene asignado valor alguno.

Los nodos en el primer nivel son \(1\)−tuplas que representan estados donde se les ha asignado un valor a la variable \(x_1\). Los nodos en el segundo nivel son \(2\)−tuplas que representan estados donde se le asignan valores a las variables \(x_1\) y \(x_2\), y así sucesivamente. Un nodo del nivel \(k\) es hijo de un nodo del nivel \(k-1\) si la tupla asociada al hijo es una extensión de la de su padre añadiendo una asignación para la variable \(x_k\). Si \(n\) es el número de variables del problema, los nodos en el nivel \(n\), que representan las hojas del árbol de búsqueda, son \(n\)−tuplas, que representan la asignación de valores para todas las variables del problema. De esta manera, si una \(n\)−tupla es consistente, entonces es solución del problema. Un nodo del árbol de búsqueda es consistente si la asignación parcial actual es consistente, o en otras palabras, si la tupla correspondiente a ese nodo es consistente.

### Backtracking Cronológico
El algoritmo de búsqueda sistemática más conocido para resolver PSR se denomina **Algoritmo de Backtracking Cronológico** (**BT**). Si asumimos un orden estático de las variables y de los valores en las variables, este algoritmo funciona de la siguiente manera:

1.  Selecciona la siguiente variable de acuerdo al orden de las variables y le asigna su próximo valor. 
2.  Esta asignación de la variable se comprueba en todas las restricciones en las que forma parte la variable actual y las anteriores:
    *   Si todas las restricciones se han satisfecho, vuelve al punto 1.
    *   Si alguna restricción no se satisface, entonces la asignación actual se deshace y se prueba con el próximo valor de la variable actual. 
3.  Si no se encuentra ningún valor consistente entonces tenemos una situación sin salida (dead-end) y el algoritmo retrocede a la variable anteriormente asignada y prueba asignándole un nuevo valor.
4.  Si asumimos que estamos buscando una sola solución, BT finaliza cuando a todas las variables se les ha asignado un valor, en cuyo caso devuelve una solución, o cuando todas las combinaciones de variable-valor se han probado sin éxito, en cuyo caso no existe solución.

<img style="float:right;margin:0 10px 10px 0;width:300px" src="http://www.cs.us.es/~fsancho/images/2016-09/backtrack.gif" /> Es fácil generalizar BT a restricciones no binarias. Cuando se prueba un valor de la variable actual, el algoritmo comprobará todas las restricciones en las que sólo forman parte la variable actual y las anteriores. Si una restricción involucra a la variable actual y al menos una variable futura, entonces esta restricción no se comprobará hasta que se hayan asignado todas las variables futuras de la restricción.

BT es un algoritmo muy simple pero muy ineficiente. El problema es que tiene una visión local del problema. Sólo comprueba restricciones que están formadas por la variable actual y las pasadas, e ignora la relación entre la variable actual y las futuras. Además, este algoritmo es ingenuo en el sentido de que no _recuerda_ las acciones previas, y como resultado, puede repetir la misma acción varias veces innecesariamente. Para ayudar a combatir este problema, se han desarrollado algunos algoritmos de búsqueda más robustos. Estos algoritmos se pueden dividir en algoritmos **look-back** y algoritmos **look-ahead**.

### Algoritmos Look-Back
Los **algoritmos look-back** tratan de explotar la información del problema para comportarse más eficientemente en las situaciones sin salida. Al igual que el backtracking cronológico, los algoritmos look-back llevan a cabo la comprobación de la **consistencia hacia atrás**, es decir, entre la variable actual y las pasadas.

<img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2016-09/180px-dead-ends-3.svg.png" /> **Backjumping (BJ)**  es parecido a BT excepto que se comporta de una manera más inteligente cuando encuentra situaciones sin salida. En vez de retroceder a la variable anteriormente instanciada, BJ salta a la variable más profunda (más cerca de la variable actual) \(x_j\) que está en conflicto con la variable actual \(x_i\) donde \(j < i\) (una variable instanciada \(x_j\) está en conflicto con una variable \(x_i\) si la instanciación de \(x_j\) evita uno de los valores en \(x_i\), debido a la restricción entre ellas). Cambiar la instanciación de \(x_j\) puede hacer posible encontrar una instanciación consistente de la variable actual.

Una variante, **conflict-directed Backjumping (CBJ)** tiene un comportamiento de salto hacia atrás más sofisticado que BJ, donde se almacena para cada variable un conjunto de conflictos mutuos que permite no repetir conflictos existentes a la vez que saltar a variables anteriores como hace BJ.

### Algoritmos look-ahead
Los algoritmos look-back tratan de reforzar el comportamiento de BT mediante un comportamiento más inteligente cuando se encuentran en situaciones sin salida. Sin embargo, todos ellos llevan a cabo la comprobación de la consistencia solamente hacia atrás, ignorando las futuras variables. Los **algoritmos Look-ahead** hacen una comprobación hacia adelante en cada etapa de la búsqueda, es decir, llevan a cabo las comprobaciones para obtener las inconsistencias de las variables futuras involucradas además de las variables actual y pasadas. De esa manera, las situaciones sin salida se pueden identificar antes y los valores inconsistentes se pueden descubrir y podar para las variables futuras.

**Forward checking (FC)** es uno de los algoritmos look-ahead más comunes. En cada etapa de la búsqueda, FC comprueba hacia adelante la asignación actual con todos los valores de las futuras variables que están restringidas con la variable actual. Los valores de las futuras variables que son inconsistentes con la asignación actual son temporalmente eliminados de sus dominios (solo para la rama actual de búsqueda). Si el dominio de una variable futura se queda vacío, la instanciación de la variable actual se deshace y se prueba con un nuevo valor. Si ningún valor es consistente, entonces se lleva a cabo BT estándar. FC garantiza que, en cada etapa, la solución parcial actual es consistente con cada valor de cada variable futura. Además cuando se asigna un valor a una variable, solamente se comprueba hacia adelante con las futuras variables con las que están involucradas. Así mediante la comprobación hacia adelante, FC puede identificar antes las situaciones sin salida y podar el espacio de búsqueda. Se puede ver como aplicar un simple paso de arco-consistencia sobre cada restricción que involucra la variable actual con una variable futura después de cada asignación de variable.

El pseudo código de Forward Checking podría ser el siguiente:

1.  Seleccionar \(x_i\).
2.  Instanciar \((x_i , a_i) : a_i \in D_i\).
3.  Razonar hacia adelante (check-forward): Eliminar de los dominios de las variables aún no instanciadas con un valor aquellos valores inconsistentes con respecto a la instanciación \((x_i, a_i)\), de acuerdo al conjunto de restricciones.
4.  Si quedan valores posibles en los dominios de todas las variables por instanciar, entonces:
    *   Si \(i < n\), incrementar \(i\), e ir al paso 1.
    *   Si \(i = n\), parar devolviendo la solución.
5.  Si existe una variable por instanciar sin valores posibles en su dominio entonces retractar los efectos de la asignación \((x_i, a_i)\):
    *   Si quedan valores por intentar en \(D_i\), ir al paso 2.
    *   Si no quedan valores:
        *   Si \(i > 1\), decrementar \(i\) y volver al paso 2.
        *   Si \(i = 1\), salir sin solución.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/australia-fc4.gif" width=600px>

Forward checking se ha combinado con algoritmos look-back para generar algoritmos híbridos. Por ejemplo, **forward checking con conflict-directed backjumping (FC-CBJ)** es un algoritmo híbrido que combina el movimiento hacia adelante de FC con el movimiento hacia atrás de CBJ, y de esa manera tiene las ventajas de ambos algoritmos.
