---
title: 'Búsquedas Informadas'
taxonomy:
    category: docs
visible: true
---

_(Basado en los apuntes del Departament de Llenguatges i Sistemes Informàtics de la Universitat Politécnica de Catalunya)_
[TOC]
<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/31a2b83a-1630-11e2-bb76-001e670c2818.jpg"/>Es evidente que los **algoritmos de búsqueda ciega** (o **no informada**) serán incapaces de encontrar soluciones en problemas en los que el tamaño del espacio de búsqueda sea grande, ya que todos ellos tienen un coste temporal que es exponencial en el tamaño del dato de entrada, por lo que cuando se aplican a problemas reales el tiempo para encontrar la mejor solución a un problema no es asumible.

Una de las formas para intentar reducir este tiempo de búsqueda a cotas más razonables pasa por hacer intervenir dentro del funcionamiento del algoritmo de búsqueda conocimiento adicional sobre el problema que se está intentando resolver. En consecuencia, perderemos en generalidad, a cambio de ganar en eficiencia temporal.

En estas líneas nos centraremos en aquellos algoritmos que introducen mecanismos para manipular esa información adicional que puede suponer la diferencia entre tardar un tiempo impracticable para hallar la solución óptima y poder encontrarla en tiempos razonables.

## Calculando costes para optimizar

Al igual que se hace con la búsqueda ciega, hemos de definir qué entendemos por **búsqueda del óptimo**, por lo que hemos de dar alguna medida del coste de obtener una solución. En general, este coste se medirá sobre el camino que nos lleva desde el estado inicial del problema hasta el estado final. No siempre es una medida factible ni deseable, pero nos centraremos en problemas en los que esta medida del óptimo tenga sentido. Para poder calcular este coste de forma efectiva, tendremos un coste asociado a los operadores que permiten pasar de un estado a otro.

Los algoritmos que veremos utilizarán el coste de los caminos explorados para saber qué nodos merece la pena explorar antes que otros. De esta manera, perderemos la sistematicidad de los algoritmos de búsqueda no informada, y el orden de visita de los estados no vendrá determinado por su posición en el grafo de búsqueda, sino por su coste respecto del problema real que intentan resolver.

En la mayoría de los problemas, debido al tamaño del espacio de búsqueda, no podemos plantearnos generar todo el grafo asociado de una vez, sino que deber ser generado a medida que es explorado, por lo que se tienen dos elementos fundamentales que intervienen en el coste del camino que va desde el estado inicial hasta la solución que buscamos:

1.  En primer lugar, tendremos **el coste del camino recorrido**, que podremos calcular simplemente sumando los costes de los operadores aplicados desde el estado inicial hasta el nodo actual. En consecuencia, este coste es algo que se puede calcular con exactitud.
2.  En segundo lugar, tendremos un coste más difícil de determinar, **el coste del camino que nos queda por recorrer hasta el estado final**. Dado que lo desconocemos, tendremos que utilizar el conocimiento del que disponemos del problema para obtener una aproximación. Es aquí donde interviene el adjetivo de "**heurística**" que se aplica a este tipo de algoritmos de búsqueda.

Evidentemente, la calidad de este conocimiento que nos permite aproximar el coste futuro hará más o menos exitosa nuestra búsqueda. Si nuestro conocimiento fuera perfecto, podríamos dirigirnos rápidamente hacia el objetivo descartando todos los caminos de mayor coste, eligiendo en cada momento el mejor estado posible, y dando la solución en tiempo lineal. En el otro extremo, si estuviéramos en la total ignorancia, tendríamos que explorar muchos caminos antes de hallar la solución óptima. Una situación similar a la que se encuentra en la búsqueda ciega.

Así pues, esta función heurística de coste futuro se vuelve fundamental en la resolución eficiente del problema, de forma que, cuanto más ajustada esté al coste real, mejor funcionarán los algoritmos que hagan uso de ella. El fundamento de los algoritmos de búsqueda heurística será el modo de elegir qué nodo explorar primero, para ello podemos utilizar diferentes estrategias que nos darán diferentes propiedades.

## Algoritmo Voraz

