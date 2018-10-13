---
title: 'Búesquedas Locales'
taxonomy:
    category: docs
visible: true
---

[TOC]
## Introducción
<img  style="float:left;margin:0 10px 10px 0;width:300px" src="http://www.cs.us.es/~fsancho/images/2015-07/052c3a86-25dc-11e2-bb76-001e670c2818.jpg"/> Hasta ahora hemos visto métodos de resolución de problemas en los que el objetivo era buscar un camino en un espacio de estados (ya sea porque estamos interesados en cómo alcanzar un estado final, o porque es el propio camino el que nos interesa), pero podemos encontrarnos que no siempre es factible esta aproximación, algo que puede ocurrir por dos razones principalmente:

*   porque este **planteamiento resulte demasiado artificial** y lejano al problema porque **no haya operadores de transición**, o porque no sea natural asociar una función de coste a dichos estados,
*   o porque no hay posibilidad de hallar una solución óptima debido a que el **tamaño del espacio de búsqueda es demasiado grande**, y en este caso nos conformamos con una solución que podamos considerar **suficientemente** buena.

Si estamos ante un caso así, podemos encontrarnos con dos opciones:

1.  Si es relativamente asequible encontrar una solución inicial, aunque no sea demasiado buena, podemos cambiar nuestra tarea de buscar un camino entre estados a **encontrar una mejora sucesiva** en el espacio de soluciones.
2.  Si no es posible encontrar una solución inicial (aunque no sea suficientemente buena) podemos ver si, partiendo de una solución no válida, podemos ir construyendo una solución que sí lo sea.

En este cambio de perspectiva, pues, lo que suponemos es que podemos navegar dentro del espacio de las posibles soluciones, realizando operaciones sobre ellas que pueden ayudar a mejorarlas. Estas operaciones no tienen porqué tener una representación en el mundo real, sino que son simplemente formas de manipular las posibles soluciones para encontrar otras opciones. El coste de estas operaciones no será tan relevante ya que lo que estamos buscando es la calidad de las soluciones, y no la forma de llegar a ellas. Al igual que en las estrategias vistas en temas anteriores disponíamos de una función de coste que nos decía lo bueno que podía ser el camino que hacía uso de esas operaciones, ahora tendremos que disponer de una función que según algún criterio (dependiente del dominio) medirá su calidad y permitirá ordenarlas respecto a lo óptimas que sean.

La estructura general que tendremos en este tipo de aproximaciones es similar al que destacamos en las búsquedas en estados de espacios:

1.  Una **solución inicial**, que en este caso será una solución completa, no un trozo inicial del camino y que, aunque la llamemos así, no tiene porqué ser una solución en su sentido estricto.
2.  **Operadores de cambio de la solución**, que en este caso manipularán soluciones completas y que no tendrán un coste asociado.
3.  Una **función de calidad**, que debe medir lo buena que es una solución y permitirá dirigir la búsqueda. A diferencia de las funciones heurísticas anteriores, en este caso esta función no indica cuánto falta para encontrar la solución que buscamos, sino que proporciona una forma de comparar la calidad entre soluciones para indicarnos cuál es la dirección que debemos tomar para encontrar soluciones mejores.

Debido a que puede no ser posible encontrar la mejor solución, saber cuándo hemos acabado la búsqueda dependerá totalmente del tipo de algoritmo que diseñemos, que tendrá que decidir cuándo debemos parar porque ya no sea posible encontrar una solución mejor o porque no merezca la pena seguir avanzando, por lo que podemos encontrarnos ante casos en los que no disponemos de un estado final definido.

