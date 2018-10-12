---
title: 'Resolviendo PSR con ACO'
taxonomy:
    category: docs
visible: true
---

[TOC]
Hemos visto cómo podemos usar sistemas descentralizados basados en poblaciones para resolver problemas que son inabordables por técnicas clásicas. Por ejemplo, [los sistemas de hormigas pueden resolver problemas de optimización](http://www.cs.us.es/~fsancho/?e=71) por medio de modelos, como al ACO, que hacen uso de la estigmergia (por medio del depósito de feromonas) para que la colonia encuentre soluciones cada vez más óptimas. En concreto, se suelen usar ACOs para aproximar soluciones óptimas definidas sobre grafos (como el famoso problema del viajante, o problemas de recorrido mínimo), pero gracias a la reducción de problemas de todo tipo a problemas de optimización en grafos, es relativamente fácil conseguir buenas aproximaciones a problemas que originalmente parecen alejados de este tratamiento.

<img src="http://www.cs.us.es/~fsancho/images/2016-11/tsp1.png"/>

Como la Inteligencia Artificial tiene como objetivo la resolución inteligente y automática de problemas, estamos interesados en ver de qué forma podemos usar este tipo de metaheurísticas para resolver, no problemas individuales aislados, sino familias de problemas amplios.

Al igual que hemos visto metaheurísticas varias (como [BFS](http://www.cs.us.es/~fsancho/?e=95), [A\*](http://www.cs.us.es/~fsancho/?e=62), o [Templado Simulado](http://www.cs.us.es/~fsancho/?e=96)) para dar soluciones a familias de problemas siempre y cuando pudiéramos representarlos como Espacios de Estados, vamos a usar esta entrada para demostrar cómo podemos usar ACOs para resolver problemas genéricos, siempre y cuando seamos capaces de representarlos como Problemas de Satisfacción de Restricciones. En este sentido, será necesario asociar a cada PSR un grafo de forma que los caminos óptimos en el grafo se asocien a soluciones óptimas en el PSR.

## Problemas de Satisfacción de Restricciones

Puedes encontrar una [extensa introducción a PSR aquí](http://www.cs.us.es/~fsancho/?e=141). Recordemos que un PSR se puede formalizar como:

**Definición.** Un **problema de satisfacción de restricciones** (**PSR**) es una terna \((X,D,C)\) donde:

1.  \(X\) es un conjunto de \(n\) variables \(\{x_1 ,...,x_n \}\).
2.  \(D =\langle D_1 ,...,D_n \rangle\) es un vector de dominios (\(D_i\) es el dominio que contiene todos los posibles valores que puede tomar la variable \(x_i\)).
3.  \(C\) es un conjunto finito de restricciones. Cada restricción está definida sobre un conjunto de \(k\) variables por medio de un predicado que restringe los valores que las variables pueden tomar simultáneamente.

<img  src="http://www.cs.us.es/~fsancho/images/2016-09/slide_4.jpg" width=500px/>

**Definición.** Una **asignación de variables**, \((x,a)\) es un par variable-valor que representa la asignación del valor \(a\) a la variable \(x\). Una asignación de un conjunto de variables es una tupla de pares ordenados, \(((x_1 ,a_1 ),...,(x_i ,a_i ))\), donde cada par ordenado \((x_i,a_i)\) asigna el valor \(a_i\) a la variable \(x_i\). Una tupla se dice **localmente consistente** si satisface todas las restricciones formadas por variables de la tupla.

**Definición.** Una **solución a un PSR** es una asignación de valores a todas las variables de forma que se satisfagan todas las restricciones. Es decir, una solución es una tupla consistente que contiene todas las variables del problema. Una **solución parcial** es una tupla consistente que contiene algunas de las variables del problema. Diremos que un **problema es consistente**, si existe al menos una solución.

## Grafo asociado a un PSR

Aunque la solución no es única, daremos y justificaremos un procedimiento para asociar un grafo a un PSR general que viene dado siguiendo la definición anterior.

Para ello, consideraremos un grafo $G=(V,E)$, donde:

$V=X \cup \bigcup_{i=1}^n D_i$

es decir, los nodos del grafo van a venir dados por el conjunto de las variables asociadas al PSR junto con todos los posibles valores que pueden tomar.

A continuación hemos de dar las aristas de $G$, junto con los pesos asociados, que serán las que indiquen si la solución óptima (respecto del peso asociado) dada por las hormigas es óptima cuando se interpreta como solución para el PSR.

El conjunto de aristas dirigidas de $G$ lo dividiremos en dos subconjuntos de aristas, cada uno de los cuales jugará un papel distinto en la estrategia de resolución del PSR asociado (y que especificaremos después):

$E=E_1\cup E_2$

donde:

$E_1=\{\{x_i\}\times D_i:\ x_i\in X\}$

$E_2=(\bigcup_{i=1}^n D_i)\times X$

Es decir, las aristas de $E_1$ conectan las variables con los posibles valores que pueden tomar (los elementos de su dominio), mientras que las aristas de $E_2$ conectan todos los valores de todos los dominios de nuevo con todas las variables del problema.

<img  src="http://www.cs.us.es/~fsancho/images/2017-11/psr-aco.jpg" width=500px />

**Nota:** Observa que en la figura anterior se han añadido nodos auxiliares (en color amarillo) para facilitar la representación de las aristas de $E_2$.

Recordemos que para obtener una solución del PSR primero necesitamos obtener una asignación válida de valores a las variables. Así pues, caminos (con algunas restricciones) que recorren el grafo anterior se podrán interpretar como asignaciones de variables de la forma siguiente:

Si $(x,v)\in E_1$ está en el camino, entonces consideramos la asignación que asocia a la variable $x$ el valor $v$. Las aristas del camino que pertenecen a $E_2$ solo sirven para poder repetir el proceso de asignación y así completar la asignación en curso.

Obviamente, hemos de controlar algunas cosas básicas como, por ejemplo, que no se asignen dos valores a una misma variable, por lo que, al igual que se hace con [la solución a TSP por medio de hormigas](http://www.cs.us.es/~fsancho/?e=71), una vez visitado un nodo asociado a una variable (y que no debemos volver a visitar), la probabilidad asignada a las aristas de $E_2$ que llegan a esa variable es nula (y, en consecuencia, no volverán a ser elegidas en el mismo camino). El camino se considerará completado cuando la asignación se haya completado (o, lo que es lo mismo, la hormiga no pueda continuar porque no tiene ninguna arista que elegir con probabilidad positiva).

Hasta aquí conseguimos que los caminos se interpreten como asignaciones válidas, pero hasta ahora no hemos introducido ninguna característica para que la colonia de hormigas pueda optimizar estos caminos en función de si la asignación asociada es solución del PSR o no. A continuación vamos a usar los pesos asignados a las aristas y la función de probabilidad asociada a cada nodo (y que ayuda a elegir la arista saliente) para que estas asignaciones sean más eficientes con respecto al PSR.

## Estrategias de Selección

<img style="float:right;margin:0 10px 10px 0;width:200px" src="http://www.cs.us.es/~fsancho/images/2017-11/selection_1.jpg"/> Al proceso de seleccionar una arista de $E_2$ se le denomina "**Selección de variable**", ya que es el paso en el cual la asignación crece eligiendo qué variable será la siguiente a ser asignada. Aunque al final hay que elegir todas las variables, se puede comprobar que una heurística de selección de variables adecuada puede acelerar considerablemente la convergencia de las soluciones generadas por la colonia a una solución óptima, ya que generalmente una restricción solo puede ser comprobada cuando todas las variables que intervienen han sido asignadas.

En el caso general que nos ocupa no se sabe qué asignación de pesos y probabilidades puede ser la más adecuada, pero sí se sabe que una buena solución se puede conseguir si se elige un orden adecuado de preferencia de probabilidades, por ejemplo:

*   aquellas variables (no usadas) que intervienen en mayor número de restricciones, o
*   aquellas que están conectadas por medio de restricciones con un mayor número de variables ya asignadas, o
*   aquellas que están conectadas por medio de restricciones con un maypr número de variables no asignadas, o
*   aquellas que tienen el menor número de valores consistentes con la asignación parcial que se está construyendo, o
*   una asignación al azar (todas las variables no usadas tienen la misma probabilidad de ser elegidas).

Al proceso de seleccionar una arista de $E_1$ se le denomina "**Selección de valor**", y el objetivo es seleccionar al valor más prometedor para la variable actual (si es de $E_1$ estamos situados en un nodo de variable y vamos a asignarle un valor válido). Los criterios pueden ser parecidos a la selección anterior, ya que su probabilidad de selección tendrá que considerar el número de conflictos que genera o resuelve esta asignación. 

Al igual que como se hacía en el caso del TSP, una hormiga situada en un nodo de variable, $x_i$, puede seleccionar la arista a continuar de acuerdo a una probabilidad asignada a todas sus aristas salientes como:

$p((x_i,v))=\frac{\tau((x_i,v))^\alpha \eta((x_i,v))^\beta}{\sum_{w\in D_i} \tau((x_i,w))^\alpha \eta((x_i,w))^\beta}$

donde $\alpha$ y $\beta$ determina el peso relativo que le damos a la memoria colectiva (que está reflejada por el valor de la feromona, $\tau$) frente a la heurística de selección del valor que consideremos (que está reflejada por $\eta$).

El valor de $\eta$, que depende de las asignaciones anteriores, se podría dar como:

$\eta((x_i,v))=\frac{1}{1 + cost(mem\cup (x_i,v))-cost(mem)}$

donde $mem$ es la memoria de la hormiga (es decir, las asignaciones previas que ha realizado) y $cost$ calcula el peso de las violaciones a restricciones que se realizan (por lo que $\eta$ depende de cuántas nuevas violaciones introduce la elección de $v$ para la variable $x_i$).

La principal diferencia con el algoritmo ACO visto para TSP radica en que la feromona y el valor de la heurística no dependen únicamente de una relación local existente entre el posible nuevo vértice (valor) a visitar, sino de una relación global entre este posible valor y el camino completo seguido por la hormiga (es decir, de las asignaciones anteriores).

Ha de tenerse en cuenta que este problema es quizás más importante que el anterior, ya que, aunque hemos de pasar por todas las variables para conseguir una asignación completa, no estamos seguros de que un valor en concreto deba ser elegido para construir una solución, y no se pueden prever las consecuencias que tendrá una elección para las futuras decisiones y la dificultad de verificar las restricciones del problema.

Es precisamente en este punto en el que la optimización distribuida que consigue la colonia puede aportar un mayor valor añadido, ya que los sistemas de hormigas proporcionan una heurística general para la resolución de cualquier problema que puede ser representado como un PSR, cuando en los casos usuales con otras metodologías esta heurística depende completamente del problema concreto (por lo que difícilmente pueden servir de base para un sistema de inteligencia artificial autónomo).

## Depósito de Feromona

<img style="float:right;margin:0 10px 10px 0;width:400px" src="http://www.cs.us.es/~fsancho/images/2017-11/hormigas.jpg"/> Una vez que una hormiga ha conseguido construir con éxito una asignación completa ha de depositar feromona en el camino conseguido para marcar la solución encontrada para las demás hormigas. Para ello, basta que deje una cantidad de feromona proporcional a la bondad de la asignación encontrada, lo que en nuestro caso podría significar, por ejemplo, inversamente proporcional al número de restricciones no satisfechas (también podemos medir cómo de satisfecha es cada restricción con un peso según el error cometido, y se considera el error global como la suma ponderada de los errores de cada restricción). Si la asignación representa una solución completa, entonces la cantidad de feromona será máxima.

Usando la notación anterior, el incremento de feromona que realiza una hormiga tras haber acabado su recorrido (ya no le quedan más asignaciones que realizar) se calcula como inversamente proporcional al coste de la asignación conseguida:

$\Delta \tau =\frac{1}{cost(mem)}$

que distribuirá uniformemente entre las aristas de su camino, y que sufrirá posteriormente el proceso habitual de evaporación usual en este tipo de modelos.

Además, para asegurar que las hormigas siempre exploran nuevas opciones, es habitual establecer unos valores mínimos y máximos de feromona, $0 < \tau_{min} < \tau_{max}$, que acotan los posibles valores de feromona depositada en las aristas del grafo (esta decisión no depende de estar resolviendo un PSR, y puede ser aplicado de forma general a cualquier solución que haga uso de hormigas).

Tras este paso, las nuevas hormigas que recorran el grafo anterior seleccionarán el siguiente nodo (sea de variable, o de valor) por medio de una probabilidad que pondere la cantidad de fermona junto con los pesos asignados a cada  arista siguiendo los procedimientos de selección explicados en el apartado anterior.

Además, los procedimientos aquí diseñados permiten dar soluciones "suficientemente" buenas aún cuando no exista una solución óptima ya que, si se penalizan adecuadamente las violaciones de las restricciones, la colonia proporcionará en este caso una asignación que minimizará estas violaciones... o lo que es lo mismo, una de las soluciones _menos malas_ en ausencia de una óptima.