<img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/f3baa5fa-1639-11e2-bb76-001e670c2818.png"/> Una primera estrategia, que representa una heurística muy limitada pero muy extendida, es utilizar como estimación futura el coste del siguiente paso que vamos a dar, que lo podemos calcular fácilmente desde el nodo actual en el que nos encontramos. En este caso, la heurística usada se resume en suponer que, en cada paso, el mejor camino se consigue al minimizar el coste inmediato.

Esta estrategia se traduce en el **algoritmo voraz** (**greedy best first**), cuya única diferencia con respecto a los algoritmos ciegos es que utiliza alguna estructura ordenada de datos para almacenar los nodos abiertos (por ejemplo, una cola con prioridad), de forma que aquellos que supongan un coste inmediato menor se coloquen primero. Una posible implementación podría ser la siguiente:
    
	Algoritmo: Voraz
    Insertar Estado_inicial Est_abiertos
    Actual ← Primero Est_abiertos
    mientras Actual no es_final? y Est_abiertos no vacía? hacer
      Quitar_primero Est_abiertos
      Insertar Actual Est_cerrados
      hijos ← generar_sucesores_ordenados_por_peso (Actual)
      hijos ← tratar_repetidos (Hijos, Est_cerrados, Est_abiertos)
      Insertar Hijos Est_abiertos
      Actual ← Primero Est_abiertos
    fin

Aunque explorar antes los nodos vecinos más cercanos puede ayudar a encontrar una solución antes, es fácil dar ejemplos en los que no se garantice que la solución encontrada sea óptima.

## El algoritmo A estrella
Dado que nuestro objetivo no es solo llegar lo mas rápidamente a la solución, sino encontrar la de menor coste tendremos que tener en cuenta el coste de todo el camino y no solo el camino recorrido o el camino por recorrer.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/c685bc9e-178f-11e2-bb76-001e670c2818.jpg"/>

Para poder introducir el siguiente algoritmo y establecer sus propiedades es necesario conocer las siguientes definiciones:

*   El **coste de una arista** entre dos nodos \(n_i\) y \(n_j\) es el coste del operador que nos permite pasar de un nodo al otro, y lo denotaremos como \(c(n_i,n_j)\). Este coste siempre será positivo.
*   El **coste de un camino** entre dos nodos \(n_i\) y \(n_j\) es la suma de los costes de todos los arcos que llevan desde un nodo al otro y lo denotaremos como: 
$C(n_i,n_j) =\sum_{x=i}^{j-1}  c(n_x,n_{x+1})$
*   El **coste del camino mínimo** entre dos nodos \(n_i\) y \(n_j\) (el del camino de menor coste de aquellos que llevan desde un nodo al otro) se denotará por:
$ K(n_i,n_j) = min_{k} C_k(n_i,n_j)$
*   Si \(n_j\) es un nodo terminal, para cada nodo \(n_i\) notaremos \(h^∗(n_i) = K(n_i,n_j)\), es decir, el coste del camino mínimo desde ese estado a un estado solución.
*   Si \(n_i\) es un nodo inicial, para cada nodo \(n_j\) notaremos \(g^∗(n_j) = K(n_i,n_j)\), es decir, el coste del camino mínimo desde un estado inicial a ese estado.

<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/f31d7178-1638-11e2-bb76-001e670c2818.gif"/> Esto nos permite definir **el coste del camino mínimo** que pasa por cualquier nodo como la suma del coste del camino mínimo desde el nodo inicial y el coste del camino mínimo nodo hasta  el nodo final:

$f^*(n) = g^*(n) + h^*(n)$

El problema habitual suele ser que para un nodo cualquiera, \(n\), el valor de \(h^*(n)\) es desconocido,  por lo que este valor hemos de **estimarlo** por una función que nos lo aproximará, a esta función la denotaremos \(h(n)\) y le daremos el nombre de **función heurística**, que debe ser siempre un valor mayor o igual que cero. Denominaremos \(g(n)\) al coste del camino desde el nodo inicial al nodo \(n\), que en este caso sí es conocido ya que lo hemos recorrido en nuestra exploración. De esta manera tendremos una estimación del coste del camino mínimo que pasa por cierto nodo:

