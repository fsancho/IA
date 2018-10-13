---
title: 'Clasificación Supervisada y No Supervisada'
taxonomy:
    category: docs
visible: true
---

[TOC]
Los sistemas de **clasificación supervisados** son aquellos en los que, a partir de un conjunto de ejemplos clasificados (**conjunto de entrenamiento**), intentamos asignar una clasificación a un segundo conjunto de ejemplos. En contra, los sistemas de **clasificación no supervisados** son aquellos en los que no disponemos de una batería de ejemplos previamente clasificados, sino que únicamente a partir de las propiedades de los ejemplos intentamos dar una **agrupación** (clasificación, clustering) de los ejemplos según su similaridad.

Aunque estas definiciones son generales y contienen entre las dos la prática totalidad de los algoritmos de aprendizaje más comunes, en lo que sigue nos vamos a centrar en dos algoritmos concretos, uno de cada tipo, que pueden servir de representación para entender su comportamiento más general, y que nos permitirán también introducir los conceptos generales de **matriz de confusión**, **error**, **sobre-aprendizaje**, etc.

## Algoritmo de Clasificación Supervisado: K Vecinos más cercanos

<img style="float:right;margin:0 10px 10px 0;" src="http://upload.wikimedia.org/wikipedia/commons/e/e7/KnnClassification.svg"/> El algoritmo de los **k vecinos más cercanos** (**k-NN Nearest Neighbour**) es un sistema de clasificación supervisado basado en criterios de vecindad. Recordemos que los sistemas de **clasificación supervisados** son aquellos en los que, a partir de un conjunto de ejemplos clasificados (**conjunto de entrenamiento**), intentamos asignar una clasificación a un segundo conjunto de ejemplos. En particular, k-NN se basa en la idea de que los nuevos ejemplos serán clasificados a la clase a la cual pertenezca la mayor cantidad de vecinos más cercanos del conjunto de entrenamiento más cercano a él.

El **algoritmo del vecino más cercano** explora todo el conocimiento almacenado en el conjunto de entrenamiento para determinar cuál será la clase a la que pertenece una nueva muestra, pero únicamente tiene en cuenta el vecino más próximo a ella, por lo que es lógico pensar que es posible que no se esté aprovechando de forma eficiente toda la información que se podría extraer del conjunto de entrenamiento.

Con el objetivo de resolver esta posible deficiencia surge la regla de los k vecinos más cercanos (k-NN), que es una extensión en la que se utiliza la información suministrada por los k ejemplos del conjunto de entrenamiento más cercanos.

En problemas prácticos donde se aplica esta regla de clasificación se acostumbra tomar un número k de vecinos impar para evitar posibles empates (aunque esta decisión solo resuelve el problema en clasificaciones binarias). En otras ocasiones, en caso de empate, se selecciona la clase que verifique que sus representantes tengan la menor distancia media al ejemplo que se está clasificando. En última instancia, si se produce un empate, siempre se puede decidir aleatoriamente entre las clases con mayor representación.

<iframe width="360"  height="240" src="https://www.youtube.com/embed/zBCcAtg3P4k" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Una posible variante de este algoritmo consiste en **ponderar la contribución de cada vecino** de acuerdo a la distancia entre él y el ejemplar a ser clasificado, dando mayor peso a los vecinos más cercanos. Por ejemplo podemos ponderar el voto de cada vecino de acuerdo al cuadrado inverso de sus distancias:  
Si \(x\) es el ejemplo que queremos clasificar enntre las clases \(V\), y \(\{x_i\}\) es el conjunto de los \(k\) ejemplos de entrenamiento más cercanos, definimos

$w_i = \frac{1}{d(x,x_i)^2}$

y entonces la clase asignada a \(x\) es aquella que verifique que la suma de los pesos de sus representantes sea máxima:

$argmax_{v \in V} \sum_{i=1...k,\ x_i\in v} w_i$

Esta mejora es muy efectiva en muchos problemas prácticos. Es robusto ante los ruidos de datos y suficientemente efectivo en conjuntos de datos grandes. Además, se puede ver que al tomar promedios ponderados de los k vecinos más cercanos el algoritmo puede evitar el impacto de ejemplos con ruido aislados.

## Algoritmo de Clasificación No Supervisado: K medias

