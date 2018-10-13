---
title: 'Algoritmo de Colonias de Hormigas'
taxonomy:
    category: docs
visible: true
---

[TOC]
## El problema del Viajante

** <img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2016-11/tsp.png"/> El problema del viajante** (**TSP**: **Travelling Salesman Problem**) es uno de los problemas más famosos y estudiados en el campo de la optimización combinatoria computacional, ya que a pesar de la aparente sencillez de su planteamiento es uno de los más complejos de resolver, haciéndolo comparable en complejidad a la de otros problemas aparentemente mucho más complejos que han retado a los matemáticos desde hace siglos.

Es un ejemplo que muestra la problemática que subyace tras algunos tipos de problemas matemáticos que a priori parecen tener una solución relativamente fácil, pero que en la práctica presentan un gran reto. La dificultad de este tipo de problemas no radica en que no se sepa cómo resolverlo, sino en la eficiencia de la solución que se conoce, ya que en la práctica la solución no es factible debido al tiempo computacional que se precisa para obtenerla.

**Definición:** _El problema del viajante consiste en encontrar la ruta más corta que debe llevar a cabo un vendedor que, comenzando por un ciudad de origen visite un determinado y preestablecido conjunto de ciudades y vuelva a la ciudad original, con la restricción de que por cada ciudad sólo pase una vez._

<img src="http://www.cs.us.es/~fsancho/images/2016-11/tsp1.png"/>

Si se desea expresar el problema de forma matemática utilizando la teoría de grafos, el TSP consiste en encontrar en un grafo, $G$, que tiene asignado un coste (longitud) para cada arista, el ciclo Hamiltoniano que tenga la menor suma de costes de las aristas que lo componen.

Dentro de la **Teoría de la Complejidad**, que es la rama de la **Teoría de la Computación** que estudia, de manera teórica, la complejidad inherente a la resolución de un problema computable, se le cataloga como un problema **NP-completo**, lo que supone que los recursos computacionales necesarios para encontrar una solución óptima crecen de forma exponencial con la entrada del problema.

<img style="float:left;margin:0 10px 10px 0;width:300px" src="http://www.cs.us.es/~fsancho/images/2016-11/erdos20k_tsp.png"/> En el caso concreto del TSP la entrada es el número de nodos (o ciudades) del grafo. Cuanto mayor sea el número de nodos, mayor va a ser el número de rutas posibles, y por lo tanto mayor será el esfuerzo requerido para calcular todas ellas. Así, el número de rutas posibles entre $N$ nodos es igual a $N!$, lo que hace que la resolución del TSP mediante la obtención de todas las rutas posibles y posterior comparación entre ellas (que es el primer algoritmo que a uno se le ocurre para dar solución) es poco factible incluso para un número de nodos no muy elevado. Basta una red simple de $7$ ciudades para que sea necesario calcular más de $5000$ combinaciones, ($7!=5040$), y si subimos hasta $10$ el número de ciudades de la red, entonces las posibles rutas se disparan hasta más de tres millones ($10!=3.628.800$).

Por ello, intentar resolver el TSP en redes relativamente simples mediante el método de generación y comparación de todas las rutas es absolutamente inabordable mediante los medios computacionales disponibles actualmente, lo que hace que sea necesario utilizar otros procedimientos que, aunque no obtengan la solución óptima, sí proporcionen una respuesta aproximada lo suficientemente optimizada en un tiempo razonablemente bajo.

Mediante estas aproximaciones se han conseguido resolver TSP con varios miles de nodos que solo se diferencian en un 1% de la solución óptima. Uno de estos métodos aproximados para resolver el TSP es el que presentamos aquí y que se inspira en la forma en que las colonias de hormigas resuelven el problema de búsqueda y recolección de alimentos.

## Comportamiento Colectivo de las Hormigas

Se debe recordar que las hormigas son prácticamente ciegas, y sin embargo, moviéndose prácticamente al azar, acaban encontrando el camino más corto desde su nido hasta la fuente de alimentos (y regresar). Es importante hacer algunas consideraciones:

1.  Por una parte, una sola hormiga no es capaz de realizar la labor anterior, sino que termina siendo un **resultado del hormiguero completo**, y
2.  No lo hacen sin "instrumentos", sino que una hormiga, cuando se mueve, deja una señal química en el suelo, depositando una sustancia denominada **feromona**, para que las demás puedan seguirla.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/75d13548-3929-11e1-bb76-001e670c2818.png"/>

<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/750d0cae-3929-11e1-bb76-001e670c2818.jpg"/> En la naturaleza, las feromonas cumplen un importante papel en la organización y supervivencia de muchas especies, y representan un sistema de comunicación química entre animales de una misma especie, informando acerca del estado fisiológico, reproductivo, social, edad, sexo y posible parentesco con el animal emisor.