$f(n) = g(n) + h(n)$

Este será el valor que utilizaremos para decidir en nuestro algoritmo de búsqueda cuál es el siguiente nodo a explorar de entre todos los nodos abiertos disponibles por medio del siguiente algoritmo, que denominaremos \(A^∗\):

    Algoritmo: \(A^\*\)
    Insertar Estado_inicial Est_abiertos
    Actual ← Primero Est_abiertos
    mientras Actual no es_final? y Est_abiertos no vacía? hacer
      Quitar_primero Est_abiertos
      Insertar Actual Est_cerrados
      hijos ← generar_sucesores_ordenados_por_heurística (Actual)
      hijos ← tratar_repetidos (Hijos, Est_cerrados, Est_abiertos)
      Insertar Hijos Est_abiertos
      Actual ← Primero Est_abiertos
    fin

<iframe width="180"  height="120" src="https://www.youtube.com/embed/sAoBeujec74" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/cX1Zsi5kaEI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/_CBhTubi-CU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Se puede observar que el algoritmo es prácticamente el mismo que el algoritmo voraz visto anterioremnte, pero ahora la ordenación de los nodos se realiza utilizando el valor de la función heurística \(f\) general, y no el caso particular del coste inmediato. Por convención, suele considerarse que, a igual valor de \(f\) los nodos con \(h\) más pequeña se explorarán antes (simplemente, porque si la \(h\) es más pequeña es porque esos nodos parecen estar más cerca de la solución), y a igual \(h\) se consideran en cualquier orden (por ejemplo, el orden en el que se introdujeron en la cola), ya que no tenemos criterios para tomar una decisión.

Nunca está de más el remarcar que el algoritmo solo acaba cuando se extrae una solución de la cola. Es posible que en cierto momento ya haya en la estructura de nodos abiertos algunos nodos que sean solución, pero hasta que no se hayan explorado los nodos por delante de ellos, no podemos asegurar que realmente sean soluciones buenas. Debe recordarse que los nodos están ordenados por el coste estimado del camino total, si esta estimación en un nodo es menor es que podría pertenecer a un camino que representa una solución mejor. Si no tomáramos esta precaución, podríamos tener el mismo problema que presenta el algoritmo voraz. 

En el peor de los casos el coste temporal de este algoritmo es también \(O(r^p)\). Si, por ejemplo, la función \(h(n)\) fuera siempre \(0\) el algoritmo se comportaría como una búsqueda en anchura gobernada por el coste del camino recorrido. De hecho, una posible interpretación de las funciones \(g\) y \(h\) es que gobiernan el comportamiento en anchura o profundidad del algoritmo.

Evidentemente, lo que hace que este algoritmo pueda tener un coste temporal inferior es la bondad de la función \(h\). Cuanto más cercana sea al coste real (que habíamos denotado \(h^\*\)), mayor será el comportamiento en profundidad del algoritmo, pues los nodos que aparentemente están más cerca de la solución se explorarán antes. En el momento en el que esa información deje de ser fiable, el coste del camino ya explorado hará que otros nodos menos profundos tengan un coste total mejor y, por lo tanto, se abrirá la búsqueda en anchura.

Si pensamos un poco en el coste espacial que tendrá el algoritmo, llegamos a la conclusión de que, debido a que puede llegar a comportarse como una búsqueda en anchura, el peor caso sería \(O(r^p)\). Un resultado teórico a tener en cuenta es que el coste espacial del algoritmo \(A^∗\) crece exponencialmente a no ser que se cumpla que:

$|h(n) − h^*(n)| < O(log(h^*(n))$

Este resultado nos da una cota para posibles actuaciones: Si no podemos encontrar una función heurística suficientemente buena, deberíamos usar algoritmos que no buscasen el óptimo pero garantizasen el encontrar una buena solución.

  
<img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/52d0bd32-1634-11e2-bb76-001e670c2818.jpg"/> El tratamiento de nodos repetidos en este algoritmo se realiza de la siguiente forma:

*   Si el nodo que se repite está en la estructura de nodos abiertos:
    *   Si su coste es menor, sustituimos el coste por el nuevo, lo que podrá variar su posición en la estructura de nodos abiertos.
    *   Si su coste es igual o mayor, nos olvidamos del nodo, ya que no aporta nada mejor que lo que teníamos.
*   Si el nodo que se repite está en la estructura de nodos cerrados:
    *   Si su coste es menor, reabrimos el nodo insertándolo en la estructura de nodos abiertos con el nuevo coste, no hacemos nada con sus sucesores, ya que se reabrirán si hace falta.
    *   Si su coste es mayor o igual, nos olvidamos del nodo.



## ¿Cuándo podemos encontrar el óptimo?

Hasta ahora no hemos hablado de cómo garantizar la optimalidad de la solución. Hemos visto que en el caso degenerado (\(h=0\)) tenemos una búsqueda en anchura guiada por el coste del camino explorado, eso nos debería garantizar el óptimo en este caso, aunque a costa de un mayor tiempo de búsqueda. Pero como hemos comentado, la función \(h\) nos permite introducir un comportamiento de búsqueda en profundidad, donde sabemos que no se garantiza el óptimo, pero a cambio podemos realizar la búsqueda en menor tiempo, porque podemos evitar explorar ciertos caminos.

Para saber si encontraremos o no el óptimo mediante el algoritmo \(A^*\) hemos de analizar las propiedades de la función heurística:

### Admisibilidad

La propiedad clave que garantizará hallar la solución óptima es la que denominaremos **admisibilidad:**

Diremos que una función heurística \(h\) es **admisible** cuando su valor en cada nodo sea menor o igual que el valor del coste real del camino que falta por recorrer hasta la solución, es decir: $\forall n \ (0 ≤ h(n) ≤ h^∗(n))$

Esto quiere decir que la función heurística ha de ser un **estimador optimista** del coste que falta para llegar a la solución. Esta propiedad implica que, si podemos demostrar que la función de estimación \(h\) que utilizamos en nuestro problema la cumple, siempre encontraremos una solución óptima. El problema radica en hacer esa demostración, pues cada problema es diferente.

Para una discusión sobre técnicas para construir heurísticos admisibles se puede consultar el capítulo 4, sección 4.2, del libro “Inteligencia Artificial: Un enfoque moderno” de S. Russell y P. Norvig.

### Consistencia
La **consistencia** se puede ver como una extensión de la admisibilidad. A partir de la admisibilidad se deduce que si tenemos el coste \(h^*(n_i)\) y el coste \(h^*(n_j)\) y el coste óptimo para ir de \(n_i\) a \(n_j\), o sea \(K(n_i,n_j)\), se ha de cumplir la desigualdad triangular:

$h^*(n_i) ≤ h^*(n_j) + K(n_i,n_j)$

La **consistencia** exige pedir lo mismo al estimador \(h\):

$h(n_i) − h(n_j) ≤ K(n_i,n_j)$

Es decir, que la diferencia de las estimaciones sea menor o igual que la distancia óptima entre nodos. Que esta propiedad se cumpla quiere decir que \(h\) es un estimador uniforme de \(h^*\). Es decir, la estimación de la distancia que calcula \(h\) disminuye de manera uniforme.

Si \(h\) es consistente además se cumple que el valor de \(g(n)\) para cualquier nodo es \(g^*(n)\), por lo tanto, una vez hemos llegado a un nodo sabemos que hemos llegado a él por el camino óptimo desde el nodo inicial. Si esto es así, no es posible que encontrar el mismo nodo por un camino alternativo con un coste menor y esto hace que el tratamiento de nodos cerrados duplicados sea innecesario, lo que ahorra tener que almacenarlos.

Suele ser un resultado habitual que las funciones heurísticas admisibles sean consistentes y, de hecho, hay que esforzarse bastante para conseguir que no sea así.





### Heurístico más informado

Otra propiedad interesante es la que permite comparar heurísticas entre sí, y permite saber cuál de ellos hará que \(A^*\) necesite explorar más nodos para encontrar una solución óptima:

Se dice que el heurístico \(h_1\) es **más informado** que el heurístico \(h_2\) si se cumple la propiedad:$\forall n\ (0 ≤ h_2(n) < h_1(n) ≤ h^∗(n))$  

En particular, poder verificar esta propiedad implica que los dos heurísticos son admisibles.

Si un heurístico es mas informado que otro, al hacer uso de él en el algoritmo \(A^*\) se expandirán menos nodos durante la búsqueda, ya que su comportamiento será más en profundidad y habrá ciertos nodos que no se explorarán.

Esto podría hacer pensar que siempre hay que escoger el heurístico más informado, pero se ha de tener en cuenta que la función heurística también tiene un tiempo de cálculo que afecta al tiempo de cada iteración, y que suele ser más costoso cuanto más informado sea el heurístico. Podemos imaginar por ejemplo que, si tenemos un heurístico que necesita 10 iteraciones para llegar a la solución, pero tiene un coste de 100 unidades de tiempo por iteración, tardará más en llegar a la solución que otro heurístico que necesite 100 iteraciones pero que solo necesite una unidad de tiempo por iteración. Lo que lleva a buscar un equilibrio entre el coste del cálculo de la función heurística y el número de expansiones que ahorramos al utilizarla. En este sentido, es posible que una función heurística peor acabe dando mejor resultado.

## Variante con menos memoria: El algoritmo IDA estrella

Como hemos visto, el algoritmo \(A^*\) tiene limitaciones de espacio por poder acabar degenerando en una búsqueda en anchura si la función heurística no es demasiado buena. Además, al igual que ocurría en la búsqueda ciega, si la solución del problema está a mucha profundidad o el tamaño del espacio de búsqueda es muy grande, podemos encontrarnos con necesidades de espacio prohibitivas. Esto lleva a buscar algoritmos alternativos que tengan menores necesidades de espacio.

La primera solución viene de la mano del algoritmo en profundidad iterativa de búsqueda ciega, pero añadiéndole el uso de la función \(f\) para controlar la profundidad a la que llegamos en cada iteración. En concreto, se realiza la búsqueda imponiendo un límite al coste del camino que se quiere hallar (en la primera iteración, la \(f\) del nodo raíz), explorando en profundidad todos los nodos con \(f\) igual o inferior a ese límite y reiniciando la búsqueda con un coste mayor si no encontramos la solución en la iteración actual:

    Algoritmo: IDA\* (limite entero)
    prof ← f(Estado inicial)
    Actual ← Estado inicial
    mientras Actual no es_final? y prof
      Inicializa Est_abiertos
      Insertar Estado_inicial Est_abiertos
      Actual ← Primero Est_abiertos
      mientras Actual no es_final? y Est_abiertos no vacía? hacer
        Quitar_primero Est_abiertos
        Insertar Actual Est_cerrados
        Hijos ← generar_sucesores_acotados (Actual, prof)
        Hijos ← tratar_repetidos (Hijos, Est_cerrados, Est_abiertos)
        Insertar Hijos Est_abiertos
        Actual ← Primero Est_abiertos
      fin
      prof ← prof+1
    fin

La función generar_sucesores solo retorna los nodos con un coste inferior o igual al de la iteración actual.

Este algoritmo, al necesitar solo una cantidad de espacio lineal, permite hallar soluciones a más profundidad, aunque hay que pagar el precio de reexpandir nodos ya visitados. Este precio extra dependerá de la conectividad del grafo asociado al espacio de estados, si existen muchos ciclos éste puede ser relativamente alto ya que a cada iteración la efectividad de la exploración real se reduce con el número de nodos repetidos que aparecen.

! ###  Para saber más...
! [Depth-first Iterative-Deepening: An Optimal Admissible Tree Search (1985)](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.91.288)
! [Inteligencia Artificial de la Universidad de Barcelona](http://www.lsi.upc.edu/~bejar/ia/ia.html)
! [Wikipedia: Algoritmo A\*](https://es.wikipedia.org/wiki/Algoritmo_de_búsqueda_A*)
! [A\* pathfinding para principiantes](http://www.policyalmanac.org/games/articulo1.htm)