En cierta forma, es similar al proceso de encontrar óptimos (máximos o mínimos) de funciones... en este caso la función a optimizar es la función de calidad de la solución. Lo normal es que se calculen estos óptimos por medios analíticos aprovechando la expresión de la función y sus propiedades de continuidad y diferenciabilidad, pero en los casos que a menudo nos encontramos en problemas de Inteligencia Artificial las funciones con las que se trabaja no tienen una expresión analítica conocida, o no verifican las condiciones de diferenciabilidad o continuidad necesarias para aplicar loas algoritmos de búsqueda de óptimos en funciones. Por ello, tenemoss que explorar la función de calidad utilizando únicamente lo que podamos obtener de los vecinos de la solución que hemos encontrado... es decir, haciendo uso únicamente de **información local** durante el proceso.

## Ascenso de la colina
  
<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/cfd285b4-25a1-11e2-bb76-001e670c2818.png"/> Debido a que en muchos problemas el tamaño del espacio de búsqueda hace que sea inabordable de manera exhaustiva, se deben buscar estrategias diferentes a las utilizadas hasta ahora. En primer lugar, puede haber pocas posibilidades de guardar información para recuperar caminos alternativos dado el gran número de alternativas que se presentan, lo que obliga a imponer restricciones de espacio decidiendo qué nodos deben ser explorados y cuáles deben ser descartados sin volver a considerarlos.

Este método general de eliminar ramas de exploración del árbol de búsqueda da lugar a una familia de algoritmos conocida como de **ramificación y poda** (**branch and bound**), en la que olvidamos aquellas opciones que no parecen prometedoras. Estos algoritmos permiten mantener una memoria limitada, ya que desprecian parte del espacio de búsqueda, pero se arriesgan a no hallar la mejor solución, ya que ésta puede estar en el espacio de búsqueda que ha sido eliminado.

De los algoritmos de ramificación y poda, unos de los más utilizados son los que se llaman **de ascenso de colinas** (**Hill-climbing**), de los que existen variantes que pueden ser útiles en distintos casos:

*   **Ascenso de colinas simple**: consiste en elegir siempre el primer operador que suponga una mejora respecto al nodo actual, de manera que no exploramos todas las posibilidades accesibles, ahorrándonos el explorar cierto número de descendientes. Presenta la ventaja de ser más rápido que explorar todas las opciones, pero la desventaja de que hay más probabilidad de no alcanzar las soluciones mejores. En cierta forma, sería el equivalente al algoritmo voraz para este tipo de casos pero con información limitada (ya que no explora todos los posibles sucesores).

<img src="http://www.cs.us.es/~fsancho/images/2015-07/3ce06cca-25a2-11e2-bb76-001e670c2818.png"/>

*   **Ascenso de colinas por máxima pendiente** (**steepest ascent hill climbing**): expande todos los posibles descendientes de un nodo y elige el que suponga la máxima mejora respecto al nodo actual. Este algoritmo supone que la mejor solución la encontraremos a través del sucesor que mayor diferencia tenga respecto a la solución actual, siguiendo una política avariciosa. La utilización de memoria para mantener la búsqueda es nula, ya que solo tenemos en cuenta el nodo mejor. Se pueden hacer versiones que guarden caminos alternativos que permitan una vuelta atrás en el caso de que consideremos que la solución a la que hemos llegado no es suficientemente buena, pero en este caso han de imponerse ciertas restricciones de memoria para no tener un coste en espacio demasiado elevado.

     Algoritmo: Ascenso de colinas por máxima pendiente
     Actual ← Estado_inicial
     seguir? ← verdad
     mientras seguir? hacer
       Hijos ← generar_sucesores(Actual)
       Hijos ← ordenar_y_eliminar_peores(Hijos, Actual)
       si no vacio?(Hijos) entonces
         Actual ← Escoger_mejor(Hijos)
       si no
         seguir? ← falso
       fin
     fin

