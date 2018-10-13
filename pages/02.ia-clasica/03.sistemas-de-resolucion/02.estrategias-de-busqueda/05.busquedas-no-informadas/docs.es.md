---
title: 'Búsquedas No Informadas'
taxonomy:
    category: docs
visible: true
---

[TOC]  
<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/47b17b64-15d3-11e2-bb76-001e670c2818.jpg"/>Los algoritmos de **búsqueda ciega** o **no informada** no dependen de información propia del problema a la hora de resolverlo, sino que proporcionan métodos generales para recorrer los árboles de búsqueda asociados a la representación del problema, por lo que se pueden aplicar en cualquier circunstancia. Se basan en la estructura del espacio de estados y determinan estrategias sistemáticas para su exploración, es decir, que siguen una estrategia fija a la hora de visitar los nodos que representan los estados del problema. Se trata también de algoritmos exhaustivos, de manera que, en el peor de los casos, pueden acabar recorriendo todos los nodos del problema para hallar la solución.

Existen, básicamente, dos estrategias de recorrido de un espacio de búsqueda, en **anchura** y en **profundidad**. Los algoritmos que veremos a continuación se basan en una de las dos (o incluso en las dos). El problema principal que tienen es que, al ser exhaustivos y sistemáticos su coste puede ser prohibitivo para la mayoría de los problemas reales, por lo tanto solo serán aplicables en problemas pequeños, pero presentan la ventaja de que no es necesario ningún conocimiento adicional sobre el problema, por lo que siempre son aplicables.

Vamos a repasar únicamente algoritmos de búsqueda ciega para árboles, que serán variantes del algoritmo de búsqueda general (para árboles) que se describe a continuación:

### Búsqueda genérica (o sin estrategia)

<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/e42ae8e0-1529-11e2-bb76-001e670c2818.png"/>Los espacios de búsqueda, en general, pueden ser representados como árboles o como grafos. La diferencia principal entre los algoritmos que encontraremos para unos u otros radica, fundamentalmente, en que los algoritmos para árboles no necesitan mantener una lista de los nodos por los que ya ha pasado, ya que no pueden volver a visitarse nodos en el recorrido de búsqueda por el árbol. Sin embargo, si trabajamos con grafos podemos encontrar caminos que repitan nodos, y en este caso necesitaremos de una memoria de almacenamiento que nos indique si ya hemos visitado ese nodo en una etapa anterior o no.

Durante una búsqueda, la **frontera** es la colección de nodos que esperan ser visitados (habitualmente almacenados en forma de pila, cola, lista...). Los nodos de la frontera se dicen **abiertos**. Cuando un nodo se elimina de la frontera, se etiqueta como **cerrado**. 

En el algoritmo de búsqueda genérica no se proporciona ninguna estrategia para el recorrido de los nodos, simplemente es un patrón que indica que "existe una forma" (no determinada) de construir los caminos que empiezan en el nodo raíz y acaban en las hojas. Sobre este algoritmo general, cada uno de los que veremos a continuación añade únicamente una estrategia específica para decidir cómo se construyen dichos caminos. Dejaremos los algoritmos para grafos para cuando introduzcamos heurísticas, ya que los que veremos aquí sacan provecho del hecho de que trabajamos con árboles y se comportan muy mal (hasta el punto de poder ser inútiles) cuando los aplicamos sobre grafos. 

### Búsqueda en anchura

La idea principal de la **Búsqueda en Anchura** (**BFS**) consiste en visitar todos los nodos que hay a profundidad \(i\) antes de pasar a visitar aquellos que hay a profundidad \(i+1\). Es decir, tras visitar un nodo, pasamos a visitar a sus hermanos antes que a sus hijos. Si usamos estructuras de programación habituales, una posible implementación para BFS se haría almacenando el conjunto de nodos abiertos como una cola, a la que se accede por un procedimiento FIFO (el primero que entra es el primero que sale). Cuando hagamos uso de estructuras de programación basadas en agentes veremos que la implementación de este algoritmo es ligeramente distinta, y mantienen el almacenamiento haciendo uso de la propia estructura que existe entre los agentes involucrados.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/41b0b292-152a-11e2-bb76-001e670c2818.png"/>

