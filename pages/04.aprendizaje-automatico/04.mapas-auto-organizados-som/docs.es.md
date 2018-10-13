---
title: 'Mapas Auto-Organizados: SOM'
taxonomy:
    category: docs
visible: true
---

[TOC]  
<img style="float:left;margin:0 10px 10px 0;width:300px" src="http://upload.wikimedia.org/wikipedia/en/0/07/Self_oraganizing_map_cartography.jpg"/> Los **Self Organizing Maps** (**Mapas Auto-Organizados**), o **SOM**, fueron inventados en 1982 por Teuvo Kohonen, profesor de la Academia de Finlandia, y proporcionan una forma de representar datos multidimensionales (vectores) en espacios de dimensión inferior, normalmente, en 2D. Este proceso de reducir la dimensionalidad de vectores es una técnica de compresión de datos conocida como **Cuantización Vectorial**. Además, la técnica de Kohonen crea una red que almacena información de forma que las relaciones topológicas del conjunto de entrenamiento se mantienen.

Un ejemplo habitual que se usa para mostrar cómo funcionan los SOM se basa en la proyección de colores (asociados a vectores 3D formados a partir de, por ejemplo, sus 3 componentes RGB) en un espacio 2D. La siguiente figura muestra un SOM entrenado para reconocer los 8 colores que aparecen a su derecha. En la representación 2D se agrupan colores similares en regiones adyacentes.

<img src="http://www.ai-junkie.com/ann/som/images/Figure1.jpg" />

Uno de los aspectos más interesantes de los SOM es que aprenden a clasificar **sin supervisión**, lo que implica que no necesitamos un objetivo que aproximar, sino que genera la distribución a partir de la similitud entre los vectores.

## Arquitectura en red

En general, el algoritmo SOM considera una arquitectura en 2 capas: por una parte tenemos una capa de **nodos de aprendizaje**, de la que nos importa la relación geométrica que hay entre ellos y que serán los que finalmente contendrán la información acerca de la representación resultante, junto con una capa de **nodos de entrada**, donde se representarán los vectores originales durante el proceso de entrenamiento. Además, todos los elementos de la primera capa están conectados con todos los elementos de la segunda capa. La siguiente figura muestra una posible arquitectura 2D para un entrenamiento SOM, la red de aprendizaje viene representada por los nodos rojos, y los vectores de entrenamiento vienen representados en verde. Como en muchos sistemas similares, la idea del algoritmo consistirá en encontrar los pesos adecuados de las conexiones entre ambas capaz para dar una "representación" adecuada de los datos de entrada en la estructura geométrica de los nodos de aprendizaje.

<img src="http://www.ai-junkie.com/ann/som/images/Figure2.jpg"/>

En realidad, como no nos importa la representación geométrica ni topológica de los nodos de entrada, es común que solo se de una representación en la que aperecen los nodos de aprendizaje y los pesos asociados a cada uno de ellos se muestran como un vector de pesos (cada elemento de este vector es el peso de la conexión con el correspondiente nodo de entrada). De esta forma, si la capa de entrada tiene tamaño \(n\) (que es la dimensión del espacio original), cada nodo de aprendizaje tendrá un vector de pesos, \(W\), de dimensión \(n\). 

## Algoritmo de Aprendizaje

A grandes rasgos, ya que no hay vector objetivo al que aproximarse, lo que se hace es que, en aquellas zonas en las que la red tiene nodos con pesos que coinciden con vectores de entrenamiento, el resto de nodos de su entorno tienden a aproximarse también a ese mismo vector. De esta forma, partiendo de una dstribución de pesos inicial (normalmente aleatorios), el SOM tiende a aproximarse a una distribución de pesos estable. Cada una de estas zonas que se estabiliza se convierte en un clasificador de propiedades, de forma que la red se convierte en una salida que representa una aplicación de clasificación. Una vez estabilizada la red, cualquier vector nuevo estimulará la zona de la red que tiene pesos similares.

De forma más detallada, los pasos que se siguen para el proceso de entrenamiento son:

1.  Cada nodo se inicializa con un peso (aleatorio). Normalmente, vectores en \([0,1]^n\),
    
2.  Se selecciona al azar un vector del conjunto de entrenamiento.
    
3.  Se calcula el nodo de la red que tiene el peso más similar al vector anterior, que notaremos como **Best Matching Unit** (BMU). Para ello, simplemente se calculan las distancias euclídeas entre los vectores \(W\) de cada nodo y el vector de entrenamiento (por motivos de eficiencia, no se aplica la raíz cuadrada al cálculo de la distancia euclídea, cosa que no afecta para calcular el mínimo).
    
4.  Se calcula el radio del **entorno de BMU**. Este radio comenzará siendo grande (como para cubrir la red completa) y se va reduciendo en cada iteración.
    
5.  Cada nodo del entorno de BMU ajusta su peso para parecerse al vector de entrenamiento seleccionado en el paso 2, de forma que los nodos más cercanos al BMU se vean más modificados.
    