La estrategia que se usa en este algoritmo hace que sus problemas vengan principalmente derivados por las características de las funciones heurísticas que se utilizan. Por un lado, hemos de considerar que el algoritmo dejará de explorar cuando no encuentra ningún nodo accesible mejor que el actual, pero como no mantiene memoria del camino recorrido, le será imposible reconsiderar su decisión de modo que, si se ha equivocado, puede ocurrir que la solución a la que llegue no sea un óptimo global, sino solo un óptimo local. Esta posibilidad, muy común al atacar problemas reales, se puede presentar cuando la función heurística que se utilice tenga óptimos locales, de forma que, dependiendo de por donde se comience la búsqueda, se acaba encontrando un óptimo distinto.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/5562712c-25a1-11e2-bb76-001e670c2818.png"/>

*   **Búsqueda por ascenso con reinicio aleatorio** (**random restarting hill climbing**): para subsanar este problema se puede intentar la ejecución del algoritmo cierto número de veces desde distintos puntos escogidos aleatoriamente y quedarse solo con la mejor exploración. Por simple que parezca, muchas veces esta estrategia es más efectiva que otros métodos más complejos, y resulta muy barata de implementar. La única dificultad que podemos encontrar radica en la capacidad para poder generar los distintos puntos iniciales de búsqueda, ya que en ocasiones el problema no permite hallar soluciones iniciales con facilidad.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/9d43bfb0-25a5-11e2-bb76-001e670c2818.png"/>

*   **Búsqueda en haces** (**beam search**): Un problema con el que se encuentran este tipo de algoritmos son las zonas del espacio de búsqueda en las que la función heurística no es informativa, como por ejemplo las denominadas mesetas y las funciones en escalón, en las que los valores de los nodos vecinos al actual tienen valores iguales, y por lo tanto una elección local no nos permite decidir el camino a seguir. Para evitar estos problemas se debe extender la búsqueda más allá de los vecinos inmediatos para obtener información suficiente para encaminar la búsqueda, pero supone un coste adicional en cada iteración, prohibitivo cuando el factor de ramificación es excesivamente grande. Una alternativa es permitir que el algoritmo guarde parte de los nodos visitados para proseguir la búsqueda por ellos en caso de que el algoritmo se quede atascado en un óptimo local. El algoritmo más utilizado de este tipo es el denominado búsqueda en haces (**beam search**).

En este algoritmo se van guardando un número N de las mejores soluciones, expandiendo siempre la mejor de ellas. De esta manera no se sigue un solo camino sino N caminos eventualmente distintos. Las variantes que se pueden plantear están en cómo se escogen esas N soluciones que se mantienen. Si siempre se sustituyen las peores soluciones de las N por los mejores sucesores del nodo actual, caemos en el peligro de que todas acaben estando en el mismo camino, reduciendo la capacidad de volver hacia atrás, así que el poder mantener la variedad de las soluciones guardadas es importante. Está claro que cuantas más soluciones se guarden, más posibilidad habrá de encontrar una buena solución, pero se tiene un coste adicional tanto en memoria como en tiempo, ya que habrá que decidir con qué sucesores quedarse y qué soluciones guardadas se sacrifican.

    Algoritmo: Búsqueda en Haces
    Actual ← Estado_inicial
    Soluciones_actuales.añadir(Estado_inicial)
    seguir? ← verdadero
    mientras seguir? hacer
      Hijos ← generar_sucesores(Actual)
      soluciones_actuales.actualizar_mejores(Hijos)
      si soluciones_actuales.algun_cambio?() entonces
        Actual ← soluciones_actuales.escoger_mejor()
      si no
        seguir? ← falso
      fin
    fin

El algoritmo acaba cuando ninguno de los sucesores mejora a las soluciones guardadas, lo que quiere decir que todas las soluciones son un óptimo local.

! ###  Para saber más...
! [Transparencias de Javier Béjar Alonso](http://www.cs.upc.edu/~bejar/ia/transpas/teoria/2-BH3-Busqueda_local.pdf)
! [Wikipedia: Algoritmo Hill Climbing](https://es.wikipedia.org/wiki/Algoritmo_hill_climbing)
! [Local Search en Artificial Intelligence: Foundations of Computational Agents](http://artint.info/html/ArtInt_83.html)