<img style="float:right;margin:0 10px 10px 0;" src="http://media.tumblr.com/tumblr_ljk6rsrrIX1qzd2hd.png"/> En contra de los algoritmos supervisados como el que hemos visto anteriormente, los sistemas de **clasificación no supervisados** son aquellos en los que no disponemos de una batería de ejemplos previamente clasificados, sino que únicamente a partir de las propiedades de los ejemplos intentamos dar una **agrupación** (**clasificación**, **clustering**) de los ejemplos según su similaridad.

Como ejemplo de algoritmo de clasificación no supervisado vamos a explicar brevemente el que, posiblemente, sea el más sencillo y extendido de todos ellos, el **algoritmo de las K-medias**, que es aplicable en los casos en que tengamos una inmersión de nuestros ejemplos en un espacio geométrico.

El algoritmo intenta encontrar una partición de nuestros ejemplos en K agrupaciones, de forma que cada ejemplo pertenezca a una de ellas, concretamente a aquella cuyo centro geométrico esté más cerca. El mejor valor de K para que la clasificación separe lo mejor posible los ejemplos no se conoce a priori, y depende completamente de los datos con los que trabajemos. Este algoritmo intenta minimizar la varianza total del sistema, es decir, si \(c_i\) es el centro geométrico de la agrupación \(i\), y \(\{x_j^i\}\) es el conjunto de ejemplos clasificados en el grupo \(i\), entonces intentamos minimizar la función:

$\sum_i \sum_j d(x_j^i,c_i)^2$

<img style="float:right;margin:0 10px 10px 0;width:300px" src="http://www.cs.us.es/~fsancho/images/2016-05/hqdefault.jpg"/> El algoritmo que se sigue es el siguiente:

1.  Seleccionar al azar K puntos como centros de los grupos.
2.  Asignar los ejemplos al centro más cercano.
3.  Calcular el centro geométrico (centroide) de los ejemplos asociados a cada grupo.
4.  Repetir desde el paso 2 hasta que no haya reasignación de centros (o su último desplazamiento esté por debajo de un umbral)

El algoritmo anterior es relativamente eficiente, y normalmente se requieren pocos pasos para que el proceso se estabilice. Pero en contra, es necesario determinar el número de agrupaciones a priori, y el sistema es sensible a la posición inicial de los K centros, haciendo que no consigan un mínimo global, sino que se sitúe en un mínimo local. Por desgracia, no existe un método teórico global que permita encontrar el valor óptimo de grupos iniciales ni las posiciones en las que debemos situar los centros, por lo que se suele hacer una aproximación experimental repitiendo el algoritmo con diversos valores y posiciones de centros. En general, un valor elevado de K hace que el error disminuya, pero a cambio se tiene un sobre entrenamiento que disminuye la cantidad de información que la agrupación resultante nos da.

<iframe width="360"  height="240" src="https://www.youtube.com/embed/_aWzGGNrcic" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Medir la eficiencia de un aprendizaje

Una vez que tenemos una máquina de aprendizaje que es capaz de desempeñar su tarea hemos de pasar a medir la eficiencia de la máquina, es decir, intentar extraer alguna medida que nos informe de lo bien (o mal) que lo está haciendo. Como en los casos de aprendizaje supervisado y no supervisado los objetivos que se buscan son muy distintos, la eficiencia de unos u otros algoritmos suelen definirse también de formas muy distintas.

El caso del **aprendizaje supervisado** es el más natural y habitual para calcular la eficiencia de la máquina resultante. Recordemos que, en este caso, disponemos de un conjunto de ejemplos iniciales sobre los que realizamos el aprendizaje. Como los algoritmos de aprendizaje supervisado aprenden de estos datos para ajustar sus parámetros internos y devolver la respuesta correcta, no tiene mucho sentido medir la eficiencia de la máquina volviendo a pasarle los mismos datos, ya que la información que nos daría sería engañosamente optimista. Lo que buscamos es ver si la máquina es capaz, a partir de los ejemplos entrenados, **generalizar** el comportamiento aprendido para que sea suficientemente buena sobre datos no vistos a priori. Si es así, decimos que la máquina (modelo, algoritmo) generaliza correctamente. 

