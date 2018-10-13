---
title: 'Consistencia en un PSR'
taxonomy:
    category: docs
visible: true
---

[TOC]
## Consistencia en un PSR
Al igual que ocurre con los algoritmos de búsqueda generales, una forma común de crear algoritmos de búsqueda sistemática para la resolución de PSR tienen como base la búsqueda basada en **backtracking**. Sin embargo, esta búsqueda sufre con frecuencia una explosión combinatoria en el espacio de búsqueda, y por lo tanto no es por sí solo un método suficientemente eficiente para resolver este tipo de problemas.

Una de las principales dificultades con las que nos encontramos en los algoritmos de búsqueda es la aparición de inconsistencias locales que van apareciendo continuamente. Las inconsistencias locales son valores individuales, o una combinación de valores de las variables, que no pueden participar en la solución porque no satisfacen alguna propiedad de consistencia.

Las restricciones explícitas en un PSR, que generalmente coinciden con las que se conocen explícitamente del problema a resolver, se generan cuando se combinan restricciones implícitas que pueden causar inconsistencias locales. Si un algoritmo de búsqueda no almacena las restricciones implícitas, repetidamente redescubrirá la inconsistencia local causada por ellas y malgastará esfuerzo de búsqueda tratando repetidamente de intentar instanciaciones que ya han sido probadas y que no llevan a una solución del problema.

!! **Ejemplo.** Tenemos un problema con tres variables \(x,y,z\), con los dominios respectivos \(\{0,1\}\), \(\{2,3\}\) y \(\{1,2\}\). Hay dos restricciones en el problema: \(y < z\) y \(x \neq y\). Si asumimos que la búsqueda mediante backtracking trata de instanciar las variables en el orden \(x,y,z\) entonces probará todas las posibles \(2^3\) combinaciones de valores para las variables antes de descubrir que no existe solución alguna. Si miramos la restricción entre \(y\) y \(z\) podremos ver que no hay ninguna combinación de valores para las dos variables que satisfagan la restricción. Si el algoritmo pudiera identificar esta inconsistencia local antes, se evitaría un gran esfuerzo de búsqueda.

En la literatura se han propuesto varias técnicas de consistencia local como formas de mejorar la eficiencia de los algoritmos de búsqueda. Tales técnicas borran valores inconsistentes de las variables o inducen restricciones implícitas que nos ayudan a podar el espacio de búsqueda. Estas técnicas de consistencia local se usan como etapas de preproceso donde se detectan y eliminan las inconsistencias locales antes de empezar la búsqueda o durante la misma con el fin de reducir el árbol de búsqueda.

> **Definición.** Un problema es **\((i,j)\)-consistente** si cualquier solución a un subproblema con \(i\) variables puede ser extendido a una solución incluyendo \(j\) variables adicionales.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/261px-query-decomposition-1.svg.png">
Observa que podemos crear **el grafo de restricciones** (realmente sería un hipergrafo), en el que los nodos son las variables del problema, y las aristas (hiperaristas) serían las restricciones impuestas sobre conjuntos de nodos/variables. Si solo tenemos restricciones binarias, estamos ante el caso de un grafo, si aparecen restricciones unarias, el grafo tendría loops, y si hay restricciones \(n\)-arias (con \(n>2\)) entonces estaríamos usando un hipergrafo.

La mayoría de las formas de consistencia se pueden ver como especificaciones de la \((i,j)\)-consistencia. Cuando \(i\) es \(k − 1\) y \(j\) es \(1\), obtenemos la **\(k\)-consistencia**.

Un problema es **fuertemente \(k\)-consistente** si es \(i\)-consistente para todo \(i \leq k\). Un problema fuertemente \(k\)-consistente con \(k\) variables se llama **globalmente consistente**. La complejidad espacial y temporal en el peor caso de forzar la \(k\)-consistencia es exponencial con \(k\). Además, cuando \(k\geq 2\), forzar la \(k\)-consistencia cambia la estructura del grafo de restricciones añadiendo nuevas restricciones no unarias. Esto hace que la \(k\)-consistencia sea impracticable cuando \(k\) es grande.

