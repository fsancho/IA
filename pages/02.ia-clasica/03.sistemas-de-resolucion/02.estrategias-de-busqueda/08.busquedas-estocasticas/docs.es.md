---
title: 'Búsquedas Estocásticas'
taxonomy:
    category: docs
visible: true
---

[TOC]
## Introducción
Cuando los espacios de búsqueda son extremadamente grandes o tienen estructuras relativamente complejas, los procedimientos de búsqueda deterministas suelen obtener muy malos resultados. La Búsqueda Estocástica introduce factores de aleatoriedad en esos procesos de forma que, bien usada, puede reducir considerablemente la complejidad del problema. Por supuesto, en este proceso se pierde algo, y es que se sustituye la optimalidad por la tratabilidad en tiempo (es decir, el problema se puede resolver en un tiempo razonable, pero ya no podemos estar 100% seguros de que vayamos a encontrar la solución siempre).

Hay dos algoritmos de búsqueda estocásticos triviales que podemos identificar claramente:

1.  **Búsqueda Aleatoria**: En cada paso, se selecciona al azar un elemento del espacio de búsqueda y comprobamos si tiene las propiedades deseadas.
2.  **Camino Aleatorio sin información**: En cada paso, se selecciona al azar un vecino del estado actual y nos desplazamos a él.

Obviamente, estas dos modificaciones para introducir la aleatoriedad tienen pocas opciones de ser eficientes en espacios relativamente complejos, pero suponen un punto de partida sobre el que construir otros algoritmos estocásticos que arrojan buenos resultados. El más famoso de ellos es el algoritmo del **Templado Simulado** (o **Enfriamiento Simulado**), que veremos a continuación:

## Templado Simulado

Hay muchas veces en los que los algoritmos de búsqueda por ascenso se quedan atascados enseguida en óptimos no demasiado buenos. Para estos casos se han diseñado algoritmos que a veces pueden dar soluciones relativamente buenas, como el que veremos en esta sección: **templado simulado** (**simulated annealing**).

Este algoritmo está inspirado en un fenómeno físico que se observa en el templado de metales y en la cristalización de disoluciones:

<img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2016-09/templaracero.jpg"/>Todo conjunto de átomos o moléculas tiene un estado de energía que depende de cierta función de la temperatura del sistema. A medida que lo vamos enfriando, el sistema va perdiendo energía hasta que se estabiliza. El fenómeno físico que se observa es que, dependiendo de cómo se realiza el enfriamiento, el estado de energía final es muy diferente. Por ejemplo, si una barra de metal se enfría demasiado rápido la estructura cristalina a la que se llega al final está poco cohesionada (un número bajo de enlaces entre átomos) y ésta se rompe con facilidad. Si el enfriamiento se realiza más lentamente, el resultado final es totalmente diferente, el número de enlaces entre los átomos es mayor, y se obtiene una barra mucho más difícil de romper. Durante este enfriamiento controlado se observa que la energía del conjunto de átomos no disminuye de manera constante, sino que a veces la energía total puede ser mayor que en un momento inmediatamente anterior. Esta circunstancia hace que el estado de energía final que se alcanza sea mejor que cuando el enfriamiento se hace rápidamente.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/ae57f5de-25a3-11e2-bb76-001e670c2818.png"/>

A partir de este fenómeno físico, se puede obtener un algoritmo que permite, en ciertos problemas, obtener soluciones mejores que las proporcionadas por los algoritmos vistos hasta ahora. En este algoritmo el nodo siguiente a explorar no será siempre el mejor descendiente, sino que se elige aleatoriamente, en función de los valores de unos parámetros, de entre todos los descendientes (los buenos y los malos). Una ventaja de este algoritmo es que no hay por qué generar todos los sucesores de un nodo, basta elegir un sucesor al azar y decidir si continuamos por él o no.

El algoritmo de templado simulado intenta transportar la analogía física al problema que se quiere solucionar. En primer lugar, se denomina **función de energía** a la función heurística que mide la calidad de una solución. Tendremos un parámetro de control que denominaremos **temperatura**, que permitirá controlar el funcionamiento del algoritmo. También se tendrá una función que dependerá de la temperatura y de la diferencia de calidad entre el nodo actual y un sucesor. Esta función dirigirá la elección de los sucesores de la forma siguiente:

*   Cuanta mayor sea la temperatura, más probabilidad habrá de que al generar como sucesor un estado peor éste sea elegido.
*   La elección de un estado peor estará en función de su diferencia de calidad con el estado actual, cuanta más diferencia, menos probabilidad de elegirlo.

El último elemento es la **estrategia de enfriamiento**. El algoritmo realiza un número total de iteraciones fijo y cada cierto número de ellas el valor de la temperatura disminuye en cierta cantidad, partiendo desde una temperatura inicial y llegando a cero en la última fase. De manera que la elección de estos dos parámetros (**número total de iteraciones** y **número de iteraciones entre cada bajada de temperatura**) determina el comportamiento completo del algoritmo. Hay que decidir experimentalmente cuál es la temperatura inicial más adecuada y también la forma más adecuada de hacer que vaya disminuyendo.

    Algoritmo: Templado Simulado
    T ← T0
    mientras T > 0 hacer
      // Paseo aleatorio por el espacio de soluciones
      para un numero prefijado de iteraciones hacer
        Enuevo ← Genera_sucesor_al_azar(Eactual)
        ∆E ← f(Eactual) − f(Enuevo)
        si ∆E > 0 entonces
          Eactual ← Enuevo
        si no
          con probabilidad e^∆E/T: Eactual ← Enuevo
        fin
      fin
      Disminuir T
    fin

Como en la analogía física, si el número de pasos es muy pequeño, la temperatura bajará muy rápidamente, y el camino explorado será relativamente aleatorio. Si el número de pasos es más grande, la bajada de temperatura será más suave y la búsqueda será mejor.

Este algoritmo es especialmente bueno para problemas con un espacio de búsqueda grande en los que el óptimo está rodeado de muchos óptimos locales, ya que le es más fácil escapar de ellos. Se puede utilizar también para problemas en los que encontrar una heurística discriminante es difícil (una elección aleatoria es tan buena como otra cualquiera), ya que en estos casos el algoritmo de ascenso de colinas no tiene mucha información con la que trabajar y se queda atascado enseguida, mientras que el templado simulado puede explorar más espacio de soluciones y tiene mayor probabilidad de encontrar una solución buena.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/2790e83c-25a6-11e2-bb76-001e670c2818.png"/>

El mayor problema de este algoritmo es determinar los valores de los parámetros, y requiere una importante labor de experimentación que depende de cada problema. Los valores óptimos de estos parámetros varían con el dominio e incluso con el tamaño de la instancia concreta del problema.

<iframe width="180"  height="120" src="https://www.youtube.com/embed/6gmnP90C0Bw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/E8tkpzDne7I" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/NPE3zncXA5s" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