Este algoritmo es **completo**, es decir, si existe solución, este algoritmo la encuentra. Más aún, es **óptimo**, en el sentido de que si hay solución, encuentra una de las soluciones a distancia mínima de la raíz.

Respecto al tratamiento de nodos repetidos, se comporta bien. Si el nodo generado actual ya apareció en niveles superiores (más cerca de la raíz), el coste actual será peor ya que su camino desde la raíz es más largo, y si está al mismo nivel, su coste será el mismo. Esto quiere decir que si nos encontramos un nodo que ya ha sido repetido, su coste será peor o igual que algún nodo anterior visitado o no, de manera que lo podremos descartar, porque o lo hemos expandido ya o lo haremos próximamente con mejor coste.

Éstas son las buenas noticias... la mala noticia es que en términos de **tiempo**, lo que tarda es:

$1+b+b^2 + ... + b^d = \sum_{i=0}^d b^i =\frac{b^{d+1}-1}{b-1}= O(b^d)$

 En términos de **espacio**, BFS almacena una lista con todos los nodos en todas las profundidades, y a distancia \(d\) esta lista es de longitud \(b^d\). Lo que supone una cantidad exponencial de nodos.

Por tanto, tanto en espacio como en tiempo su complejidad es exponencial en \(d\).

### Búsqueda en Profundidad

Al igual que en el caso de la búsqueda en anchura, la **búsqueda en profundidad** (**DFS**) también puede ser vista como un proceso por niveles, pero con la diferencia de que, tras visitar un nodo, se visitan sus hijos antes que sus hermanos, por lo que el algoritmo tiende a bajar por las ramas del árbol hacia las hojas antes de visitar cada una de las ramas posibles. De nuevo, si hacemos uso de estructuras clásicas de programación, DFS se puede implementar por medio de una pila accediendo a sus elementos por un proceso de LIFO (último en entrar, primero en salir).

<img src="http://www.cs.us.es/~fsancho/images/2015-07/424b1e90-152a-11e2-bb76-001e670c2818.png"/>

Como en el caso del BFS, la complejidad en tiempo del DFS es del orden de \(b^d\). Es exponencial ya que en el peor caso DFS tiene que visitar todos los nodos. Sin embargo, la complejidad en espacio es lineal en \(d\), donde \(d\) es la longitud del camino más largo posible, ya que el máximo número de nodos que se almacenan es del orden \(bd\).

DFS no es ni óptimo ni completo. No es óptimo porque si existe más de una solución, podría encontrar la primera que estuviese a un nivel de profundidad mayor, y para ver que no es completo es necesario irse a ejemplos en los que el espacio de búsqueda fuese infinito: _supongamos un robot que puede moverse a izquierda o derecha en cada paso y ha de encontrar un objeto; la búsqueda en profundidad le obligaría a moverse indefinidamente en una sola dirección, cuando el objeto podría estar en la dirección contraria (e incluso a un solo paso del origen)_. Para evitar este problema es común trabajar con una pequeña variante de este algoritmo que se llama de **Profundidad limitada**, que impone un límite máximo al nivel alcanzado.

    Procedimiento: Busqueda en profundidad limitada (limite: entero)
    Est_abiertos.insertar(Estado inicial)
    Actual ← Est_abiertos.primero()
    mientras no es_final?(Actual) y no Est_abiertos.vacia?() hacer
      Est_abiertos.borrar_primero()
      Est_cerrados.insertar(Actual)
      si profundidad(Actual) ≤ limite entonces
        Hijos ← generar_sucesores (Actual)
        Hijos ← tratar_repetidos (Hijos, Est_cerrados, Est_abiertos)
        Est_abiertos.insertar(Hijos)
      fin
      Actual ← Est_abiertos.primero()
    fin

Para el tratamiento de posibles nodos repetidos la idea consiste en lo siguiente: si el nodo generado actual está repetido en niveles superiores (más cerca de la raíz), su coste será peor ya que su camino desde la raíz es más largo, si está al mismo nivel, su coste será el mismo. En estos dos casos podemos olvidarnos de este nodo.En el caso de que el repetido corresponda a un nodo de profundidad superior, significa que hemos llegado al mismo estado por un camino más corto, de manera que deberemos mantenerlo y continuar su exploración, ya que nos permitirá llegar a mayor profundidad que antes.