En la literatura puede encontrarse un análisis más detallado acerca de consistencias en PSR. Vamos a ver aquí solo algunos casos particulares que son de uso común en algoritmos básicos:

### Consistencia de Nodo (1-consistencia)

La consistencia local más simple de todas es la **consistencia de nodo** o **nodo-consistencia**. Forzar este nivel de consistencia nos asegura que todos los valores en el dominio de una variable satisfacen todas las restricciones unarias sobre esa variable.

> **Definición.** Un problema es **nodo-consistente** si y sólo si todas sus variables son nodo-consistentes:  
\[\forall x_i \in X,\ \forall C_i,\ \exists a \in D_i \ :\ a\ satisface\ C_i\]

!! **Ejemplo.** Consideremos una variable \(x\) en un problema con dominio \([2,15]\) y la restricción unaria \(x \leq 7\). La consistencia de nodo eliminará el intervalo \([8,15]\) del dominio de \(x\).

### Consistencia de Arco (2\-consistencia)

> **Definición.** Un problema binario es **arco-consistente** si para cualquier par de variables \(x_i\) y \(x_j\), para cada valor \(a\) en \(D_i\) hay al menos un valor \(b\) en \(D_j\) tal que las asignaciones \((x_i ,a)\) y \((x_j ,b)\) satisfacen la restricción entre \(x_i\) y \(x_j\).
<img src="http://www.cs.us.es/~fsancho/images/2016-09/constnetac.gif">
Cualquier valor en el dominio \(D_i\) de la variable \(x_i\) que no es arco-consistente puede ser eliminado de \(D_i\) ya que no puede formar parte de ninguna solución. El dominio de una variable es arco-consistente si todos sus valores son arco-consistentes.

!! **Ejemplo.** La restricción \(C_{ij} = x_i < x_j\), donde \(x_i\in [3,6]\) y \(x_j\in [8,10]\) es consistente, ya que para cada valor \(a \in [3,6]\) hay al menos un valor \(b \in [8,10]\) de manera que se satisface la restricción \(C_{ij}\). Sin embargo, si la restricción fuese \(C_{ij} = x_i > x_j\) no sería arco-consistente.

> Un **problema es arco-consistente** si y sólo si todos sus arcos son arco-consistentes:  
\[\forall C_{ij} \in C,\ \forall a \in D_i,\ \exists b \in D_j \ : \ b \mbox{ es un  
soporte para } a \mbox{ en } C_{ij}\]

### Consistencia de caminos (3-consistencia)

La consistencia de caminos es un nivel más alto de consistencia local que la arco-consistencia. La consistencia de caminos requiere, para cada par de valores \(a\) y \(b\) de dos variables \(x_i\) y \(x_j\), que la asignación de \(((x_i,a), (x_j,b))\) satisfaga la restricción entre \(x_i\) y \(x_j\), y que además exista un valor para cada variable a lo largo del camino entre \(x_i\) y \(x_j\) de forma que todas las restricciones a lo largo del camino se satisfagan.

Un problema satisface la consistencia de caminos si y sólo si todo par de variables \((x_i ,x_j) \) verifica la consistencia de caminos. Cuando un problema satisface la consistencia de caminos y además es nodo-consistente y arco-consistente se dice que satisface fuertemente la consistencia de caminos.

## Consistencia Global

A veces es deseable una noción más fuerte que la consistencia local. Decimos que un etiquetado, construido mediante un algoritmo de consistencia, es globalmente consistente si contiene solamente aquellas combinaciones de valores que forman parte de, al menos, una solución.

**Definición.** Dado un PSR \((X,D,C)\), se dice que es **globalmente consistente** si y sólo si para cada variable  \(x_i \) y cada valor posible para ella, \(a \in D_i\), la asignación \((x_i, a)\) forma parte de una solución del PSR.

En determinados casos (por ejemplo, si el grafo de restricciones es un árbol), niveles bajos de consistencia son equivalentes a la consistencia global, lo que permite generar algoritmos que en tiempo polinomial pueden dar el conjunto de soluciones sin hacer backtracking.