6.  Repetir desde el paso 2 (el número de iteraciones que se considere necesario).
    

La fórmula que establece el radio en función de la iteración (que hace que vaya disminuyendo, pero no linealmente) es:

$r(t)=r_0 e^{-\frac{t}{\lambda} }$

donde \(r_0\) es el radio inicial (habitualmente, el radio de la red, es decir, uno suficiente para cubrir en el primer paso todos los nodos) y \(\lambda\) una constante que permite hacer que el radio sea muy pequeño cuando llegamos a la iteración máxima:

$\lambda= \frac{Tiempo\_de\_Entrenamiento}{\ln r_0}$

La siguiente figura muestra el efecto de ir reduciendo paulatinamente el radio del entorno, donde se marcan los nodos que se verían afectados si el nodo BMU es el nodo amarillo:

<img src="http://www.ai-junkie.com/ann/som/images/Figure5.jpg"/>

Para aproximar los pesos (\(W\)) de los nodos del entorno al vector de entrenamiento (\(V\)) usamos la modificación que sugiere la fórmula siguiente:

$W(t+1) = W(t) + L(t) (V(t)-W(t))$

El factor \(L(t)\) se denomina **tasa de aprendizaje**, y permite aproximar \(W\) a \(V\) con el paso del tiempo. Como queremos que su valor también disminuya a medida que el tiempo pasa, podemos usar una expresión similar a la del radio:

$L(t)=L_0 e^{-\frac{t}{\lambda} }$

El valor de \(L_0\) se ajusta experimentalmente, nosotros usaremos el valor \(0.1\). Además, y con el fin de que el efecto de aprendizaje sea más notable en las cercanías del BMU, añadiremos un factor más al producto anterior, que hace que los nodos más cercanos al BMU se vean más afectados:

$W(t+1) = W(t) + D(t) L(t) (V(t)-W(t))$

Por ejemplo, haciendo que \(D(t)\) siga una gaussiana de la forma:

$D(t)=e^{-\frac{d^2}{2r^2(t)} }$

donde \(d\) es la distancia del nodo que estamos ajustando al BMU (centro del entorno).

## Ejemplo de Aplicación

Los SOM se usan habitualente para proporcionar ayudas visuales, ya que permiten mostrar relaciones entre grandes cantidades de datos y que precisarían muchas más dimensiones (algo inviable para el ser humano) para ser mostradas adecuadamente. Con el fin de trabajar con una topología en los nodos que refleje un mayor número de conexiones entre ellos, pero sea realista desde un punto de vista 2D, es habitual trabajar con un teselado hexagonal del plano, identificando los hexágonos con los nodos de la red.

**Paises organizados según su nivel de pobreza**

Según los diversos factores que se usan para medir la calidad de vida de los países, podemos usar SOM para representar las agrupaciones que forman los diversos países en una red 2D.

<img src="http://www.ai-junkie.com/ann/som/images/povertymap.jpg"/>

Junto a la representacion anterior, una vez extraídos los colores, podemos volver a proyectar los países en un mapa estándar, de forma que visualmente podamos interpretar simultáneamente la información geográfica con la procedente de los datos anteriores:

<img src="http://www.ai-junkie.com/ann/som/images/worldpovertymap.jpg"/>

En general, los SOM se pueden usar para representar datos complejos de una forma muy visual, ya que las relaciones abstractas se destacan como relaciones de carcanía y por colores... desde relaciones semánticas hasta estructuras topológicas.

### Clasificación de animales

Supongamos ahora que tenemos la siguiente tabla de información acerca de las propiedades de un conjunto de animales:

|    |Paloma|Gallina|Pato|Ganso|Buho|Halcón|Águila|Zorro|Perro|Lobo|Gato|Tigre|León|Caballo|Cebra|Vaca|
|---|-----------|---------|------|---------|-------|---------|---------|------|--------|-------|-------|------|------|-----------|--------|------|
Pequeño|Sí|Sí|Sí|Sí|Sí|Sí|No|No|No|No|Sí|No|No|No|No|No|
Medio|No|No|No|No|No|No|Sí|Sí|Sí|Sí|No|No|No|No|No|No|
Grande|No|No|No|No|No|No|No|No|No|No|No|Sí|Sí|Sí|Sí|Sí|
2 patas|Sí|Sí|Sí|Sí|Sí|Sí|Sí|No|No|No|No|No|No|No|No|No|
4 patas|No|No|No|No|No|No|No|Sí|Sí|Sí|Sí|Sí|Sí|Sí|Sí|Sí|
Pelo|No|No|No|No|No|No|No|Sí|Sí|Sí|Sí|Sí|Sí|Sí|Sí|Sí|
Pezuñas|No|No|No|No|No|No|No|No|No|No|No|No|No|Sí|Sí|Sí|
Melena|No|No|No|No|No|No|No|No|No|Sí|No|No|Sí|Sí|Sí|No|
Plumas|Sí|Sí|Sí|Sí|Sí|Sí|Sí|No|No|No|No|No|No|No|No|No|
Caza|No|No|No|No|Sí|Sí|Sí|Sí|No|Sí|Sí|Sí|Sí|No|No|No|
Corre|No|No|No|No|No|No|No|No|Sí|Sí|No|Sí|Sí|Sí|Sí|No|
Vuela|Sí|No|No|Sí|Sí|Sí|Sí|No|No|No|No|No|No|No|No|No|
Nada|No|No|Sí|Sí|No|No|No|No|No|No|No|No|No|No|No|No|