La versión del mismo algoritmo usando recursión sería:

    Función: Busqueda en profundidad limitada recursiva (actual:nodo, limite: entero)
    si profundidad(Actual) ≤ limite entonces
      para todo nodo ∈ generar_sucesores (Actual) hacer
        si es_final?(nodo) entonces
          retorna (nodo)
        sino
          resultado ← Busqueda en profundidad limitada recursiva(nodo,limite)
          si es_final?(resultado) entonces
            retorna (resultado)
          fin
        fin
      fin
    sino
      retorna (∅)
    fin 

Las implementaciones recursivas de los algoritmos permiten por lo general un gran ahorro de espacio. En este caso, la búsqueda en profundidad se puede realizar recursivamente de manera natural. La recursividad permite que las alternativas queden almacenadas en la pila de ejecución como puntos de continuación del algoritmo sin necesidad de almacenar ninguna información. Así, el ahorro de espacio es proporcional al factor de ramificación que en la práctica en problemas difíciles no es despreciable. Lo único que perdemos es la capacidad de buscar repetidos en los nodos pendientes que tenemos en el camino recorrido, pero habitualmente la limitación de memoria es una restricción bastante fuerte que impide resolver problemas con longitudes de camino muy largas.

En el caso de la búsqueda en profundidad, el tratamiento de nodos repetidos no es crucial ya que al tener un límite en profundidad los ciclos no llevan a caminos infinitos. No obstante, en este caso se pueden comprobar los nodos en el camino actual, ya que está completo en la estructura de nodos abiertos. Además, no tratando repetidos mantenemos el coste espacial lineal, lo cual es una gran ventaja. El evitar tener que tratar repetidos y tener un coste espacial lineal supone una característica diferenciadora de hace muy ventajosa a la búsqueda en profundidad, y permite obtener soluciones que se encuentren a gran profundidad.

### Profundidad iterada

El algoritmo de **Profundidad Iterada** (**ID**) mezcla los requerimientos espaciales del DFS (lineal en \(d\)) y las propiedades óptimas del BFS (completo y asintóticamente óptimo). La idea principal de este algoritmo es hacer una búsqueda DFS repetidamente sobre subárboles de profundidad \(0\), después de profundidad \(1\), después \(2\), etc... hasta que se alcanza el objetivo.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/ce895e80-152a-11e2-bb76-001e670c2818.png">

El algoritmo ID es **óptimo** y **completo**, garantiza encontrar una solución, en caso de que exista y, si existen varias soluciones, devuelve una de las que tengan distincia mínima a la raíz.

    Procedimiento: Busqueda en profundidad iterativa (limite: entero)
    prof ← 1
    Actual ← Estado inicial
    mientras no es_final?(Actual) y prof<limite
      Est_abiertos.inicializar()
      Est_abiertos.insertar(Estado inicial)
      Actual ← Est_abiertos.primero()
      mientras no es_final?(Actual) y no Est_abiertos.vacia?() hacer
        Est_abiertos.borrar_primero()
        Est_cerrados.insertar(Actual)
        si profundidad(Actual) ≤ prof entonces
          Hijos ← generar_sucesores (Actual)
          Hijos ← tratar_repetidos (Hijos, Est_cerrados, Est_abiertos)
          Est_abiertos.insertar(Hijos)
        fin
        Actual← Est_abiertos.primero()
      fin
      prof ← prof+1
    fin

Aparentemente podría parecer que este algoritmo es más costoso que los anteriores al tener que repetir en cada iteración la búsqueda anterior, pero si pensamos en el número de nodos nuevos que recorremos a cada iteración, estos son siempre tantos como todos los que hemos recorrido en todas las iteraciones anteriores, por lo que las repeticiones suponen un factor constante respecto a los que recorreríamos haciendo solo la última iteración.

Respecto a la complejidad en tiempo, se comporta como DFS y BFS, del orden \(O(b^d)\), esto es, en el peor caso es exponencial en \(d\). ID visita los nodos a profundidad \(0\), \(d+1\) veces, los que están a profundidad \(1\), \(d\) veces, ..., y los que están a produndidad \(d\), \(1\) vez. Por tanto, el tiempo total requerido es:

$1+(1+b)+(1+ b+ b^2)+\dots+(1+ b+ b^2 + \dots + b^d)= O(1+b+b^2 + \dots + b^d)= O(b^d)$

Igual que en el caso del algoritmo en profundidad, el tratar nodos repetidos acaba con todas las ventajas espaciales del algoritmo, por lo que es aconsejable no hacerlo. Como máximo se puede utilizar la estructura de nodos abiertos para detectar bucles en el camino actual.

### Anchura iterada

El algoritmo en **Anchura Iterada** (**IB**) es análogo al ID, pero realiza una búsqueda DFS primero en los subárboles de anchura \(1\), después en los de anchura \(2\),... hasta encontrar un nodo solución. 

<img src="http://www.cs.us.es/~fsancho/images/2015-07/3610c732-152b-11e2-bb76-001e670c2818.png">

IB no es completo por las mismas causas que no lo era DFS. Como no ofrece muchas más novedades respecto a los ya vistos, no profundizaremos más en él, y sólo destacaremos que puede ser aconsejable su uso cuando el árbol tiene un valor de ramificación excesivamente alto.

### Búsqueda Bidireccional 

Un problema de **Búsqueda bidireccional** es una extensión del problema de búsqueda general planteado antes. Se define como una 5-tupla \((X,S,G,\delta,\gamma)\), donde \((X,S,G,\delta)\) es un problema de búsqueda básico y \(\gamma: X \rightarrow 2^X\) es una función de **transición inversa**, es decir, que \(\gamma(x)\) es el conjunto de predecesores de \(x\).

En la búsqueda bidireccional (BB), tal y como sugiere su nombre, se realizan dos búsquedas simultáneas: una desde el estado inicial hasta el estado final, y otra desde el estado final hasta el estado inicial. La búsqueda global acaba cuando ambas búsquedas parciales se encuentran. Sin embargo, no todos los problemas de búsqueda básicos se pueden plantear de forma sencilla como problemas de búsqueda bidireccionales, muchas veces porque no es sencillo proporcionar la función de transición inversa.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/6ce16176-154f-11e2-bb76-001e670c2818.gif">

Habitualmente, se suele implementar como un par de algoritmos BFS simultáneos, así que, como ellos, será óptimo y completo. Sin embargo, la BB mejora a BFS en términos de complejidad, ya que su complejidad en tiempo es exponencial en \(d/2\) (cuando ambas búsquedas deben recorrer todos los nodos que le corresponden). Su complejidad en espacio es también del orden de \(b^{d/2}\), ya que debe mantener una lista de todos los nodos a profundidad \(i\), y el número de nodos a profundidad \(d/2\) es \(b^{d/2}\).

Como variante de este método, existe la **búsqueda dirigida por islas**, que es una generalización del BB en el que se establecen un conjunto de objetivos intermedios (**islas**), lo que suele reducir un problema de búsqueda grande en un conjunto de problemas de búsqueda menores. Si se van espaciando estas islas entre el nodo origen y el objetivo, se puede conseguir que su complejidad mejore, haciendo \(mb^{d/m} « b^d\). Las cotas decrecen, pero suele ser difícil garantizar la optimalidad, ya que habría que asegurar que todas las islas (u objetivos intermedios) están en el camino óptimo de la solución original.

El número de variantes que se han dado para mejorar la casuística de las búsquedas ciegas es enorme, y como nuestro objetivo es solo conocer las aproximaciones clásicas a la resolución de problemas, no entraremos en más detalles y pasaremos a estudiar otros tipos de búsquedas que resulten más eficientes en general.

! ### Para saber más...
! [Jorge Valverde Rebaza: Problema del 8-puzle y búsqueda no informada](http://jc-info.blogspot.com.es/2009/04/problema-del-8-puzzle-y-busqueda-no.html)
! [Wikipedia: Búsquedas no informadas](http://es.wikipedia.org/wiki/B%C3%BAsquedas_no_informadas)
! [Transparencias de la Universidad Carlos III de Madrid](http://ocw.uc3m.es/ingenieria-informatica/inteligencia-artificial-2/material-de-clase-1/no-informada.pdf)