La forma más común para medir esta capacidad de generalización es guardando algunos de los ejemplos iniciales para ser usados posteriormente como **validación** de la máquina aprendida. Es decir, el conjunto de ejemplos (de los que conocemos el resultado que debe dar), \(D\), se particiona en dos subconjuntos, \(D=D_{train}\cup D_{val}\), de forma que al algoritmo de entrenamiento solo se le enseñan los ejemplos de \(D_{train}\), y una vez realizado el entrenamiento completo, se mide cómo de buenos son los resultados sobre los datos de \(D_{val}\), que nunca ha visto. El error cometido se mide teniendo en cuenta el resultado que la máquina devuelve sobre ellos y el dato, conocido, que debería haber devuelto.

Así, si la máquina es de clasificación, es habitual hablar de la **matriz de confusión** que se obtiene, que simplemente indica, para cada una de las posibles clases, cuántos ejemplos de \(D_{val}\) se clasifican en cada una de la posibles opciones: cada columna de la matriz representa el número de predicciones de cada clase, mientras que cada fila representa las instancias en la clase real. 

<img src="http://www.cs.us.es/~fsancho/images/2016-12/matrizconfusion.jpg"/>

Uno de los beneficios de las matrices de confusión es que facilitan ver si el sistema está confundiendo dos clases, no solo el error global que comete de saber cuántos ha clasificado bien o no. 

Cuando la máquina se usa para hacer predicciones numéricas (o vectoriales), no clasificación, suele ser normal medir la media del error cometido en los ejemplos de \(D_{val}\), y hablamos del **error de validación**:

$E_{val}=\frac{1}{|D_{val}|} \sum_{(x,y)\in D_{val} } |y-M(x)|$

donde \(y\) sería el valor que se debería haber devuelto, y \(M(x)\) es el valor que nuestra máquina entrenada ha conseguido devolver. Obsérvese que esta fórmula vale para cualquier tipo de resultado en el que podamos **medir** lo que se diferencia el valor obtenido del esperado. En el caso de los clasificadores sería equivalente a considerar que vale \(1\) si son distintos, y \(0\) si son iguales.

Podríamos haber calculado de igual forma el **error de entrenamiento**, \(E_{train}\), que habitualmente será muy reducido ya que el algoritmo de aprendizaje modifica los parámetros del modelo para intentar minimizarlo. Cuando el proceso consigue reducir este error tanto que es posible que no generalice bien (es decir, al modelo se ha ajustado tanto a los datos vistos, que ha perdido el patrón general que pueden seguir), se dice que se ha producido un **sobre-entrenamiento** (**overfitting**), y el modelo resultante deja de ser útil para el propósito inicial de predecir el comportamiento en las partes no observadas.

<img src="http://www.cs.us.es/~fsancho/images/2016-12/overfitting.jpg"/>

Por ello, es importante mantener un equilibrio en el proceso de aprendizaje para que no aprenda tanto de los datos proporcionados como para distorsionar el posible patrón general que está detrás de ellos (y que muchas veces tienen un ruido o un sesgo que no podemos evitar en la medición).

<img src="http://www.cs.us.es/~fsancho/images/2016-12/testtrain.png"/>

En el caso de estar trabajando con **aprendizaje no supervisado** tenemos el problema de no disponer de una respuesta verdadera que sepamos a priori, por lo que es mucho más complicado poder dar medidas de eficiencia. En casos como el de la clusterización en espacios geométricos (numéricos) lo que se puede medir es algo parecido a un potencial de estrés de la agrupación conseguida, que sería el valor de la propia función que queremos minimizar, por ejemplo:

$\sum_i \sum_j d(x_j^i,c_i)^2$

donde \(x_j^i\) es la colección de elementos asignados al cluster \(c_i\).

! ### Para saber más...
! [Tutorial clustering K-medias](http://home.dei.polimi.it/matteucc/Clustering/tutorial_html/kmeans.html)
! [Wikipedia: K vecinos más cercanos](https://es.wikipedia.org/wiki/K-vecinos_m%C3%A1s_cercanos)
! [Clasificadores KNN](http://www.sc.ehu.es/ccwbayes/docencia/mmcc/docs/t9knn.pdf)
! [Cluster: K-medias](http://www.uantof.cl/facultades/csbasicas/Matematicas/academicos/emartinez/magister/cluster1.pdf)