Las feromonas han sido más estudiadas en insectos, como las hormigas y las abejas, que en animales superiores como los mamíferos, aunque se encuentran a todos los niveles de la jerarquía animal. Existen muchos tipos de feromonas, algunas son volátiles y cuentan con poca estabilidad y persistencia, pero tienen una mayor dispersión y un tiempo corto de acción, como las que segregan las hormigas o termitas durante un ataque a su nido. Además, existe otro tipo de feromonas que tienen poca volatilidad y una mayor estabilidad y persistencia, pero cuya dispersión es menor y con un mayor tiempo de acción, como son los hilos de plata que dejan los caracoles para poder regresar a su guarida, o las feromonas segregadas por las hormigas para guiar a las demás en la búsqueda de alimentos.

<iframe width="180"  height="120" src="https://www.youtube.com/embed/LjZd1OWKP6s" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/eVKAIufSrHs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Los siguientes pasos explican, de forma intuitiva, porqué la forma de proceder de las hormigas hace aparecer caminos de distancia mínima entre los nidos y las fuentes de comida:

1.  Una hormiga (**exploradora**) se mueve de manera aleatoria alrededor de la colonia.
2.  Si esta encuentra una fuente de comida, retorna a la colonia de manera más o menos directa, dejando tras sí un **rastro de feromonas**.
3.  Estas feromonas son atractivas, las hormigas más cercanas se verán atraídas por ellas y seguirán su pista de manera más o menos directa (lo que quiere decir que a veces pueden dejar el rastro), que les lleva a la fuente de comida encontrada por la exploradora.
4.  Al regresar a la colonia con alimentos estas hormigas depositan más feromonas, por lo que fortalecen las rutas de conexión.
5.  Si existen dos rutas para llegar a la misma fuente de alimentos, en una misma cantidad de tiempo, la ruta más corta será recorrida por más hormigas que la ruta más larga.
6.  En consecuencia, la ruta más corta aumentará en mayor proporción la cantidad de feromonas depositadas y será más atractiva para las siguientes hormigas.
7.  La ruta más larga irá desapareciendo debido a que las feromonas son volátiles (**evaporación**).
8.  Finalmente, todas las hormigas habrán determinado y escogido el **camino más corto**.

De esta forma, aunque una hormiga aislada (exploradora) se mueva esencialmente al azar, un grupo de ellas que pertenecen al mismo hormiguero decidirán sus movimientos considerando seguir con mayor frecuencia el camino con mayor cantidad de feromonas.

## Algoritmo de Optimización por Colonias de Hormigas

Los** Algoritmos de Optimización por Colonias de Hormigas (ACO) **son una metodología inspirada en el **comportamiento colectivo** de las hormigas en su búsqueda de alimentos. Veamos cómo utilizar estas características comunicativas de las colonias de hormigas para resolver un problema computacionalmente duro como es el TSP:

En la solución que presentamos aquí vamos a suponer que las $N$ ciudades están conectadas entre sí (las $N$ ciudades forman un grafo completo).

Denotaremos estas ciudades por $\{C_0,\dots,C_{N-1}\}$, y denotaremos por $d_{ij}$ la distancia (el coste de la arista) entre las ciudades $C_i$ y $C_j$. De forma explícita, las ciudades pueden verse como puntos de un espacio de 2 dimensiones, y la distancia entre ellas se calcula por medio de la distancia euclídea habitual (entre las ciudades $C_i=(x_i,y_i)$ y $C_j=(x_j,y_j)$ el resultado será $d_{ij}=\sqrt{(x_i-x_j)^2 + (y_i-y_j)^2}$).

En el caso más habitual, esta distancia es simétrica, es decir, tiene el mismo coste ir de $C_i$ a $C_j$ que de $C_j$ a $C_i$. Pero de todas formas, el algoritmo que vamos a explicar a continuación requiere muy pocas modificaciones si hay ciudades que no son accesibles desde otras, si los costes no se corresponden con las distancias euclídeas entre ellas (por ejemplo, si se considera como coste el precio del billete de tren entre las ciudades) o si dicho coste no es simétrico.

En esta solución las hormigas van construyendo soluciones al problema TSP moviéndose por el grafo de una ciudad a otra hasta que completan un ciclo. Durante cada iteración del algoritmo, cada hormiga construye su recorrido ejecutando una regla de transición probabilista que indica qué nodo debe añadir al ciclo que está construyendo. El número de iteraciones máximo que se deja correr al algoritmo depende de la decisión del usuario.

Para cada hormiga, la transición de la ciudad $i$ a la ciudad $j$ en una iteración del algoritmo depende de:

1.  **Si la ciudad ha sido ya visitada, o no, en el ciclo que está construyendo:** Cada hormiga mantiene en memoria las ciudades que ya ha visitado en el recorrido actual, y únicamente considera en cada paso las ciudades que no ha visitado todavía, que denotaremos por $J_i$. De esta forma, aseguramos que al final la hormiga ha construido un recorrido válido. (Este paso puede traer complicaciones si no todas las conexiones entre ciudades están permitidas, ya que es probable comenzar a generar un recorrido que no tiene posibilidades de ser completado; en este caso, una solución podría ser, por ejemplo, que la hormiga anula el recorrido que está construyendo y comienza un nuevo).
2.  **La inversa de la distancia a dicha ciudad, $\nu_{ij}=1/d_{ij}$, que es lo que se llama _visibilidad:_** Esta medida es una información local que mide, de alguna forma, la bondad de escoger $C_j$ estando en la $C_i$, y puede ser usada por las hormigas para que la distancia entre ciudades consecutivas sea una característica que intervenga en la selección del recorrido que está construyendo. Normalmente, esta información suele ser estática, ya que las distancias de las ciudades son invariables a lo largo de la ejecución del algoritmo, pero es fácil imaginar escenarios en los que los costes de paso de un nodo a otro del grafo sean cambiantes y el algoritmo podría aplicarse para ir obteniendo buenas soluciones en este entorno dinámico.
3.  **La cantidad de feromona que hay depositada en la arista que une ambos nodos, que denotaremos por $\tau_{ij}(t)$**: Esta cantidad se actualiza en cada paso, dependiendo de la cantidad de hormigas que han pasado por ella y de que el recorrido final de las hormigas que han usado este conexión haya sido bueno (en relación con los demás). De alguna forma, mide la **inteligencia colectiva del hormiguero**, ya que es información que depende del conjunto de hormigas que están ejecutando el algoritmo. A diferencia de la visibilidad, esta medida proporciona una información más global, ya que la feromona que tiene una arista indica lo buena que es esa arista en conjunción con otras para dar una buena solución.

Una vez consideradas las condiciones anteriores, la **probabilidad de que la hormiga $k$ vaya de $C_i$ a $C_j$ en la construcción del recorrido actual**, viene dada por una expresión del tipo siguiente:

$ p_{ij}^k(t)=\frac{[\tau_{ij}(t)]^\alpha [\nu_{ij}]^\beta}{\sum_{l\in J_i^k} [\tau_{il}(t)]^\alpha [\nu_{il}]^\beta} \mbox{, si } j\in J_i^k$

$ p_{ij}^k(t)=0 \mbox{, si } j\notin J_i^k$

Donde $\alpha$ y $\beta$ son dos parámetros ajustables que controlan el peso relativo de cada una de las medidas en la heurística resultante. Se puede observar que los valores anteriores definen una función de probabilidad en cada nodo para cada hormiga, ya que se ha normalizado para que la suma sea $1$. Además, hemos de tener en cuenta que:

*   Si $\alpha=0$, las ciudades más cercanas en cada paso son las que tienen mayor probabilidad de ser seleccionadas, lo que se correspondería con el algoritmo voraz clásico en su versión estocástica (con múltiples puntos de inicio, ya que, como veremos, las hormigas se colocan inicialmente en una ciudad al azar). En consecuencia, las hormigas no usan el conocimiento de la colonia para mejorar su comportamiento, que viene definido por la cantidad de feromona que hay en las aristas.
*   Si $\beta=0$ únicamente interviene la feromona, lo que experimentalmente se comprueba que puede llevar a recorridos no muy buenos y sin posibilidad de mejora.

Por ello, parece que puede ser interesante una estrategia intermedia que mezcle ambas posibilidades, algo que se ha comprobado experimentalmente yque da sentido al hecho de haber formado las probabilidades anteriores como una combinación de ambas técnicas.

<img src="http://www.cs.us.es/~fsancho/images/2016-11/antsystem-interface.png"/>

Con el fin de mejorar los recorridos más prometedores para el problema, tras completar un recorrido cada hormiga deposita una cantidad de feromona, $\Delta\tau_{ij}^k(t)$, en cada una de las aristas por las que ha pasado. Esta cantidad dependerá de lo bueno que hay sido ese recorrido en comparación con el del resto de las hormigas.

Por ejemplo, si la hormiga $k$ ha realizado el recorrido $T^k(t)$, de longitud total $L^k(t)$, para cada par $(i,j)\in T^k(t)$, se puede hacer un depósito de feromona de $\Delta\tau_{ij}^k(t)=Q/L^k(t)$, donde $Q$ es un parámetro del sistema (en la práctica, este parámetro se ajusta para que la influencia de ambas estrategias sea compensada).

