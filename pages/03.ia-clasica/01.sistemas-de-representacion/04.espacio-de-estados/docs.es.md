---
title: 'Espacio de Estados'
taxonomy:
    category: docs
visible: true
---

[TOC]
<img src="http://www.cs.us.es/~fsancho/images/2015-07/c6f563de-154e-11e2-bb76-001e670c2818.jpg"> 
Sin lugar a dudas, una de las principales características que reconocemos en la inteligencia es la capacidad para resolver problemas. Si consideramos una inteligencia como la humana, a la habilidad para analizar los elementos intrínsecos de cada problema, que está presente también en muchas otras especies animales, se añade la **capacidad de abstraerlos e identificar las acciones que se pueden realizar** sobre ellos para resolver el problema. En un nivel incluso superior de abstracción, reconocible solo en las llamadas especies superiores, podemos considerar también la capacidad de determinar cuál puede ser, de entre los posibles métodos que se idean, el más adecuado, ya sea en términos de tiempo, de recursos, de seguridad para el individuo, etc. De esta forma, aparece una triple capacidad de **análisis**, **abstracción** y **estrategia** que sitúa el tema general de la resolución de problemas en el núcleo de la inteligencia artificial y, por ello, no resulta extraño que se consideren deseables para cualquier individuo, artificial o no, que queramos que se comporte inteligentemente.

Podemos pensar en una variedad de problemas que van desde cómo alcanzar una fuente de comida situada a cierta distancia y a la que no se puede ir directamente, hasta cómo resolver un pequeño juego como podría ser el famoso cubo de Rubik, o resolver el problema matemático de encontrar la solución a una ecuación numérica. En todos ellos encontramos elementos comunes tras un proceso de abstracción que nos permiten de forma general definir la **resolución de problemas** como: 

> _el proceso que, partiendo de una situación inicial y utilizando un conjunto de procedimientos/reglas/acciones seleccionados a priori, es capaz de explicitar el conjunto de pasos que nos llevan a una situación posterior que llamamos **solución**_.

Lo que consideremos o no solución dependerá del contexto concreto del problema, y puede ser, por ejemplo, el conjunto de acciones que nos llevan a cumplir cierta propiedad, conseguir cierto objetivo, o verificar ciertas restricciones.

Como estamos interesados en la generación de mecanismos automáticos que se puedan llamar inteligentes, no nos contentamos con resolver problemas individuales y dar para cada problema una solución independiente, sino que intentaremos buscar elementos comunes a una gran bolsa de problemas que faciliten dar una clasificación de los mismos y reconocer métodos y estrategias que puedan ser válidos de la forma más general posible.

Para ello, y teniendo en cuenta lo la idea de **modelar**, es necesario que podamos expresar las características de los problemas usando un lenguaje formal común a todos ellos, para posteriormente proporcionar métodos y estrategias generales (en forma de algoritmos o de heurísticas, en nuestro caso) con los que poder obtener con ciertas garantías soluciones de esos problemas.

<img src="http://www.cs.us.es/~fsancho/images/2017-09/kr-entc.gif">

Una de las aproximaciones más generales y sencillas de formalizar un problema y sus posibles mecanismos de solución es por medio de lo que se denomina **espacio de estados**. Antes de definir formalmente en qué consiste este espacio, observemos que en todo momento estamos tratando con métodos en los que la resolución de los problemas se dan de forma dinámica, es decir, se supone que se produce una evolución temporal, que pasa por etapas, que nos permite llegar de la situación inicial en la que el problema se presenta hasta una situación final en la que se ha encontrado la solución del mismo. Es precisamente esta dinámica, en la que aplicamos las reglas u operaciones de las que disponemos, la que permite ir modificando cada situación posible para llevarnos desde el inicio a la solución. Simplemente, denominaremos **estado** a la _representación de los elementos que describen el problema en un momento dado_, es decir, a la situación en que se encuentra o se podría encontrar el problema en cada instante de tiempo.

