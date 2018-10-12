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

!! **Ejemplo.** El **problema de coloración de mapas** es un problema clásico que se puede formular como un PSR. En este problema hay un conjunto de colores y un mapa dividido en regiones. El objetivo es colorear cada región del mapa de manera que regiones adyacentes tengan distintos colores. Una forma de modelar este problema dentro del PSR sería asociando una variable por cada región del mapa (el dominio de cada variable es el conjunto de posibles colores disponibles), y para cada par de regiones contiguas añadir una restricción sobre los valores de las variables correspondientes que impida asignarles el mismo valor (color). Como suele ser habitual, este mapa puede ser representado mediante un grafo donde los nodos representan las diversas regiones del mapa y cada par de regiones adyacentes están unidas por una arista. Veremos que esta representación en forma de grafo, que en este problema es natural, será usada como metodología general para dar una estructura a las restricciones de cualquier problema PSR.
! <img src="http://www.cs.us.es/~fsancho/images/2016-09/screen-shot-2013-05-20-at-3.57.27-pm.png" width=500px>

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

!! Consideremos el conocido **problema criptoaritmético ’send+more=money’**. Este problema puede ser declarado como: asignar a cada letra \(\{s, e, n, d, m, o, r, y\}\) un dígito diferente del conjunto \(\{0,...,9\}\) de forma que se satisfaga la expresión \(send+more=money\).
!! <img src="http://www.cs.us.es/~fsancho/images/2016-09/sendmoremoney.jpg" width=200px>
!! La manera más directa de modelar este problema es asignando una variable a cada una de las letras (que vendrán representadas por las mismas letras), todas ellas tomando valores en el dominio \(\{0,...,9\}\) y con las restricciones de:
!! 1.  Todas las variables toman valores distintos, y
!! 2.  Se satisface \(send+more=money\).
!! De esta forma, podemos escribir las restricciones como:
!! \(10^3 (s+m)+10^2 (e+o)+10(n+r)+d+e = 10^4 m + 10^3 o + 10^2 n + 10e + y\)
!! \(s\neq e,\ s\neq n,\ ...,\ r\neq y\)
!! Esta representación del problema es correcta, pero no es muy útil, ya que la primera de las restricciones exige manipular todas las variables simultáneamente y no facilita recorrer el espacio combinatorio de valores de una forma cómoda (ten en cuenta siempre que, finalmente, vamos a recorrer este espacio de combinaciones de valores como un espacio de estados). Por lo que, al no disponer de restricciones locales entre las variables, no podemos podar el espacio de búsqueda para agilizar la búsqueda de soluciones.

!! Vamos a dar otro modelado similar pero más eficiente para resolver el problema, que consiste en decomponer esta restricción global en restricciones más pequeñas haciendo uso de las relaciones que se producen entre los dígitos que ocupan la misma posición en una suma. Para ello, introducimos los **dígitos de acarreo** para descomponer la ecuación anterior en una colección de pequeñas restricciones.
!! <img src="http://www.cs.us.es/~fsancho/images/2016-09/acarreo.png">
!! Tal y como está planteado el problema, \(m\) debe de tomar el valor \(1\) (ya que es el acarreo de 2 cifras que como mucho pueden sumar \(18\), más un posible acarreo previo de una unidad, lo que limita el resultado a \(19\)) y por lo tanto \(s\) solamente puede tomar valores de \(\{1,...,9\}\) (si \(s=0\) entonces no podría haber acarreo). Además de las variables del modelo anterior, el nuevo modelo incluye tres variables adicionales, \(c_1\), \(c_2\), \(c_3\) que sirven como dígitos de acarreo. Aunque introducimos nuevas variables, por lo que el espacio de búsqueda se amplia, éstas nos permitirán simplificar las restricciones y facilitar su exploración de forma considerable. En consecuencia, el dominio de \(s\) es \(\{1,...,9\}\), el dominio de \(m\) es \(\{1\}\), el dominio de los dígitos de acarreo es \(\{0,1\}\), y el dominio del resto de variables es \(\{0,...,9\}\).
!! Con la ayuda de los dígitos de acarreo la restricción de la ecuación anterior puede descomponerse en varias restricciones más pequeñas (junto con las restricciones que indican que todas las variables originales son distintas entre sí):
!! \(e + d = y + 10c_1\)  
!! \(c_1 + n + r = e + 10c_2\)  
!! \(c_2 + e + o = n + 10c_3\)  
!! \(c_3 + s + m = 10m + o\)
!! Esta nueva representación presenta la ventaja de que las restricciones más pequeñas pueden comprobarse durante la búsqueda de una forma más sencilla y local, permitiendo podar más inconsistencias y consecuentemente reduciendo el tamaño del espacio de búsqueda efectivo.

