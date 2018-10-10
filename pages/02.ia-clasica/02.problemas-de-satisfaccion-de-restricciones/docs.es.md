---
title: 'Problemas de Satisfacción de Restricciones'
taxonomy:
    category: docs
visible: true
---

_Basado en "[Introducción a la Programación de Restricciones](http://users.dsic.upv.es/~msalido/papers/aepia-introduccion.pdf)", de Federico Barber y Miguel A. Salido (Departamento de Sistemas Informáticos y Computación de la Universidad Politécnica de Valencia, España)_
[TOC]
## Introducción

En muchas ocasiones la resolución de problemas está sujeta a que las diversas componentes en las que se pueden descomponer verifiquen ciertos conjuntos de restricciones. Problemas tan cotidianos como fijar una cita con unos amigos, comprar un coche o preparar una receta culinaria pueden depender de muchos aspectos interdependientes, e incluso conflictivos, sujetos a un conjunto de **restricciones** que deben ser verificadas para poder encontrar una solución al problema planteado.

Históricamente, la resolución de **problemas de satisfacción de restricciones** (**PSR**, por sus siglas en español) ha generado una gran expectación entre expertos de muchas áreas debido a su potencial para la resolución de grandes problemas reales que caen, en muchas ocasiones, dentro de lo que se conocen como problemas **NP** (aquellos que presentan una complejidad computacional superior para su resolución). Los primeros trabajos relacionados con la programación de restricciones datan de los años 60 y 70 en el campo de la Inteligencia Artificial.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/constraint-satisfaction-problems-n.jpg">

La idea de las técnicas de PSR es resolver problemas mediante la declaración de restricciones sobre el área del problema (el espacio de posibles soluciones) y consecuentemente encontrar soluciones que satisfagan todas las restricciones. A veces, se buscan soluciones que, además, optimicen algunos criterios determinados.

La resolución de problemas con restricciones puede dividirse en dos ramas claramente diferenciadas: la **satisfacción de restricciones** y la **resolución de restricciones**. Ambas comparten la misma terminología pero sus orígenes y técnicas de resolución son diferentes: la satisfacción de restricciones trata con problemas con dominios finitos, mientras que la resolución de restricciones está orientada principalmente a problemas sobre dominios infinitos o dominios más complejos. 

Aquí nos centraremos principalmente en los problemas de satisfacción de restricciones, que básicamente consisten en un conjunto finito de variables, un dominio de valores finito para cada variable y un conjunto de restricciones que acotan las posibles combinaciones de valores que estas variables pueden tomar en su dominio.

**Ejemplo.** El **problema de coloración de mapas** es un problema clásico que se puede formular como un PSR. En este problema hay un conjunto de colores y un mapa dividido en regiones. El objetivo es colorear cada región del mapa de manera que regiones adyacentes tengan distintos colores. Una forma de modelar este problema dentro del PSR sería asociando una variable por cada región del mapa (el dominio de cada variable es el conjunto de posibles colores disponibles), y para cada par de regiones contiguas añadir una restricción sobre los valores de las variables correspondientes que impida asignarles el mismo valor (color). Como suele ser habitual, este mapa puede ser representado mediante un grafo donde los nodos representan las diversas regiones del mapa y cada par de regiones adyacentes están unidas por una arista. Veremos que esta representación en forma de grafo, que en este problema es natural, será usada como metodología general para dar una estructura a las restricciones de cualquier problema PSR.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/screen-shot-2013-05-20-at-3.57.27-pm.png">

## Resolución del PSR

La resolución de un PSR consta de dos fases, que son:

1.  **Modelar el problema como un problema de satisfacción de restricciones**. Para ello, y siguiendo una metodología similar al ejemplo anterior, el problema se expresa mediante un conjunto de variables, dominios en los que toman los posibles valores, y restricciones sobre estas variables.
2.  **Procesar las restricciones**. Una vez formulado el problema como un PSR, hay dos maneras de procesar las restricciones:
    *   **Técnicas de consistencia**: basadas en la eliminación de valores inconsistentes de los dominios de las variables (es decir, que no verifican las restricciones impuestas). A veces se pueden aplicar aquí técnicas derivadas de la [Lógica Proposicional](http://www.cs.us.es/~fsancho/?e=120) (o de primer orden).
    *   **Algoritmos de búsqueda**: se basan en la exploración sistemática del espacio de soluciones hasta encontrar una solución (o probar que no existe tal solución en caso contrario) que verifica todas las restricciones del problema.

Lo más normal es que se combinen ambas aproximaciones, ya que las técnicas de consistencia permiten deducir información del problema, y reducen el espacio de soluciones que podemos explorar usando algoritmos de búsqueda más o menos tradicionales.

## Modelización del PSR

Como hemos señalado anteriormente, una parte muy importante para la resolución de problemas por medio de las técnicas que aquí vamos a ver es el modelado del problema en términos de **variables**, **dominios** y **restricciones**.

Como intentar dar una formalización completa de este proceso puede ser un poco engorroso, y sin embargo es bastante natural el proceso que se lleva a cabo, vamos a presentar esta etapa de modelado por medio de un ejemplo en el que se mostrarán diversas modelizaciones de un mismo problema y se pondrán de manifiesto las ventajas de una modelización adecuada para resolverlo.

Consideremos el conocido **problema criptoaritmético ’send+more=money’** utilizado en \[21\]. Este problema puede ser declarado como: asignar a cada letra \\(\\{s, e, n, d, m, o, r, y\\}\\) un dígito diferente del conjunto \\(\\{0,...,9\\}\\) de forma que se satisfaga la expresión \\(send+more=money\\).

<img src="http://www.cs.us.es/~fsancho/images/2016-09/sendmoremoney.jpg">

La manera más directa de modelar este problema es asignando una variable a cada una de las letras (que vendrán representadas por las mismas letras), todas ellas tomando valores en el dominio \\(\\{0,...,9\\}\\) y con las restricciones de:

1.  Todas las variables toman valores distintos, y
2.  Se satisface \\(send+more=money\\).

De esta forma, podemos escribir las restricciones como:

\\(10^3 (s+m)+10^2 (e+o)+10(n+r)+d+e = 10^4 m + 10^3 o + 10^2 n + 10e + y\\)

\\(s\\neq e,\\ s\\neq n,\\ ...,\\ r\\neq y\\)

Esta representación del problema es correcta, pero no es muy útil, ya que la primera de las restricciones exige manipular todas las variables simultáneamente y no facilita recorrer el espacio combinatorio de valores de una forma cómoda (ten en cuenta siempre que, finalmente, vamos a recorrer este espacio de combinaciones de valores como un espacio de estados). Por lo que, al no disponer de restricciones locales entre las variables, no podemos podar el espacio de búsqueda para agilizar la búsqueda de soluciones.

Vamos a dar otro modelado similar pero más eficiente para resolver el problema, que consiste en decomponer esta restricción global en restricciones más pequeñas haciendo uso de las relaciones que se producen entre los dígitos que ocupan la misma posición en una suma. Para ello, introducimos los **dígitos de acarreo** para descomponer la ecuación anterior en una colección de pequeñas restricciones.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/acarreo.png">

  
Tal y como está planteado el problema, \\(m\\) debe de tomar el valor \\(1\\) (ya que es el acarreo de 2 cifras que como mucho pueden sumar \\(18\\), más un posible acarreo previo de una unidad, lo que limita el resultado a \\(19\\)) y por lo tanto \\(s\\) solamente puede tomar valores de \\(\\{1,...,9\\}\\) (si \\(s=0\\) entonces no podría haber acarreo). Además de las variables del modelo anterior, el nuevo modelo incluye tres variables adicionales, \\(c\_1\\), \\(c\_2\\), \\(c\_3\\) que sirven como dígitos de acarreo. Aunque introducimos nuevas variables, por lo que el espacio de búsqueda se amplia, éstas nos permitirán simplificar las restricciones y facilitar su exploración de forma considerable. En consecuencia, el dominio de \\(s\\) es \\(\\{1,...,9\\}\\), el dominio de \\(m\\) es \\(\\{1\\}\\), el dominio de los dígitos de acarreo es \\(\\{0,1\\}\\), y el dominio del resto de variables es \\(\\{0,...,9\\}\\).

Con la ayuda de los dígitos de acarreo la restricción de la ecuación anterior puede descomponerse en varias restricciones más pequeñas (junto con las restricciones que indican que todas las variables originales son distintas entre sí):

\\(e + d = y + 10c\_1\\)  
\\(c\_1 + n + r = e + 10c\_2\\)  
\\(c\_2 + e + o = n + 10c\_3\\)  
\\(c\_3 + s + m = 10m + o\\)

Esta nueva representación presenta la ventaja de que las restricciones más pequeñas pueden comprobarse durante la búsqueda de una forma más sencilla y local, permitiendo podar más inconsistencias y consecuentemente reduciendo el tamaño del espacio de búsqueda efectivo.

## Conceptos PSR

Vamos a presentar más formalmente los conceptos y objetivos básicos que son necesarios en los problemas de satisfacción de restricciones y que utilizaremos a lo largo de esta entrada.

**Definición.** Un **problema de satisfacción de restricciones** (**PSR**) es una terna \\((X,D,C)\\) donde:

1.  \\(X\\) es un conjunto de \\(n\\) variables \\(\\{x\_1 ,...,x\_n \\}\\).
2.  \\(D =\\langle D\_1 ,...,D\_n \\rangle\\) es un vector de dominios (\\(D\_i\\) es el dominio que contiene todos los posibles valores que puede tomar la variable \\(x\_i\\)).
3.  \\(C\\) es un conjunto finito de restricciones. Cada restricción está definida sobre un conjunto de \\(k\\) variables por medio de un predicado que restringe los valores que las variables pueden tomar simultáneamente.

**Definición.** Una **asignación de variables**, o **instanciación**, \\((x,a)\\) es un par variable-valor que representa la asignación del valor \\(a\\) a la variable \\(x\\). Una instanciación de un conjunto de variables es una tupla de pares ordenados, \\(((x\_1 ,a\_1 ),...,(x\_i ,a\_i ))\\), donde cada par ordenado \\((x\_i,a\_i)\\) asigna el valor \\(a\_i\\) a la variable \\(x\_i\\). Una tupla se dice **localmente consistente** si satisface todas las restricciones formadas por variables de la tupla.

**Definición.** Una **solución a un PSR** es una asignación de valores a todas las variables de forma que se satisfagan todas las restricciones. Es decir, una solución es una tupla consistente que contiene todas las variables del problema. Una **solución parcial** es una tupla consistente que contiene algunas de las variables del problema. Diremos que un **problema es consistente**, si existe al menos una solución.

Básicamente los objetivos que deseamos alcanzar se centran en una de las siguientes opciones:

1.  Encontrar una solución, sin preferencia alguna.
2.  Encontrar todas las soluciones.
3.  Encontrar una solución _óptima_ (dando alguna **función objetivo** definida en términos de algunas o todas las variables).

<img src="http://www.cs.us.es/~fsancho/images/2016-09/slide_4.jpg">

Antes de entrar con más detalles vamos a resumir la notación que utilizaremos posteriormente.

**Notación Variables:** Para representar las **variables** utilizaremos las últimas letras del alfabeto, por ejemplo \\(x,y,z\\), así como esas mismas letras con un subíndice.

**Notación Restricciones:** Una **restricción k−aria** entre las variables \\(\\{x\_1 ,...,x\_k\\}\\) la denotaremos por \\(C\_{1..k}\\). De esta manera, una **restricción binaria** entre las variables \\(x\_i\\) y \\(x\_j\\) la denotaremos por \\(C\_{ij}\\). Cuando los índices de las variables en una restricción no son relevantes, lo denotaremos simplemente por \\(C\\).

La **aridad** de una restricción es el número de variables que componen dicha restricción. Una **restricción unaria** es una restricción que consta de una sola variable. Una **restricción binaria** es una restricción que consta de dos variables. Una **restricción n−aria** es una restricción que involucra a \\(n\\) variables.

**Ejemplo.** La restricción \\(x \\leq 5\\) es una restricción unaria sobre la variable \\(x\\). La restricción \\(x\_4 − x\_3 \\neq 3\\) es una restricción binaria. La restricción \\(2x\_1 − x\_2 + 4x\_3 \\leq 4\\) es una restricción ternaria.

**Definición.** Una tupla \\(p\\) de una restricción \\(C\_{i..k}\\) es un elemento del producto cartesiano \\(D\_i \\times \\dots\\times D\_k\\). Una tupla \\(p\\) que satisface la restricción \\(C\_{i..k}\\) se le llama **tupla permitida o válida** (en caso contrario, se dirá no permitida o no válida). Una tupla \\(p\\) de una restricción \\(C\_{i..k}\\) se dice que es **soporte** para un valor \\(a \\in D\_j\\) si la variable \\(x\_j \\in X\_{C\_{i..k} }\\), \\(p\\) es una tupla permitida y contiene a \\((x\_j,a)\\). Verificar si una tupla dada es permitida o no por una restricción se llama **comprobación de la consistencia**.

Una restricción puede definirse extensionalmente mediante un conjunto de tuplas válidas o no válidas (cuando sea posible) o también intencionalmente mediante un predicado entre las variables.

**Ejemplo.** Consideremos una restricción entre 4 variables \\(x\_1 ,x\_2 ,x\_3 ,x\_4\\) , todas ellas con dominios el conjunto \\(\\{1,2\\}\\), donde la suma entre las variables \\(x\_1\\) y \\(x\_2\\) es menor o igual que la suma entre \\(x\_3\\) y \\(x\_4\\). Esta restricción puede representarse intencionalmente mediante la expresión \\(x\_1 + x\_2 \\leq x\_3 + x\_4\\). Además, esta restricción también puede representarse extensionalmente mediante el conjunto de tuplas permitidas:

\\(\\{(1,1,1,1), (1,1,1,2), (1,1,2,1), (1,1,2,2), (2,1,2,2), (1,2,2,2),\\)

\\( (1,2,1,2), (1,2,2,1),(2,1,1,2), (2,1,2,1), (2,2,2,2)\\}\\),

o mediante el conjunto de tuplas no permitidas:

\\(\\{(1,2,1,1), (2,1,1,1), (2,2,1,1), (2,2,1,2), (2,2,2,1)\\}\\).

## Consistencia en un PSR

Al igual que ocurre con los algoritmos de búsqueda generales, una forma común de crear algoritmos de búsqueda sistemática para la resolución de PSR tienen como base la búsqueda basada en **backtracking**. Sin embargo, esta búsqueda sufre con frecuencia una explosión combinatoria en el espacio de búsqueda, y por lo tanto no es por sí solo un método suficientemente eficiente para resolver este tipo de problemas.

Una de las principales dificultades con las que nos encontramos en los algoritmos de búsqueda es la aparición de inconsistencias locales que van apareciendo continuamente. Las inconsistencias locales son valores individuales, o una combinación de valores de las variables, que no pueden participar en la solución porque no satisfacen alguna propiedad de consistencia.

Las restricciones explícitas en un PSR, que generalmente coinciden con las que se conocen explícitamente del problema a resolver, se generan cuando se combinan restricciones implícitas que pueden causar inconsistencias locales. Si un algoritmo de búsqueda no almacena las restricciones implícitas, repetidamente redescubrirá la inconsistencia local causada por ellas y malgastará esfuerzo de búsqueda tratando repetidamente de intentar instanciaciones que ya han sido probadas y que no llevan a una solución del problema.

**Ejemplo.** Tenemos un problema con tres variables \\(x,y,z\\), con los dominios respectivos \\(\\{0,1\\}\\), \\(\\{2,3\\}\\) y \\(\\{1,2\\}\\). Hay dos restricciones en el problema: \\(y < z\\) y \\(x \\neq y\\). Si asumimos que la búsqueda mediante backtracking trata de instanciar las variables en el orden \\(x,y,z\\) entonces probará todas las posibles \\(2^3\\) combinaciones de valores para las variables antes de descubrir que no existe solución alguna. Si miramos la restricción entre \\(y\\) y \\(z\\) podremos ver que no hay ninguna combinación de valores para las dos variables que satisfagan la restricción. Si el algoritmo pudiera identificar esta inconsistencia local antes, se evitaría un gran esfuerzo de búsqueda.

En la literatura se han propuesto varias técnicas de consistencia local como formas de mejorar la eficiencia de los algoritmos de búsqueda. Tales técnicas borran valores inconsistentes de las variables o inducen restricciones implícitas que nos ayudan a podar el espacio de búsqueda. Estas técnicas de consistencia local se usan como etapas de preproceso donde se detectan y eliminan las inconsistencias locales antes de empezar la búsqueda o durante la misma con el fin de reducir el árbol de búsqueda.

**Definición.** Un problema es **\\((i,j)\\)-consistente** si cualquier solución a un subproblema con \\(i\\) variables puede ser extendido a una solución incluyendo \\(j\\) variables adicionales \[9\].

<img src="http://www.cs.us.es/~fsancho/images/2016-09/261px-query-decomposition-1.svg.png">

Observa que podemos crear **el grafo de restricciones** (realmente sería un hipergrafo), en el que los nodos son las variables del problema, y las aristas (hiperaristas) serían las restricciones impuestas sobre conjuntos de nodos/variables. Si solo tenemos restricciones binarias, estamos ante el caso de un grafo, si aparecen restricciones unarias, el grafo tendría loops, y si hay restricciones \\(n\\)-arias (con \\(n>2\\)) entonces estaríamos usando un hipergrafo.

La mayoría de las formas de consistencia se pueden ver como especificaciones de la \\((i,j)\\)-consistencia. Cuando \\(i\\) es \\(k − 1\\) y \\(j\\) es \\(1\\), obtenemos la **\\(k\\)-consistencia**.

Un problema es **fuertemente \\(k\\)-consistente** si es \\(i\\)-consistente para todo \\(i \\leq k\\). Un problema fuertemente \\(k\\)-consistente con \\(k\\) variables se llama **globalmente consistente**. La complejidad espacial y temporal en el peor caso de forzar la \\(k\\)-consistencia es exponencial con \\(k\\). Además, cuando \\(k\\geq 2\\), forzar la \\(k\\)-consistencia cambia la estructura del grafo de restricciones añadiendo nuevas restricciones no unarias. Esto hace que la \\(k\\)-consistencia sea impracticable cuando \\(k\\) es grande.

En \[4\] puede encontrarse un análisis más detallado acerca de consistencias en PSR. Vamos a ver aquí solo algunos casos particulares que son de uso común en algoritmos básicos:

### Consistencia de Nodo (\\(1\\)-consistencia)

La consistencia local más simple de todas es la **consistencia de nodo** o **nodo-consistencia**. Forzar este nivel de consistencia nos asegura que todos los valores en el dominio de una variable satisfacen todas las restricciones unarias sobre esa variable.

**Definición.** Un problema es **nodo-consistente** si y sólo si todas sus variables son nodo-consistentes:  
\\\[\\forall x\_i \\in X,\\ \\forall C\_i,\\ \\exists a \\in D\_i \\ :\\ a\\ satisface\\ C\_i\\\]

**Ejemplo.** Consideremos una variable \\(x\\) en un problema con dominio \\(\[2,15\]\\) y la restricción unaria \\(x \\leq 7\\). La consistencia de nodo eliminará el intervalo \\(\[8,15\]\\) del dominio de \\(x\\).

### Consistencia de Arco (\\(2\\)-consistencia)

**Definición.** Un problema binario es **arco-consistente** si para cualquier par de variables \\(x\_i\\) y \\(x\_j\\), para cada valor \\(a\\) en \\(D\_i\\) hay al menos un valor \\(b\\) en \\(D\_j\\) tal que las asignaciones \\((x\_i ,a)\\) y \\((x\_j ,b)\\) satisfacen la restricción entre \\(x\_i\\) y \\(x\_j\\).

<img src="http://www.cs.us.es/~fsancho/images/2016-09/constnetac.gif">

Cualquier valor en el dominio \\(D\_i\\) de la variable \\(x\_i\\) que no es arco-consistente puede ser eliminado de \\(D\_i\\) ya que no puede formar parte de ninguna solución. El dominio de una variable es arco-consistente si todos sus valores son arco-consistentes.

**Ejemplo.** La restricción \\(C\_{ij} = x\_i < x\_j\\), donde \\(x\_i\\in \[3,6\]\\) y \\(x\_j\\in \[8,10\]\\) es consistente, ya que para cada valor \\(a \\in \[3,6\]\\) hay al menos un valor \\(b \\in \[8,10\]\\) de manera que se satisface la restricción \\(C\_{ij}\\). Sin embargo, si la restricción fuese \\(C\_{ij} = x\_i > x\_j\\) no sería arco-consistente.

Un **problema es arco-consistente** si y sólo si todos sus arcos son arco-consistentes:  
\\\[\\forall C\_{ij} \\in C,\\ \\forall a \\in D\_i,\\ \\exists b \\in D\_j \\ : \\ b \\mbox{ es un  
soporte para } a \\mbox{ en } C\_{ij}\\\]

### Consistencia de caminos (\\(3\\)-consistencia)

La consistencia de caminos es un nivel más alto de consistencia local que la arco-consistencia. La consistencia de caminos requiere, para cada par de valores \\(a\\) y \\(b\\) de dos variables \\(x\_i\\) y \\(x\_j\\), que la asignación de \\(((x\_i,a), (x\_j,b))\\) satisfaga la restricción entre \\(x\_i\\) y \\(x\_j\\), y que además exista un valor para cada variable a lo largo del camino entre \\(x\_i\\) y \\(x\_j\\) de forma que todas las restricciones a lo largo del camino se satisfagan.

Un problema satisface la consistencia de caminos si y sólo si todo par de variables \\((x\_i ,x\_j) \\) verifica la consistencia de caminos. Cuando un problema satisface la consistencia de caminos y además es nodo-consistente y arco-consistente se dice que satisface fuertemente la consistencia de caminos.

## Consistencia Global

A veces es deseable una noción más fuerte que la consistencia local. Decimos que un etiquetado, construido mediante un algoritmo de consistencia, es globalmente consistente si contiene solamente aquellas combinaciones de valores que forman parte de, al menos, una solución.

**Definición.** Dado un PSR \\((X,D,C)\\), se dice que es **globalmente consistente** si y sólo si para cada variable  \\(x\_i \\) y cada valor posible para ella, \\(a \\in D\_i\\), la asignación \\((x\_i, a)\\) forma parte de una solución del PSR.

En determinados casos (por ejemplo, si el grafo de restricciones es un árbol), niveles bajos de consistencia son equivalentes a la consistencia global, lo que permite generar algoritmos que en tiempo polinomial pueden dar el conjunto de soluciones sin hacer backtracking.

## El Árbol de Búsqueda

Las posibles combinaciones de la asignación de valores a las variables en un PSR genera un espacio de búsqueda al que se puede dotar de estructura para ser visto como un **árbol de búsqueda**. De esta forma, después podremos recorrerlo siguiendo la estrategia que queramos. La búsqueda mediante **backtracking**, que es la base sobre la que se soportan la mayoría de algoritmos para PSR, corresponde a la tradicional exploración en [profundidad DFS](http://www.cs.us.es/~fsancho/?e=95) en el árbol de búsqueda.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/psr-tree.png" align="left"> La forma más habitual de darle estructura de árbol pasa por asumir que el orden de las variables es estático y no cambia durante la búsqueda, y entonces un nodo en el nivel \\(k\\) del árbol de búsqueda representará un estado donde las variables \\(x\_1 ,...,x\_k\\) están asignadas a valores concretos de sus dominios mientras que el resto de variables, \\(x\_{k+1} ,...,x\_n\\), no lo están. Podemos asignar cada nodo en el árbol de búsqueda con la tupla formada por las asignaciones llevadas a cabo hasta ese momento, donde la raíz del árbol de búsqueda representa la tupla vacía, donde ninguna variable tiene asignado valor alguno.

Los nodos en el primer nivel son \\(1\\)−tuplas que representan estados donde se les ha asignado un valor a la variable \\(x\_1\\). Los nodos en el segundo nivel son \\(2\\)−tuplas que representan estados donde se le asignan valores a las variables \\(x\_1\\) y \\(x\_2\\), y así sucesivamente. Un nodo del nivel \\(k\\) es hijo de un nodo del nivel \\(k-1\\) si la tupla asociada al hijo es una extensión de la de su padre añadiendo una asignación para la variable \\(x\_k\\). Si \\(n\\) es el número de variables del problema, los nodos en el nivel \\(n\\), que representan las hojas del árbol de búsqueda, son \\(n\\)−tuplas, que representan la asignación de valores para todas las variables del problema. De esta manera, si una \\(n\\)−tupla es consistente, entonces es solución del problema. Un nodo del árbol de búsqueda es consistente si la asignación parcial actual es consistente, o en otras palabras, si la tupla correspondiente a ese nodo es consistente.

## Backtracking Cronológico

El algoritmo de búsqueda sistemática más conocido para resolver PSR se denomina **Algoritmo de Backtracking Cronológico** (**BT**). Si asumimos un orden estático de las variables y de los valores en las variables, este algoritmo funciona de la siguiente manera:

1.  Selecciona la siguiente variable de acuerdo al orden de las variables y le asigna su próximo valor. 
2.  Esta asignación de la variable se comprueba en todas las restricciones en las que forma parte la variable actual y las anteriores:
    *   Si todas las restricciones se han satisfecho, vuelve al punto 1.
    *   Si alguna restricción no se satisface, entonces la asignación actual se deshace y se prueba con el próximo valor de la variable actual. 
3.  Si no se encuentra ningún valor consistente entonces tenemos una situación sin salida (dead-end) y el algoritmo retrocede a la variable anteriormente asignada y prueba asignándole un nuevo valor.
4.  Si asumimos que estamos buscando una sola solución, BT finaliza cuando a todas las variables se les ha asignado un valor, en cuyo caso devuelve una solución, o cuando todas las combinaciones de variable-valor se han probado sin éxito, en cuyo caso no existe solución.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/backtrack.gif" align="right"> Es fácil generalizar BT a restricciones no binarias. Cuando se prueba un valor de la variable actual, el algoritmo comprobará todas las restricciones en las que sólo forman parte la variable actual y las anteriores. Si una restricción involucra a la variable actual y al menos una variable futura, entonces esta restricción no se comprobará hasta que se hayan asignado todas las variables futuras de la restricción.

BT es un algoritmo muy simple pero muy ineficiente. El problema es que tiene una visión local del problema. Sólo comprueba restricciones que están formadas por la variable actual y las pasadas, e ignora la relación entre la variable actual y las futuras. Además, este algoritmo es ingenuo en el sentido de que no _recuerda_ las acciones previas, y como resultado, puede repetir la misma acción varias veces innecesariamente. Para ayudar a combatir este problema, se han desarrollado algunos algoritmos de búsqueda más robustos. Estos algoritmos se pueden dividir en algoritmos **look-back** y algoritmos **look-ahead**.

### Algoritmos Look-Back

Los **algoritmos look-back** tratan de explotar la información del problema para comportarse más eficientemente en las situaciones sin salida. Al igual que el backtracking cronológico, los algoritmos look-back llevan a cabo la comprobación de la **consistencia hacia atrás**, es decir, entre la variable actual y las pasadas.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/180px-dead-ends-3.svg.png" align="right"> **Backjumping (BJ)** \[11\] es parecido a BT excepto que se comporta de una manera más inteligente cuando encuentra situaciones sin salida. En vez de retroceder a la variable anteriormente instanciada, BJ salta a la variable más profunda (más cerca de la variable actual) \\(x\_j\\) que está en conflicto con la variable actual \\(x\_i\\) donde \\(j < i\\) (una variable instanciada \\(x\_j\\) está en conflicto con una variable \\(x\_i\\) si la instanciación de \\(x\_j\\) evita uno de los valores en \\(x\_i\\), debido a la restricción entre ellas). Cambiar la instanciación de \\(x\_j\\) puede hacer posible encontrar una instanciación consistente de la variable actual.

Una variante, **conflict-directed Backjumping (CBJ)** \[18\] tiene un comportamiento de salto hacia atrás más sofisticado que BJ, donde se almacena para cada variable un conjunto de conflictos mutuos que permite no repetir conflictos existentes a la vez que saltar a variables anteriores como hace BJ.

### Algoritmos look-ahead

Los algoritmos look-back tratan de reforzar el comportamiento de BT mediante un comportamiento más inteligente cuando se encuentran en situaciones sin salida. Sin embargo, todos ellos llevan a cabo la comprobación de la consistencia solamente hacia atrás, ignorando las futuras variables. Los **algoritmos Look-ahead** hacen una comprobación hacia adelante en cada etapa de la búsqueda, es decir, llevan a cabo las comprobaciones para obtener las inconsistencias de las variables futuras involucradas además de las variables actual y pasadas. De esa manera, las situaciones sin salida se pueden identificar antes y los valores inconsistentes se pueden descubrir y podar para las variables futuras.

**Forward checking (FC)** \[13\] es uno de los algoritmos look-ahead más comunes. En cada etapa de la búsqueda, FC comprueba hacia adelante la asignación actual con todos los valores de las futuras variables que están restringidas con la variable actual. Los valores de las futuras variables que son inconsistentes con la asignación actual son temporalmente eliminados de sus dominios (solo para la rama actual de búsqueda). Si el dominio de una variable futura se queda vacío, la instanciación de la variable actual se deshace y se prueba con un nuevo valor. Si ningún valor es consistente, entonces se lleva a cabo BT estándar. FC garantiza que, en cada etapa, la solución parcial actual es consistente con cada valor de cada variable futura. Además cuando se asigna un valor a una variable, solamente se comprueba hacia adelante con las futuras variables con las que están involucradas. Así mediante la comprobación hacia adelante, FC puede identificar antes las situaciones sin salida y podar el espacio de búsqueda. Se puede ver como aplicar un simple paso de arco-consistencia sobre cada restricción que involucra la variable actual con una variable futura después de cada asignación de variable.

El pseudo código de Forward Checking podría ser el siguiente:

1.  Seleccionar \\(x\_i\\).
2.  Instanciar \\((x\_i , a\_i) : a\_i \\in D\_i\\).
3.  Razonar hacia adelante (check-forward): Eliminar de los dominios de las variables aún no instanciadas con un valor aquellos valores inconsistentes con respecto a la instanciación \\((x\_i, a\_i)\\), de acuerdo al conjunto de restricciones.
4.  Si quedan valores posibles en los dominios de todas las variables por instanciar, entonces:
    *   Si \\(i < n\\), incrementar \\(i\\), e ir al paso 1.
    *   Si \\(i = n\\), parar devolviendo la solución.
5.  Si existe una variable por instanciar sin valores posibles en su dominio entonces retractar los efectos de la asignación \\((x\_i, a\_i)\\):
    *   Si quedan valores por intentar en \\(D\_i\\), ir al paso 2.
    *   Si no quedan valores:
        *   Si \\(i > 1\\), decrementar \\(i\\) y volver al paso 2.
        *   Si \\(i = 1\\), salir sin solución.

![](/~fsancho/images/2016-09/australia-fc4.gif)

Forward checking se ha combinado con algoritmos look-back para generar algoritmos híbridos. Por ejemplo, **forward checking con conflict-directed backjumping (FC-CBJ)** \[18\] es un algoritmo híbrido que combina el movimiento hacia adelante de FC con el movimiento hacia atrás de CBJ, y de esa manera tiene las ventajas de ambos algoritmos.

## Heurísticas

Los algoritmos de búsqueda para PSR vistos hasta el momento requieren el orden en el cual se van a estudiar las variables, así como el orden en el que se van a instanciar los valores de cada una de las variables. Seleccionar el orden correcto de las variables y de los valores puede mejorar notablemente la eficiencia de resolución. De igual forma, puede resultar importante una ordenación adecuada de las restricciones del problema \[20\].

Veamos algunas de las más importantes heurísticas de ordenación de variables y de ordenación de valores.

### Ordenación de Variables

Muchos resultados experimentales han mostrado que el orden en el cual las variables son asignadas durante la búsqueda puede tener una impacto significativo en el tamaño del espacio de búsqueda explorado. Generalmente, las heurísticas de ordenación de variables tratan de seleccionar lo antes posible las variables que más restringen a las demás. La intuición indica que es mejor tratar de asignar lo antes posible las variables más restringidas y de esa manera identificar las situaciones sin salida lo antes posible y así reducir el número de vueltas atrás.

La ordenación de variables puede ser estática y dinámica. Las heurísticas de ordenación de variables estáticas generan un orden fijo de las variables antes de iniciar la búsqueda, basado en información global derivada del grafo de restricciones inicial. Las heurísticas de ordenación de variables dinámicas pueden cambiar el orden de las variables dinámicamente basándose en información local que se genera durante la búsqueda.

**Heurísticas de ordenación de variables estáticas**

Se han propuesto varias heurísticas de ordenación de variables estáticas. Estas heurísticas se basan en la información global que se deriva de la topología del grafo de restricciones original que representa el PSR:

1.  **Minimum Width (MW)** \[8\]: La anchura de la variable \\(x\\) es el número de variables que están antes de \\(x\\), de acuerdo a un orden dado, y que son adyacentes a \\(x\\). La anchura de un orden es la máxima anchura de todas las variables bajo ese orden. La anchura de un grafo de restricciones es la anchura mínima de todos los posibles ordenes. Después de calcular la anchura de un grafo de restricciones, las variables se ordenan desde la última hasta la primera en anchura decreciente. Esto significa que las variables que están al principio de la ordenación son las más restringidas y las variables que están al final de la ordenación son las menos restringidas. Asignando las variables más restringidas al principio, las situaciones sin salida se pueden identificar antes y además se reduce el número de vueltas atrás.
2.  **Maximun Degree (MD)** \[5\]: ordena las variables en un orden decreciente de su grado en el grafo de restricciones. El grado de un nodo se define como el número de nodos que son adyacentes a él. Esta heurística también tiene como objetivo encontrar un orden de anchura mínima, aunque no lo garantiza.
3.  **Maximun Cardinality (MC)** \[19\]: selecciona la primera variable arbitrariamente y después en cada paso, selecciona la variable que es adyacente al conjunto más grande de las variables ya seleccionadas.

**Heurísticas de ordenación de variables dinámicas**

El problema de los algoritmos de ordenación estáticos es que no tienen en cuenta los cambios en los dominios de las variables causados por la propagación de las restricciones durante la búsqueda, o por la densidad de las restricciones. Esto se debe a que estas heurísticas generalmente se utilizan en algoritmos de comprobación hacia atrás donde no se lleva a cabo la propagación de restricciones.

Se han propuesto varias heurísticas de ordenación de variables dinámicas que abordan este problema. La más común se basa en el **principio del primer fallo** (**FF**) \[13\] que sugiere que para tener éxito deberíamos intentar primero donde sea más probable que falle. De esta manera las situaciones sin salida pueden identificarse antes y además se ahorra espacio de búsqueda. De acuerdo con el principio de FF, en cada paso seleccionaríamos la variable más restringida.

La heurística FF también conocida como **heurística Minimum Remaining Values (MRV)**, trata de hacer lo mismo seleccionando la variable con el dominio más pequeño. Se basa en la intuición de que si una variable tiene pocos valores, entonces es más difícil encontrar un valor consistente. Cuando se utiliza MRV junto con algoritmos look-back, equivale a una heurística estática que ordena las variables de forma ascendente con el tamaño del dominio antes de llevar a cabo la búsqueda. Cuando MRV se utiliza en conjunción con algoritmos look-ahead, la ordenación se vuelve dinámica, ya que los valores de las futuras variables se pueden podar después de cada asignación de variables. En cada etapa de la búsqueda, la próxima variable a asignarse es la variable con el dominio más pequeño.

Algunos resultados experimentales prueban que todas las heurísticas de ordenación de variables estáticas son peores que el algoritmo MRV.

### Ordenación de Valores

Se ha realizado poco trabajo sobre heurísticas para la ordenación de valores. La idea básica que hay detrás de las heurísticas de ordenación de valores es seleccionar el valor de la variable actual que más probabilidad tenga de llevarnos a una solución. La mayoría de las heurísticas propuestas tratan de seleccionar el valor menos restringido de la variable actual, es decir, el valor que menos reduce el número de valores útiles para las futuras variables.

Una de las heurísticas de ordenación de valores más conocidas es la **heurística min-conflicts** \[16\]. Básicamente, esta heurística ordena los valores de acuerdo a los conflictos en los que éstos están involucrados con las variables no instanciadas. Esta heurística asocia a cada valor \\(a\\) de la variable actual, el número total de valores en los dominios de las futuras variables adyacentes que son incompatibles con \\(a\\). El valor seleccionado es el asociado a la suma más baja. Esta heurística se puede generalizar para PSR no binarios de forma directa \[14\].

Se pueden encontrar otras propuestas sobre valores en \[12\] y \[10\].

### Otras técnicas de resolución de PSR: Métodos estocásticos

Además de las técnicas sistemáticas y completas, existen también aproximaciones no sistemáticas e incompletas incluyendo heurísticas (tales como hill climbing, búsqueda tabú, enfriamiento simulado, algoritmos genéticos o algoritmos de hormigas).

Estas técnicas pueden considerarse como adaptativas en el sentido de que comienzan su búsqueda en un punto aleatorio del espacio de búsqueda y lo modifican repetidamente utilizando heurísticas hasta que alcanza la solución (con un cierto número de iteraciones), y ya las hemos revisado, en otros contextos, en entradas anteriores. Estos métodos son generalmente robustos y buenos para encontrar un mínimo global en espacios de búsqueda grandes y complejos \[15\], aunque no aseguran que se pueda encontrar debido a la aleatoriedad del punto de inicio. Por ello, es común repetir varias veces la aplicación de estos algoritmos cambiando al azar el punto de partida.

## Aplicaciones

PSR se ha aplicado con mucho éxito a muchos problemas de áreas tan diversas como planificación, scheduling, generación de horarios, empaquetamiento, diseño y configuración, diagnosis, modelado, recuperación de información, CAD/CAM, criptografía, etc.

Los problemas de asignación fueron quizás el primer tipo de aplicación industrial que fue resuelta con herramientas de restricciones. Entre los ejemplos típicos iniciales figuran la asignación de stands en los aeropuertos, donde los aviones deben aparcar en un stand disponible durante la estancia en el aeropuerto (aeropuerto Roissy en Paris) \[6\] o la asignación de pasillos de salida \[3\] y atracaderos \[|7\] en el aeropuerto internacional de Hong Kong \[3\].

Otra área de aplicación de restricciones típica es la asignación de personal donde las reglas de trabajo y unas regulaciones imponen una serie de restricciones difíciles de satisfacer. El principal objetivo en este tipo de problemas es balancear el trabajo entre las personas contratadas de manera que todos tengan las mismas ventajas. Existen sistemas como Gymnaste que se desarrolló para la generación de turnos de enfermeras en los hospitales \[2\], para la asignación de tripulación a los vuelos (British Airways, Swissair), la asignación de plantillas en compañías ferroviarias (SNCF, Compañía de Ferrocarril Italiana) \[7\] o sistemas para la obtención de mallas ferroviarias óptimas \[1\].

<img src="http://www.cs.us.es/~fsancho/images/2016-09/examinationtimetablingusecase.png">

Sin embargo, una de las áreas de aplicación más exitosa de los PSR con dominios finitos es en los problemas de secuenciación o Scheduling, donde de nuevo las restricciones expresan las limitaciones existentes en la vida real. El PSR se utiliza para la secuenciación de actividades industriales, forestales, militares, etc. En general, su uso se está incrementando cada vez más debido a las tendencias de las empresas de trabajar bajo demanda.

## Tendencias

Las tendencias actuales en PSR pasan por desarrollar técnicas para resolver determinados problemas de satisfacción de restricciones basándose principalmente en la topología de estos. Entre todas podemos destacar las siguientes:

1.  Técnicas para resolver problemas con muchas restricciones.
2.  Técnicas para resolver problemas con muchas variables y restricciones, donde puede resultar conveniente la paralelización o distribución del problema de forma que éste se pueda dividir en un conjunto de subproblemas más fáciles de manejar.
3.  Técnicas combinadas de satisfacción de restricciones con métodos de investigación operativa con el fin de obtener las ventajas de ambas propuestas.
4.  Técnicas de computación evolutiva, donde los [algoritmos genéticos](http://www.cs.us.es/~fsancho/?e=65) al igual que las [redes neuronales](http://www.cs.us.es/~fsancho/?e=72), se han ido ganando poco a poco el reconocimiento de los investigadores como técnicas efectivas en problemas de gran complejidad. Se distinguen por utilizar estrategias distintas a la mayor parte de las técnicas de búsqueda clásicas y por usar operadores probabilísticos más robustos que los operadores determinísticos.
5.  Otros temas de interés son heurísticas inspiradas biológicamente, tales como [colonias de hormigas](http://www.cs.us.es/~fsancho/?e=71), [optimización por enjambres de partículas](http://www.cs.us.es/~fsancho/?e=70), algoritmos meméticos, algoritmos culturales, búsqueda dispersa, etc.

! ## Para Saber más...
! 
! [Capítulo sobre PSR](http://users.dsic.upv.es/~msalido/papers/capitulo.pdf)
! [](http://users.dsic.upv.es/~msalido/papers/capitulo.pdf)[Tema de PSR del curso de IA de Ingeniería de Sistemas de la US](https://www.cs.us.es/cursos/ia1/temas/tema-05.pdf)
! [Problemas de Satisfacción de Restricciones de Javier Ramírez Rodriguez de la UAM](http://kali.azc.uam.mx/clc/03_docencia/posgrado/i_artificial/12_ProbSatRest.pdf)

## Referencias

1.  F. Barber, M.A. Salido, Ingolotti L., M. Abril, A. Lova, and P. Tormos. An interactive train scheduling tool for solving and plotting running maps. To appear in LNCS/LNAI on Artificial Intelligence Technology Transfer, 2004.
2.  P. Chan, K. Heus, and G. Weil. Nurse scheduling with global constraints in CHIP: GYMNASTE. In Proc. of Practical Application of Constraint Technology, 1998.
3.  K.P. Chow and M. Perett. Airport counter allocation using constraint logic programming. In Proc. of Practical Application of Constraint Technology, 1997.
4.  R. Debruyne and C. Bessi\` ere. Some practicable filtering techniques for the constraint satisfaction problem. In proceedings of the 15th IJCAI, pages 412–417, 1997.
5.  R. Dechter and I. Meiri. Experimental evaluation of preprocessing algorithms for constraints satisfaction problems. Artificial Intelligence, 68:211–241, 1994.
6.  M. Dincbas and H. Simosis. APACHE- a constraint based, automated stand allocation systems. In Proc. of Advanced Software Technology in Air Transport, 1991.
7.  F. Focacci, E. Lamma, P. Melo, and M. Milano. Constraint logic programming for the crew rostering problem. In Proc. of Practical Application of Constraint Technology, 1997.
8.  E. Freuder. A sufficient condition for backtrack-free search. Journal of the ACM, 29:24–32, 1982.
9.  E. Freuder. A sufficient condition for backtrack-bounded search. Journal of the ACM, 32, 4:755–761, 1985.
10.  D. Frost and R. Dechter. Look-ahead value orderings for constraint satisfaction problems. In Proc. of IJCAI-95, pages 572–578, 1995.
11.  J. Gaschnig. Performance measurement and analysis of certain search algorithms. Technical Report CMU-CS-79-124, Carnegie-Mellon University, 1979.
12.  P.A. Geelen. Dual viewpoint heuristic for binary constraint satisfaction problems. In proceeding of European Conference of Artificial Intelligence (ECAI’92), pages 31–35, 1992.
13.  R. Haralick and Elliot G. Increasing tree efficiency for constraint satisfaction problems. Artificial Intelligence, 14:263–314, 1980.
14.  N. Keng and D. Yun. A planning/scheduling methodology for the constrained resources problem. In Proceeding of IJCAI-89, pages 999–1003, 1989.
15.  J. Larrosa and P. Meseguer. Algoritmos para Satisfacción de Restricciones. Inteligencia Artificial: Revista Iberoamericana de Inteligencia Artificial, 20:31–42, 2003.
16.  S. Minton, M.D. Johnston, A.B. Philips, and P. Laird. A heuristic repair method for constraint-satisfaction and scheduling problems. Artificial Intelligence, 58:161–205, 1992.
17.  M. Perett. Using constraint logic programming techniques in container port planning. In ICL Technical Journal, pages 537–545, 1991.
18.  P. Prosser. An empirical study of phase transitions in binary constraint satisfaction problems. Artificial Intelligence, 81:81–109, 1993.
19.  P.W. Purdom. Search rearrangement backtracking and polynomial average time. Artificial Intelligence, 21:117–133, 1983.
20.  M.A. Salido and F. Barber. A constraint ordering heuristic for scheduling problems. In Proceeding of the 1st Multidisciplinary International Conference on Scheduling : Theory and Applications, pages 476–490, 2003.
21.  P. Van Hentenryck. Constraint Satisfaction in Logic Programming. MIT Press, 1989.