Usando las columnas anteriores como vectores de entrenamiento, y un tamaño adecuado del mundo para que los vectores puedan distribuirse en él con comodidad, podemos obtener una clasificación 2D de los elementos a los que caracterizan (animales), dando relaciones de similaridad (clasificándose) automáticamente:

<img src="http://www.cs.us.es/~fsancho/images/2016-05/som-hexaclassifierview.png"/>

Al igual que en el caso anterior, se normalizan las componentes de los vectores (ya están normalizados, convirtiendo No = 0, Sí = 1) y se generan pesos al azar con componentes aleatorias entre 0 y 1. En este caso, debido a que cada vector tiene 13 componentes, usamos sólo las 3 primeras para dar una ligera clasificación por colores, pero no reflejan la información adicional que hay en los pesos reales que se usan en el algoritmo.

Puede observarse que la clasificación tiene sentido, ya que agrupa de forma coherente animales que consideramos similares por causas diversas.

<iframe width="180"  height="120" src="https://www.youtube.com/embed/ipH_Df2MbPI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/b3nG4c2NECI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/sBK89IpyVdE" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/8tnxgfE6glI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Preprocesado de Datos

<img style="float:left;margin:0 10px 10px 0;width:400px" src="http://www.datapreparator.com/_Media/kddpicture-3.jpeg"/> Rara vez los conjuntos de datos sirven tal como nos los dan, ya que es habitual encontrar que vienen dados en escalas muy diferentes, con altos grados de variabilidad (y diferente para cada atributo almacenado), e incluso con distintos tipos de datos, donde algunos son numéricos y otros categóricos. Por eso, normalmente, y antes de realizar el entrenamiento, hay que realizar algún tipo de _preprocesamiento_ que tiene como objetivo conseguir que todas las variables tengan aproximadamente el mismo rango y la misma desviación estándar. Una de las formas para conseguir esto es el siguiente:

*   Convertir variables categóricas que tengan \(n\) posibles valores (categorías) en \(n\) variables distintas. Los valores de estas variables dependerán de cómo hayamos preprocesado el resto del fichero, pero normalmente se pondrá al valor máximo de la normalización en caso de que la variable corresponda a esa categoría y al valor mínimo en caso de que no.
*   Normalizar las columnas numéricas restando la media y dividiento por la desviación estándar. Así todas las variables tendrán la mayor parte de sus valores entre -1 y 1.

Otros preprocesos posibles consisten en aplicar logaritmos en caso de que el rango de variación pase por varios órdenes de magnitud, o restar el mínimo y dividir por el rango de variación, para dar diferentes variables en el rango $[0,1]$. Aún así, cuando se trata de variables con distribución muy desigual, es habitual que los modelos obtenidos no sea excesivamente buenos, y habría que someterlos a algún preproceso adicional, que será totalmente heurístico (es decir, hecho ad hoc), y que puede incluir la eliminación de algunas de las variables, algún proceso estadístico adicional sobre el conjunto resultante y ejecuciones preliminares del algoritmo para comprobar los resultados que se consiguen.

En cualquier caso, lo más importante del preproceso es no desvirtuar las relaciones métricas entre los diferentes valores de los atributos, ya que un mal preprocesado puede dar lugar a artefactos (es decir, características no presentes en los datos iniciales) en los resultados del algoritmo. Por ejemplo, si las categorías de una variable categórica son totalmente diferentes, el vector que represente cada categoría tendrá que hacerse de forma que la distancia a todas las demás sea la misma. Sin embargo, con variables que tengan una distancia "natural", por ejemplo, variables del tipo mediano, pequeño, grande, habrá que convertirlas a números enteros, o a valores numéricos que mantengan esa misma relación de proximidad entre ellas.

! ### Para saber más...
! [Self-Organizing Maps Research Lab](http://www.cis.hut.fi/research/som-research/)
! [World Poverty Map](http://www.cis.hut.fi/research/som-research/worldmap.html)
! [Self-Organizing Maps](http://davis.wpi.edu/~matt/courses/soms/)
! [Self-Organizing Maps for Pictures](http://www.generation5.org/content/2004/aiSomPic.asp)
! [SOM Tutorial](http://www.ai-junkie.com/ann/som/som5.html)