## Conceptos PSR
Vamos a presentar más formalmente los conceptos y objetivos básicos que son necesarios en los problemas de satisfacción de restricciones y que utilizaremos a lo largo de esta entrada.

> **Definición.** Un **problema de satisfacción de restricciones** (**PSR**) es una terna \((X,D,C)\) donde:
> 
> 1.  \(X\) es un conjunto de \(n\) variables \(\{x_1 ,...,x_n \}\).
> 2.  \(D =\langle D_1 ,...,D_n \rangle\) es un vector de dominios (\(D_i\) es el dominio que contiene todos los posibles valores que puede tomar la variable \(x_i\)).
> 3.  \(C\) es un conjunto finito de restricciones. Cada restricción está definida sobre un conjunto de \(k\) variables por medio de un predicado que restringe los valores que las variables pueden tomar simultáneamente.

> **Definición.** Una **asignación de variables**, o **instanciación**, \((x,a)\) es un par variable-valor que representa la asignación del valor \(a\) a la variable \(x\). Una instanciación de un conjunto de variables es una tupla de pares ordenados, \(((x_1 ,a_1 ),...,(x_i ,a_i ))\), donde cada par ordenado \((x_i,a_i)\) asigna el valor \(a_i\) a la variable \(x_i\). Una tupla se dice **localmente consistente** si satisface todas las restricciones formadas por variables de la tupla.

> **Definición.** Una **solución a un PSR** es una asignación de valores a todas las variables de forma que se satisfagan todas las restricciones. Es decir, una solución es una tupla consistente que contiene todas las variables del problema. Una **solución parcial** es una tupla consistente que contiene algunas de las variables del problema. Diremos que un **problema es consistente**, si existe al menos una solución.

Básicamente los objetivos que deseamos alcanzar se centran en una de las siguientes opciones:

1.  Encontrar una solución, sin preferencia alguna.
2.  Encontrar todas las soluciones.
3.  Encontrar una solución _óptima_ (dando alguna **función objetivo** definida en términos de algunas o todas las variables).
<img src="http://www.cs.us.es/~fsancho/images/2016-09/slide_4.jpg">
Antes de entrar con más detalles vamos a resumir la notación que utilizaremos posteriormente.

> **Notación Variables:** Para representar las **variables** utilizaremos las últimas letras del alfabeto, por ejemplo \(x,y,z\), así como esas mismas letras con un subíndice.

> **Notación Restricciones:** Una **restricción $k$−aria** entre las variables \(\{x_1 ,...,x_k\}\) la denotaremos por \(C_{1..k}\). De esta manera, una **restricción binaria** entre las variables \(x_i\) y \(x_j\) la denotaremos por \(C_{ij}\). Cuando los índices de las variables en una restricción no son relevantes, lo denotaremos simplemente por \(C\).

La **aridad** de una restricción es el número de variables que componen dicha restricción. Una **restricción unaria** es una restricción que consta de una sola variable. Una **restricción binaria** es una restricción que consta de dos variables. Una **restricción n−aria** es una restricción que involucra a \(n\) variables.

!! **Ejemplo.** La restricción \(x \leq 5\) es una restricción unaria sobre la variable \(x\). La restricción \(x_4 − x_3 \neq 3\) es una restricción binaria. La restricción \(2x_1 − x_2 + 4x_3 \leq 4\) es una restricción ternaria.

> **Definición.** Una tupla \(p\) de una restricción \(C_{i..k}\) es un elemento del producto cartesiano \(D_i \times \dots\times D_k\). Una tupla \(p\) que satisface la restricción \(C_{i..k}\) se le llama **tupla permitida o válida** (en caso contrario, se dirá no permitida o no válida). Una tupla \(p\) de una restricción \(C_{i..k}\) se dice que es **soporte** para un valor \(a \in D_j\) si la variable \(x_j \in X_{C_{i..k} }\), \(p\) es una tupla permitida y contiene a \((x_j,a)\). Verificar si una tupla dada es permitida o no por una restricción se llama **comprobación de la consistencia**.

Una restricción puede definirse extensionalmente mediante un conjunto de tuplas válidas o no válidas (cuando sea posible) o también intencionalmente mediante un predicado entre las variables.