> **Estado**: _representación de los elementos que describen el problema en un momento dado._

La cuestión principal que debemos plantearnos para esta metodología es acerca de qué debemos incluir en el estado. Por desgracia, no existen directrices generales que permitan dar una respuesta satisfactoria a esta cuestión pero, siguiendo técnicas de resolución de problemas clásicas, podemos asegurar que es importante guardar un equilibrio entre el ahorro de recursos de almacenamiento para la descripción del estado y la necesidad de tener suficiente información almacenada como para poder resolver el problema. Aunque a priori puede parecer una buena idea almacenar toda la información posible, pronto veremos que en problemas relativamente pequeños la cantidad de estados puede ser tan grande que la capacidad de almacenamiento computacional se nos puede agotar sin darnos la opción de resolver el problema. Vemos, pues, que este enfoque entronca directamente con teorías matemáticas bien establecidas, como son la **Teoría de la Computabilidad** (que estudia qué es resoluble de forma automática) y la **Teoría de la Complejidad** (que estudia cuántos recursos necesitamos para resolver los problemas que sí son resolubles).

! Debe existir un equilibrio entre el ahorro de recursos de almacenamiento para la descripción del estado y la necesidad de tener suficiente información almacenada como para poder resolver el problema

Este proceso de elegir adecuadamente la información que almacenamos en un estado es tan importante que se ha convertido en un eje central de la Inteligencia Artificial, recibiendo el nombre de [**Teoría de la Representación**](http://www.cs.us.es/~fsancho/?e=172), y ha demostrado ser esencial para que algoritmos y heurísticas concretas de resolución sean o no eficientes a la hora de resolver problemas. Un buen algoritmo con una mala representación puede ser tan ineficiente como un mal algoritmo y, muchas veces, una buena representación es capaz de llevarnos a una solución del problema incluso usando algoritmos malos.

**La elección de los estados**, como veremos más adelante en casos concretos, **no solo determina qué información se almacenará de las diversas situaciones por las que pasa el problema, sino que en muchos casos es determinante también para decidir cuáles son las reglas u operaciones básicas que se permiten para realizar transformaciones entre estados**. Otras veces también podemos encontrar restricciones debido a la incapacidad para realizar ciertas acciones para resolver un problema, lo que puede influir en cómo se elegirán los estados para hacerlos coherentes con las operaciones disponibles. En general, el proceso de transformar el problema original (al que muchas veces llamaremos simplemente "mundo real") en este espacio de estados que es manipulable por medios automáticos es lo que conocemos como **modelar el problema** (debe tenerse en cuenta que el modelado existe en otras muchas ramas de la ciencia, y nosotros aquí solo consideramos el modelado computacional, que es un tipo particular de modelado matemático).

! Modelar computacional de un problema: proceso de transformar el problema original ("mundo real") en un espacio de estados que es manipulable por medios automáticos.

## Problema de búsqueda básico
<img style="float:left;margin:0 10px 10px 0;width:300px" src="http://www.cs.us.es/~fsancho/images/2016-11/GraphStateSpace.png" /> Si nos imaginamos este espacio de estados como un terreno por el cual nos podemos mover, donde partimos de un punto concreto del terreno (**estado inicial**) y podemos aplicar las reglas válidas para ir saltando de un estado a otro, podemos identificar la resolución del problema (llegar hasta un **estado final** válido) con el problema de **buscar un camino** adecuado entre un estado inicial y un estado final. Es por ello que muy habitualmente se habla del **Problema de Búsqueda en el Espacio de Estados**. Pasemos pues a dar una definición formal de esta idea: 

Un **problema de búqueda básico** es una 4-tupla \((X,S,G,d)\), donde 

*   \(X\) es un **conjunto de estados** (el que hemos estado llamando **Espacio de Estados**).
*   \(S \subseteq X\), es un conjunto no vacío de **estados iniciales** (no tiene porqué existir un solo estado de partida).
*   \(G \subseteq X\), es un conjunto no vacío de **estados finales** (\(G\) se usa como inicial de Goals, objetivos en inglés, y al igual que no existe un único estado de partida, puede ocurrir que haya muchos estados finales válidos para el mismo problema).
*   \(d: X \rightarrow \cal{P}(X)\) es una **función de transición**. Para cada \(x\in X\), \(d(x)\) determina el conjunto de estados sucesores de \(x\) (\(\cal{P}(X)\) representa las partes de \(X\), es decir, el conjunto de los posibles subconjuntos de \(X\), ya que desde un estado concreto podemos llegar a varios posibles estados aplicando distintas operaciones o reglas permitidas).

Observa que esta definición formal no explicita ni la forma en que hay que almacenar la información en los estados ni cuáles son las reglas válidas que permiten pasar de un estado a otro durante la resolución, ya que todo ello depende del problema concreto que se esté resolviendo y nosotros estamos interesados en dar un marco general que permita aplicar los métodos que desarrollemos al mayor conjunto posible de problemas. 

Una vez fijado este primer marco de representación, podemos dar los pasos generales necesarios para "buscar" el camino que lleve desde el planteamiento inicial del problema hasta una solución:

1.  **Dar una representación del problema**, es decir, definir un **espacio de estados** que refleje las características del mundo real que sean necesarias para la resolución del problema. Como ya se ha indicado, ha de tenerse en cuenta que esta elección no es única, y que determinará en gran medida la facilidad o dificultad de resolver el problema que tenemos entre manos. Asimismo, este paso determina también las acciones disponibles para moverse por este espacio. La capacidad para cambiar de representación para obtener una más adecuada a la solución del problema es lo que se denomina **perspicacia**.
2.  Especificar uno, o más, **estados iniciales**.
3.  Especificar uno, o más **estados finales** (objetivos o metas). A veces no se especifican propiamente los estados finales, sino alguna propiedad que han de cumplir para que se consideren válidos.
4.  Definir **reglas** a partir de las acciones disponibles. El conjunto de reglas definirá la función de transición del sistema formal. Estas reglas determinan la estructura del espacio de estados, y esta estructura es responsable, en gran medida de la dificultad que nos encontremos posteriormente para realizar búsquedas en el espacio.
5.  El problema se resuelve **usando las reglas en combinación con una estrategia de control**. De nuevo, obsérvese que aquí no prefijamos ninguna estrategia de control específica. Más adelante veremos algunas de las más habituales y estudiaremos sus bondades e inconvenientes para resolver problemas de forma general. Una buena estrategia de control debe establecer el **orden de aplicación de las reglas** y **resuelve los posibles conflictos** que puedan aparecer.
6.  Dependiendo de la estrategia de control utilizada, o de las necesidades de la búsqueda, puede ser necesaria una **función de coste** que indique cuánto cuesta aplicar una regla determinada a un estado determinado, de esa forma podemos calcular cuánto cuesta el proceso total de ir desde un estado inicial hasta un estado final aplicando dicha estrategia, y de esta forma comparar entre sí los distintos caminos que existen para resolver el problema.

### Ejemplo
!! Como primer ejemplo, consideremos el **puzle de piezas deslizantes**, donde el objetivo es deslizar las piezas usando el hueco hasta conseguir el orden deseado. El caso general consiste en un puzzle de \(n\times m\) cuadrículas, con \(n\times m-1\) piezas numeradas consecutivamente y 1 hueco. A veces podemos encontrar este puzle en una variante equivalente haciendo uso de imágenes que han de reconstruirse situando el orden adecuado en sus piezas.
!! <img src="http://www.cs.us.es/~fsancho/images/2015-07/a1c910b4-1527-11e2-bb76-001e670c2818.jpg">
!! El espacio de estados, \(X\), describe todas las posibles combinaciones de las piezas y el hueco. Como queremos dar un método general de resolución, el conjunto de los estados iniciales es, en este caso, todo el espacio \(S=X\), y el conjunto de estados finales es únicamente uno, el estado en el que todos están en orden y el hueco se sitúa al final, tal y como muestra la figura anterior. La función de transición describe el cambio que resulta de mover, en un estado concreto, el hueco en cualquiera de las 4 direcciones (en los bordes y esquinas sólo podrá moverse en 3 o 2 direcciones posibles, respectivamente).
!! Obsérvese que, en este caso, la solución al puzle no es el estado final, que sabemos exactamente cuál es, sino el camino que lleva desde un estado inicial (prefijado, o aleatorio) hasta ese estado final. Es decir, deseamos conocer la sucesión de movimientos que nos permiten resolver el puzle.
!! <img src="http://www.cs.us.es/~fsancho/images/2015-07/23717796-1528-11e2-bb76-001e670c2818.jpg">
!! En el caso de un puzle de tamaño \(3\times 3\) (en este caso el puzle se conoce como **8-puzle**, que es el número de piezas móviles) el número de posibles estados es de \(9!= 362880\), un tamaño que permite, con la capacidad de los ordenadores actuales, hacer una búsqueda exhaustiva para encontrar el camino desde cualquier estado al estado final ordenado. Esta búsqueda exhaustiva se consigue comenzando por el estado inicial e ir visitando a partir de él todos los demás estados por la aplicación sucesiva de las reglas de transición, de esta forma, si existe una solución (un camino que conecta el estado inicial y el final) este método la encontrará, aunque, posiblemente, de una forma completamente ineficiente.
!! Si jugamos con el puzle de tamaño \(4\times 4\) (que se conoce como **15-puzle**) el número de posibles estados es de \(16! \approx 2x10^{13}\), demasiado grande para una búsqueda exhaustiva. En casos como éste, donde el espacio de estados es excesivamente grande para hacer un recorrido exhaustivo de sus elementos, hemos de encontrar estrategias de búsqueda más depuradas que nos permitan alcanzar las soluciones de forma más eficiente y usando menos recursos (en tiempo y en espacio almacenado).

!! Consideremos otro puzle habitual, **el puzle de los misioneros y caníbales**: Tres misioneros se perdieron explorando una jungla. Separados de sus compañeros, sin alimento y sin radio, sólo sabían que para llegar a su destino debían ir siempre hacia adelante. Los tres misioneros se detuvieron frente a un río que les bloqueaba el paso, preguntándose que podían hacer. De repente, aparecieron tres caníbales llevando un bote, pues también ellos querían cruzar el río. Ya anteriormente se habían encontrado grupos de misioneros y caníbales, y cada uno respetaba a los otros, pero sin confiar entre ellos. Los caníbales se comían a los misioneros cuando les superaban en número, y los misioneros bautizaban a los caníbales en situaciones similares. Todos querían cruzar el río, pero el bote no podía llevar más de dos personas a la vez y los misioneros no querían que los caníbales les aventajaran en número. ¿Cómo puede resolverse el problema, sin que en ningún momento hayan más caníbales que misioneros en cualquier orilla del río?
!! El espacio de estados asociado al problema podría representarse de la siguiente forma (muy descriptiva, pero poco práctica desde el punto de vista computacional):
!! <img src="http://www.cs.us.es/~fsancho/images/2017-09/mc-search-space.png">

!!! **Ejercicio**: Formaliza la siguiente versión del puzle "_Todos los dígitos del Rey_" explicitando una representación de sus estados y la función de transición entre ellos: Dado el conjunto de dígitos \(0123456789\), inserta los símbolos de los operadores aritméticos (\(\times + - /,\)) entre ellos para que la expresión resultante se evalúe como 100. Por ejemplo:
!!  $0+1+2+3+4+5+6+7+(8\times 9) =100$
!! ¿Puedes encontrar otros?




## Criterios de evaluación

Antes de que pasemos a ver la variedad de algoritmos (estrategias) que han sido diseñados para resolver problemas de búsqueda en espacios de estados, puede merecer la pena mencionar, aunque sea de forma breve, cómo podemos evaluar la eficiencia de estos algoritmos. Habitualmente, se suelen usar los siguientes criterios de evaluación: 

*   **Complejidad en tiempo**: Se puede medir como el número de veces que se aplica la función de transición que necesita el algoritmo para encontrar la solución. En un contexto más amplio suele medirse por medio del número de pasos que da un algoritmo en su ejecución.
*   **Complejidad en espacio**: Se mide por la cantidad de espacio de almacenamiento necesario para encontrar la solución. En el caso que estamos viendo lo podemos medir como el número de estados que el algoritmo debe mantener en memoria para encontrar la solución. Algunos algoritmos podrán "olvidar" los estados por los que van pasando, mientras que otros necesitan mantener una memoria con esos estados para poder volver atrás en la búsqueda o saber por cuáles ha pasado.
*   **Completitud**: Si existe una solución, ¿está garantizado por el algoritmo que la encontraremos?
*   **Optimalidad**: Si existen varias soluciones, ¿encuentra el algoritmo la óptima? Esta optimalidad se mide respecto de alguna medida, por ejemplo, la que está más cerca en número de transformaciones para llegar desde el estado inicial, o la que ha usado menos memoria.

## Una representación (casi) universal

Normalmente, los algoritmos que vamos a ver se basan en la suposición de que el espacio de búsqueda tiene la estructura de un grafo dirigido: cada **nodo** del grafo representa uno de los estados del espacio, y dos nodos están conectados si existe una forma de ir de uno al otro por medio de la función de transición.

Normalmente, cuando resolvemos el problema a partir de un estado particular, podemos construir un árbol que se construye partiendo del estado inicial y donde en cada nivel se añaden los estados que se pueden alcanzar desde los estados del nivel anterior (y que, en consecuencia, puede contener estados repetidos). En este caso, la **profundidad** (\(d\), de **depth**) del árbol es la longitud máxima de los caminos que se pueden construir desde cualquier nodo a la raíz; y el **factor de ramificación** (\(b\), de **branch**) del árbol es el máximo número de sucesores que puede tener un nodo del árbol.

En un árbol, los sucesores inmediatos de un nodo (salvo las hojas, claro, que son los nodos terminales) se llaman **hijos**, el predecesor de un nodo (salvo la raíz, que no tiene predecesor), que es único, se llama **padre**, y los nodos que tienen el padre común se llaman **hermanos**.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/96a74992-1529-11e2-bb76-001e670c2818.png">

Es importante destacar que nuestro espacio de estados **NO** es un árbol, sino que el árbol se consigue al considerar la estructura ordenada que surge entre los diversos estados de nuestro problema al aplicar las reglas que permiten pasar de unos estados a otros. Si cambiamos la representación de los estados (y en consecuencia las reglas que se pueden aplicar) cambiará el árbol asociado, pero nuestro problema sigue siendo el mismo. Es por ello que la representación es fundamental para obtener soluciones más o menos eficientes, ya que los posibles caminos entre los nodos que representan estados iniciales y los nodos que representan estados finales pueden cambiar completamente dependiendo del árbol que obtengamos.

! ## Para saber más...
! 
! [Tema 3 de la asignatura de IA del Grado en Ingeniería en Informática - Tecnologías Informáticas](http://www.cs.us.es/cursos/iati/temas/tema-03.pdf)
! [Tema 3 Artificial Intellicenge and its teaching](http://aries.ektf.hu/~gkusper/ArtificialIntelligence_LectureNotes.v.1.0.4.pdf )
! [Tema 3 Artificial Intellicenge. Foundations of Computational Agents](http://artint.info/html/ArtInt_46.html)