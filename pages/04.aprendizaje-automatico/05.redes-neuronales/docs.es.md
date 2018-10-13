---
title: 'Redes Neuronales'
taxonomy:
    category: docs
visible: true
---

[TOC]
Una **Red Neuronal Artificial (RNA**) es un modelo matemático inspirado en el comportamiento biológico de las neuronas y en cómo se organizan formando la estructura del cerebro. El cerebro puede considerarse un sistema altamente complejo, donde se calcula que hay aproximadamente 100 mil millones (\(10^{11}\)) neuronas en la corteza cerebral y que forman un entramado de más de 500 billones de conexiones neuronales (una neurona puede llegar a tener 100 mil conexiones, aunque la media se sitúa entre 5000 y 10000 conexiones). 

Respecto a su funcionamiento, el cerebro puede ser visto como un sistema inteligente que lleva a cabo tareas de manera distinta a como lo hacen las computadoras actuales. Si bien estas últimas son muy rápidas en el procesamiento de la información, existen tareas muy complejas, como el reconocimiento y clasificación de patrones, que demandan demasiado tiempo y esfuerzo aún en las computadoras más potentes de la actualidad, pero que el cerebro humano es más apto para resolverlas, muchas veces sin aparente esfuerzo (por ejemplo, el reconocimiento de un rostro familiar entre una multitud de otros rostros). 

<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2015-07/41d2cc80-25f4-11e2-bb76-001e670c2818.jpg"/>

Si bien hay distintos tipos de neuronas biológicas, la imagen de la izquierda muestra un esquema simplificado del tipo más común, y donde podemos reconocer diferentes partes:

*   El cuerpo central, llamado **soma**, que contiene el núcleo celular.
*   Una prolongación del soma, el **axón**. 
*   Una ramificación terminal, las **dendritas**.
*   Una zona de conexión entre una neurona y otra, conocida como **sinapsis**.

La función principal de las neuronas es la transmisión de impulsos nerviosos. Estos viajan por toda la neurona comenzando por las dendritas hasta llegar a las terminaciones del axón, donde pasan a otra neurona por medio de la conexión sináptica.

La manera en que respondemos ante los estímulos del mundo exterior, y el aprendizaje que podemos realizar del mismo, está directamente relacionado con las conexiones neuronales del cerebro, y las RNAs son un intento de emular este hecho.

## Modelo neuronal de McCulloch-Pitts

El primer modelo matemático de una neurona artificial, creado con el fin de llevar a cabo tareas simples, fue presentado en el año 1943 en un trabajo conjunto entre el psiquiatra y neuroanatomista **Warren McCulloch** y el matemático **Walter Pitts**.

La siguiente figura muestra un ejemplo de modelo neuronal con \(n\) entradas, que consta de:

*   Un conjunto de entradas \(x_1,\dots x_n\).
*   Los pesos sinápticos \(w_1,\dots w_n\), correspondientes a cada entrada.
*   Una función de agregación, \(\Sigma\).
*   Una función de activación, \(f\).
*   Una salida, \(Y\).

<img src="http://www.um.es/LEQ/Atmosferas/Ch-VI-3/6-3-8.GIF"/>

Las entradas son el estímulo que la neurona artificial recibe del entorno que la rodea, y la salida es la respuesta a tal estímulo. La neurona puede adaptarse al medio circundante y aprender de él modificando el valor de sus pesos sinápticos, y por ello son conocidos como los **parámetros libres** del modelo, ya que pueden ser modificados y adaptados para realizar una tarea determinada.

En este modelo, la salida neuronal \(Y\) está dada por:

$Y = f(\sum_{i=1}^n w_i x_i)$

La función de activación se elige de acuerdo a la tarea realizada por la neurona. Entre las más comunes dentro del campo de las RNAs podemos destacar:

<img src="http://jarroba.com/wp-content/uploads/2013/09/funciones-de-activaci%C3%B3n.png"/>

## Usando el Perceptron para clasificar clases en el plano

Aplicaremos el modelo neuronal de la sección anterior para realizar tareas de clasificación en el plano (por lo que solo haremos uso de dos entradas, \(x_1\) y \(x_2\)). Para ello, vamos a considerar que existe una entrada de peso 1, llamada \(b\) y consideraremos como función de activación a la función signo definida por:

$\Gamma(s) = \left\{ \begin{array}{cl}   1  & \mbox{si } s \geq 0 \\   -1 & \mbox{si } s < 0 \end{array} \right.$

Por lo tanto, la salida neuronal \(Y\) estará dada en este caso por:

$Y =\left\{ \begin{array}{cl}   1  & \mbox{si } w_1 x_1 + w_2 x_2 + b \geq 0 \\   -1 & \mbox{si } w_1 x_1 + w_2 x_2 + b < 0 \end{array} \right.$

Supongamos que tenemos dos clases en el plano: la clase \(C_1\), formada por los círculos rojos, y la clase \(C_2\), formada por los círculos azules, donde cada elemento de estas clases está representado por un punto \((x,y)\) en el plano. Supondremos además que tales clases son separables linealmente, es decir, es posible trazar una recta que separe estrictamente ambas clases.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/020ad512-25f8-11e2-bb76-001e670c2818.png"/>

Diremos que la neurona artificial clasifica correctamente las clases \(C_1\) y \(C_2\) si dados los pesos sinápticos \(w_1\) y \(w_2\) y el término aditivo \(b\), la recta con ecuación

$y = −\frac{w_1}{w_2} x − \frac{b}{w_2}$

es una recta que separa las dos clases. La ecuación implícita de la recta es \(w_1x + w_2y + b = 0\). Obsérvese que si el punto \((x_0,y_0) \in C_1\), entonces \(w_1x_0+ w_2y_0+ b < 0\) y si \((x_0,y_0) \in C_2\), entonces \(w_1x_0+ w_2y_0+ b > 0\). Por lo tanto, dado el par \((x_0,y_0) \in C_1\cup C_2\), la neurona clasifica de la siguiente manera:

$(x_0,y_0) \in C_1 \Leftrightarrow Y = −1$

$(x_0,y_0) \in C_2 \Leftrightarrow  Y = 1$

Si ahora tomamos dos clases $C^*_1$ y \(C^*_2\) (separables linealmente) distintas a las anteriores, entonces la neurona puede no clasificar correctamente a estas clases, pues la recta anterior puede no ser una recta válida para separarlas. Sin embargo, es posible modificar los parámetros anteriores y obtener nuevos parámetros \(w^*_1, w^*_2\) y \(b^*\) tal que la recta \(y = −\frac{w^*_1}{w^*_2} x − \frac{b^*}{w^*_2}\) sí sirva como recta de separación entre ellos. El proceso por el cual la neurona pasa de los parámetros \(w_1, w_2, b\) a los parámetros  \(w^*_1, w^*_2, b^*\) se conoce como **método de aprendizaje**. Este proceso es el que permite modificar los parámetros libres con el fin de que la neurona se adapte y sea capaz de realizar diversas tareas.

El método de aprendizaje que detallaremos a continuación y que utilizaremos para adaptar los parámetros libres con el fin de clasificar correctamente las clases \(C_1\) y \(C_2\) se conoce como método de **error-corrección**. Para aplicarlo es necesario:

*   Un conjunto de entrenamiento, \(D\).
*   Un instructor.
*   Valores iniciales, \(w'_1, w'_2, b'\), arbitrarios de los parámetros libres.

El conjunto de entrenamiento es definido por \(D = C_1\cup C_2\). El entrenamiento consiste en lo siguiente:

*   El instructor toma un elemento \((x_0,y_0) \in D\) al azar y presenta éste a la neurona.
*   Si la neurona clasifica mal este punto, es decir, si la salida de la neurona es \(Y = −1\) cuando \((x_0,y_0) \in C_2\) o \(Y = 1\) cuando \((x_0,y_0) \in C_1\), entonces se aplica la siguiente corrección a los parámetros libres iniciales

$w_1= w'_1+ d x_0$

$w_2= w'_2+ d y_0$

$b = b'+ d$

donde el valor de \(d\) se obtiene de la siguiente manera:

$d = =\left\{ \begin{array}{cl}   1  & \mbox{si } Y=-1 \mbox{ y } (x_0,y_0)\in C_2 \\   -1 & \mbox{si } Y=1 \mbox{ y } (X_0,y_0)\in C_1 \end{array} \right.$

*   Si la neurona clasifica bien el punto \((x_0,y_0)\), entonces no se realiza ninguna corrección.
*   El procedimiento se repite pasando a la neurona otro punto del conjunto \(D\) y usando los últimos parámetros \(w_1 , w_2, b\) corregidos (no los iniciales). Nuevamente, si la neurona clasifica mal el punto, entonces se aplica una corrección similar a la anterior.
*   Esta tarea se repite con todos los puntos del conjunto \(D\). Si en el proceso hubo correcciones, entonces el procedimiento es repetido nuevamente con todos los puntos de \(D\).
*   El entrenamiento termina cuando la neurona clasifica correctamente todos los elementos del conjunto de entrenamiento.

Este procedimiento converge, es decir, en un número finito de pasos es posible obtener los parámetros finales que separan entre sí los conjuntos.

Un modelo neuronal utilizado para clasificación, cuya salida está dada de la forma anterior y que utiliza el **método de error-corrección** para modificar sus parámetros libres se conoce como **Perceptron** (el nombre deriva de la palabra en inglés “perception”). Estas neuronas pueden agruparse formando una RNA conocida como **Perceptron múltiple**.

## El Perceptron multicapa

Un caso particular de perceptron múltiple se puede formar organizando sus neuronas en capas. Así, tenemos la **capa de entrada** formada por las entradas a la red, la **capa de salida** formada por las neuronas que constituyen la salida final de la red, y las **capas ocultas** formadas por las neuronas que se encuentran entre los nodos de entrada y de salida. Una RNA puede tener varias capas ocultas o no tener ninguna de ellas. Las conexiones sinápticas (las flechas que llegan y salen de las neuronas) indican el flujo de la señal a través de la red, y tienen asociadas un peso sináptico correspondiente. Si la salida de una neurona va dirigida hacia dos o más neuronas de la siguiente capa, cada una de estas últimas recibe la salida neta de la neurona anterior. La cantidad de capas de una RNA es la suma de las capas ocultas más la capa de salida. En el caso de existir capas ocultas nos referimos a la RNA como un **Perceptron multicapa**.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/be9db638-25fb-11e2-bb76-001e670c2818.gif"/>

El problema habitual con este tipo de redes multicapa es el de, dados un conjunto de datos ya clasificados, de los que se conoce la salida deseada, proporcionar los pesos adecuados de la red para que se obtenga una aproximación correcta de las salidas si la red recibe únicamente los datos de entrada.

<iframe width="180"  height="120" src="https://www.youtube.com/embed/MRIv2IwFTPg" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/uwbHOpp9xkc" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/eNIqz_noix8" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

A mediados de los años 80 se ofreció un algoritmo, llamado de **Propagación hacia atrás**, que aproxima en muchos casos los pesos a partir de los datos objetivo. Este algoritmo de **entrenamiento de la red** se puede resumir muy brevemente en los siguiente puntos:

*   Empezar con unos pesos sinápticos cualesquiera (generalmente elegidos al azar).
*   Introducir datos de entrada (en la capa de entrada) elegidos al azar entre el conjunto de datos de entrada que se van a usar para el entrenamiento.
*   Dejar que la red genere un vector de datos de salida (propagación hacia delante).
*   Comparar la salida generada por al red con la salida deseada.
*   La diferencia obtenida entre la salida generada y la deseada (denominada _error_) se usa para ajustar los pesos sinápticos de las neuronas de la capa de salidas.
*   El error se _propaga hacia atrás_ (back-propagation), hacia la capa de neuronas anterior, y se usa para ajustar los pesos sinápticos en esta capa.
*   Se continua propagando el error hacia atrás y ajustando los pesos hasta que se alcance la capa de entradas.
*   Este proceso se repetirá con los diferentes datos de entrenamiento. 

Entre las diversas tareas en las que una RNA puede aplicarse podemos mencionar la clasificación lineal y no lineal de una cantidad arbitraria \(C_1,\dots,C_m\) de clases, regresión lineal y no lineal, análisis de series temporales, control de procesos, robótica, optimización de funciones, procesamiento de señales, etc...

<iframe width="180"  height="120" src="https://www.youtube.com/embed/FVozZVUNOOA" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

! ### Para saber más...
! [Universidad Carlos III: Redes Neuronales](http://ocw.uc3m.es/ingenieria-informatica/redes-de-neuronas-artificiales)
! [Wikipedia: Redes Neuronales Artificiales](https://es.wikipedia.org/wiki/Red_neuronal_artificial)
! [Xataka: Redes Neuronales Artificiales, ¿qué son y porqué están volviendo?](http://www.xataka.com/robotica-e-ia/las-redes-neuronales-que-son-y-por-que-estan-volviendo)
! [Introducción a las Redes Neuronales Artificiales aplicadas](http://halweb.uc3m.es/esp/Personal/personas/jmmarin/esp/DM/tema3dm.pdf)