!! **Ejemplo.** Consideremos una restricción entre 4 variables \(x_1 ,x_2 ,x_3 ,x_4\) , todas ellas con dominios el conjunto \(\{1,2\}\), donde la suma entre las variables \(x_1\) y \(x_2\) es menor o igual que la suma entre \(x_3\) y \(x_4\). Esta restricción puede representarse intencionalmente mediante la expresión \(x_1 + x_2 \leq x_3 + x_4\). Además, esta restricción también puede representarse extensionalmente mediante el conjunto de tuplas permitidas:
!! 
!! \(\{(1,1,1,1), (1,1,1,2), (1,1,2,1), (1,1,2,2), (2,1,2,2), (1,2,2,2),\)
!! \( (1,2,1,2), (1,2,2,1),(2,1,1,2), (2,1,2,1), (2,2,2,2)\}\),
!! o mediante el conjunto de tuplas no permitidas:
!! \(\{(1,2,1,1), (2,1,1,1), (2,2,1,1), (2,2,1,2), (2,2,2,1)\}\).

## Aplicaciones
PSR se ha aplicado con mucho éxito a muchos problemas de áreas tan diversas como planificación, generación de horarios, empaquetamiento, diseño y configuración, diagnosis, modelado, recuperación de información, CAD/CAM, criptografía, etc.

Los problemas de asignación fueron quizás el primer tipo de aplicación industrial que fue resuelta con herramientas de restricciones. Entre los ejemplos típicos iniciales figuran la asignación de stands en los aeropuertos, donde los aviones deben aparcar en un stand disponible durante la estancia en el aeropuerto (aeropuerto Roissy en Paris) o la asignación de pasillos de salida y atracaderos en el aeropuerto internacional de Hong Kong.

Otra área de aplicación de restricciones típica es la asignación de personal donde las reglas de trabajo y unas regulaciones imponen una serie de restricciones difíciles de satisfacer. El principal objetivo en este tipo de problemas es balancear el trabajo entre las personas contratadas de manera que todos tengan las mismas ventajas. Existen sistemas como Gymnaste que se desarrolló para la generación de turnos de enfermeras en los hospitales, para la asignación de tripulación a los vuelos (British Airways, Swissair), la asignación de plantillas en compañías ferroviarias (SNCF, Compañía de Ferrocarril Italiana) o sistemas para la obtención de mallas ferroviarias óptimas.

<img src="http://www.cs.us.es/~fsancho/images/2016-09/examinationtimetablingusecase.png" width=600px>

Sin embargo, una de las áreas de aplicación más exitosa de los PSR con dominios finitos es en los problemas de secuenciación de tareas, donde de nuevo las restricciones expresan las limitaciones existentes en la vida real. El PSR se utiliza para la secuenciación de actividades industriales, forestales, militares, etc. En general, su uso se está incrementando cada vez más debido a las tendencias de las empresas de trabajar bajo demanda.


## Tendencias

Las tendencias actuales en PSR pasan por desarrollar técnicas para resolver determinados problemas de satisfacción de restricciones basándose principalmente en la topología de éstos. Entre todas podemos destacar las siguientes:

1.  Técnicas para resolver problemas con muchas restricciones.
2.  Técnicas para resolver problemas con muchas variables y restricciones, donde puede resultar conveniente la paralelización o distribución del problema de forma que éste se pueda dividir en un conjunto de subproblemas más fáciles de manejar.
3.  Técnicas combinadas de satisfacción de restricciones con métodos de investigación operativa con el fin de obtener las ventajas de ambas propuestas.
4.  Técnicas de computación evolutiva, donde los [algoritmos genéticos](http://www.cs.us.es/~fsancho/?e=65) al igual que las [redes neuronales](http://www.cs.us.es/~fsancho/?e=72), se han ido ganando poco a poco el reconocimiento de los investigadores como técnicas efectivas en problemas de gran complejidad. Se distinguen por utilizar estrategias distintas a la mayor parte de las técnicas de búsqueda clásicas y por usar operadores probabilísticos más robustos que los operadores determinísticos.
5.  Otros temas de interés son heurísticas inspiradas biológicamente, tales como [colonias de hormigas](http://www.cs.us.es/~fsancho/?e=71), [optimización por enjambres de partículas](http://www.cs.us.es/~fsancho/?e=70), algoritmos meméticos, algoritmos culturales, búsqueda dispersa, etc.

! ## Para Saber más...
! 
! [Capítulo sobre PSR](http://users.dsic.upv.es/~msalido/papers/capitulo.pdf)
! [Tema de PSR del curso de IA de Ingeniería de Sistemas de la US](https://www.cs.us.es/cursos/ia1/temas/tema-05.pdf)
! [Problemas de Satisfacción de Restricciones de Javier Ramírez Rodriguez de la UAM](http://kali.azc.uam.mx/clc/03_docencia/posgrado/i_artificial/12_ProbSatRest.pdf)