De esta forma, recorridos más largos tendrán menos ganancia de feromona en sus aristas, lo que disminuirá su probablidad relativa de ser seleccionadas en etapas posteriores.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/4eaf1d4e-392a-11e1-bb76-001e670c2818.png"/>

Para que este método funcione correctamente es necesario además dejar que la feromona no permanezca indefinidamente, sino que su influencia decaiga en el tiempo, de manera que aquellas aristas que no vuelvan a ser visitados por las hormigas, y que por tanto no son reforzadas, tengan cada vez menos influencia en la heurística de decisión de cada paso.Esta disminución en el tiempo de la cantidad de feromona refleja un hecho que ocurre en la realidad, y es que la feromona usada en este tipo de procesos se evapora con una cierta tasa en cuanto es depositada, de forma que es útil únicamente si hay refuerzo constante en cada tramo.

Para conseguir este efecto, en los algoritmos de hormigas se introduce un nuevo parámetro, $0\leq \rho \leq 1$, junto con una regla de actualización de feromona como sigue: 

$\tau_{ij}(t) \leftarrow (1-\rho)\tau_{ij}(t) + \sum _{k=1}^m \Delta\tau_{ij}^k(t)$

y se supone que inicialmente en todas las aristas hay una cantidad pequeña de feromona, $\tau_0$.

El número total de hormigas que intervienen, que hemos denotado por $m$ en las ecuaciones anteriores, es otro parámetro importante a tener en cuenta:

*   demasiadas hormigas tenderán rápidamente a reforzar recorridos que no son óptimos de manera que sea difícil salirse de ellos y diferenciar los buenos,
*   mientras que muy pocas hormigas no provocarán el proceso de sinergia esperado debido a que no pueden contrarrestar el efecto de la evaporación de feromona, por lo que finalmente la solución que proporcionen sería equivalente al del algoritmo voraz estocástico.

Aunque no hay resultados teóricos que indiquen qué cantidad de hormigas es la óptima, una de las propuestas experimentales que más fuerza tiene es la de tomar tantas hormigas como ciudades haya, es decir, $m=N$. Lo que supone un incremento lineal de los recursos.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/b6cb1be0-3924-11e1-bb76-001e670c2818.png" width=200px />
<img src="http://www.cs.us.es/~fsancho/images/2015-07/b7efe604-3924-11e1-bb76-001e670c2818.png" width=200px />
<img src="http://www.cs.us.es/~fsancho/images/2015-07/b7624358-3924-11e1-bb76-001e670c2818.png" width=200px />

A grandes rasgos, el algoritmo que hemos seguido y que puede servir de base para resolver otros problemas similares o hacer variantes es el sigiente:

    Depositar una cantidad de feromona inicial en todas las aristas
    Crear m hormigas
    Repetir
        Reiniciar hormigas (borrar memoria)
        Cada hormiga: Construir solución usando feromonas y coste de las aristas
        Cada hormiga: Depositar feromonas en aristas de la solución
        Evaporar feromona en las aristas
    Devolver la mejor solución encontrada   

<img src="http://www.cs.us.es/~fsancho/images/2016-11/aco.png"/>

Algunas variantes para mejorar la eficiencia de este algoritmo introducen, por ejemplo:

*   **Sistema Elitista**: Añadir en cada paso feromona a las aristas del mejor recorrido encontrado hasta el momento, haya sido encontrado en el paso actual o no.
*   **Sistema por Ranking**: Es el usado en esta entrada, cada hormiga deposita feromona proporcional a la bondad de la solución encontrada.
*   **Sistema de Colonias**: Todas las hormigas dejan la misma cantidad de feromona, independientemente de la bondad de la solución, pero la ejecución no es sincronizada, sino que las hormigas que acaban antes pueden volver a comenzar una nueva generación de camino. De esta forma, los caminos más cortos, tendrán más posibilidad de ser repetidos. Es el sistema que ocurre en la naturaleza.

! ### Para saber más...
! [Sitio web de Marc Dorigo](http://iridia.ulb.ac.be/~mdorigo/HomePageDorigo/)
! [Clever Algorithms: Sistemas de Hormigas](http://www.cleveralgorithms.com/nature-inspired/swarm/ant_system.html)
! [Optimizing the Ant System](http://ai-depot.com/CollectiveIntelligence/Ant-System.html)
! [ACO](http://www.aco-metaheuristic.org/)
! [Life in Wireframe: Ant algorithms](http://lifeinwireframe.blogspot.com/2010/08/ant-algoithms.html)
! [Problema del Viajante](http://www.tsp.gatech.edu/)