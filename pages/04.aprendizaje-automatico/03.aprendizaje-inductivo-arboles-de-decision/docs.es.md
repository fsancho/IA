---
title: 'Aprendizaje Inductivo: Árboles de Decisión'
taxonomy:
    category: docs
visible: true
---

[TOC]
<img style="float:left;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2018-01/grexit-decision-tree-1.png"/> Entre los diversos tipos de aprendizaje que podemos diferenciar, destaca el **aprendizaje inductivo**, que se basa en el descubrimiento de patrones a partir de ejemplos. Desde el punto de vista de la clasificación, la tarea general consiste en lo siguiente:

Supongamos que disponemos de N ejemplos observados en el mundo real, \(\{e_1,\dots, e_N\}\), que vienen definidos a partir de un conjunto de atributos (propiedades), \(e_i=(p_{i1},\dots,p_{im})\), y para cada uno de ellos tenemos una clasificación observada, \(c_i\). La tarea del aprendizaje inductivo consiste en inducir de los datos anteriores un mecanismo que nos permita inferir las clasificaciones de cada uno de los ejemplos a partir únicamente de las propiedades. Si esto es posible, podríamos usar este mecanismo para deducir la clasificación de nuevos ejemplos habiendo observado únicamente sus propiedades.

Es evidente que obtener un mecanismo como este sería muy útil debido a que podríamos predecir comportamientos futuros a partir de los comportamientos observados en el pasado. Por ejemplo, a partir de los síntomas que tenemos observados en enfermos anteriores, y sabiendo ya si han desarrollado o no cierta enfermedad, podríamos extraer patrones que nos permitieran predecir si un paciente nuevo, aquejado de ciertos síntomas, desarrollará o no la misma enfermedad, lo que nos permitiría adelantarnos a su tratamiento. Otro ejemplo que es muy usado en la actualidad se encuentra en el mundo de los créditos bancarios, a partir de los comportamientos de los clientes antiguos con respecto a la morosidad o no de sus pagos del crédito concedido, podemos inferir qué nuevos clientes pueden ser los más convenientes para la concesión de un crédito, es decir, cuáles de ellos tienen más probabilidad de hacer frente al pago del mismo y cuáles más probabilidad de dejarlo sin pagar.

Aunque los resultados que se obtienen dependen de la calidad de los ejemplos introducidos (que sea una cantidad suficiente, que representen fielmente el comportamiento de la población no observada, que no muestren contradicciones internas, etc.), sin lugar a dudas este mecanismo de descubrimiento de patrones se ha convertido en los últimos años en una de las fuentes más fiables de predicciones y su uso se ha extendido velozmente.

Entre todos los posibles mecanismos para obtener estas predicciones de manera fiable, una de las que más destaca es la creación de **árboles de decisión**, que proporcionan un conjunto de reglas que se van aplicando sobre los ejemplos nuevos para decidir qué clasificación es la más adecuada a sus atributos.

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id31.jpg"/>

Un **árbol de decisión** está formado por un conjunto de nodos de decisión (interiores) y de nodos-respuesta (hojas):

*   Un **nodo de decisión** está asociado a uno de los atributos y tiene 2 o más ramas que salen de él, cada una de ellas representando los posibles valores que puede tomar el atributo asociado. De alguna forma, un nodo de decisión es como una pregunta que se le hace al ejemplo analizado, y dependiendo de la respuesta que de, el flujo tomará una de las ramas salientes.
*   Un **nodo-respuesta** está asociado a la clasificación que se quiere proporcionar, y nos devuelve la decisión del árbol con respecto al ejemplo de entrada.

El ejemplo anterior (el más clásico de los que se pueden encontrar) muestra la tabla de ejemplos que hemos observado a lo largo del tiempo respecto a las condiciones meteorológicas y la posibilidad de jugar al golf o no. El árbol de la derecha muestra un posible mecanismo aprendido para poder tomar decisiones para esta tarea de clasificación. Observa en el árbol está formado únicamente por los nodos azul oscuro (nodos de decisión) y los de color amarillo (nodos-respuesta), mientras que los rectángulos azules claro son simplemente las etiquetas de las ramas de salida de cada nodo de decisión, indicando cuál es la opción que verifica nuestro ejemplo.

Es evidente que no siempre podremos conseguir un árbol de decisión que sea capaz de predecir los ejemplos con una fiabilidad del 100%, pero cuanto mejor sea la batería de ejemplos de los que disponemos (por ejemplo, que no haya contradicciones entre clasificaciones), mejor se comportará el árbol que podemos construir a partir de ellos.

## El algoritmo ID3

Evidentemente, la construcción del árbol de decisión no es única, y si aplicamos una estrategia u otra a la hora de decidir en qué orden se hacen las preguntas sobre los atributos podemos encontrar árboles muy dispares. De entre todos los posibles árboles, estamos interesados en encontrar aquellos que cumplan las mejores características como máquinas de predicción, e intentaremos dar un mecanismo automático de construcción del árbol a partir de los ejemplos.

<img style="float:left;margin:0 10px 10px 0;" src="http://history-computer.com/ModernComputer/thinkers/images/shannon.jpg"/> En el año 1979, J. Ross Quinlan presenta un método para construir árboles de decisión que presentan muy buenas características, como son un buen balanceado y un tamaño pequeño (el menor número de preguntas posibles para poder encontrar la respuesta en todos los casos, si es posible). Para ello, hace uso de la **Teoría de la Información** desarrollada por C. Shannon en 1948. Aunque el mérito se le asocia a este autor, de forma paralela aparecieron varios métodos de construcción que eran prácticamente equivalentes. El algoritmo de construcción que presenta se llama **ID3**, y hasta el momento ha sido el más utilizado y en el que se han basado mejoras posteriores introducidas por el mismo Quinlan y por otros autores.

El ID3 construye un árbol de decisión de arriba a abajo, de forma directa, sin hacer uso de backtracking, y basándose únicamente en los ejemplos iniciales proporcionados. Para ello, usa el concepto de **Ganancia de Información** para seleccionar el atributo más útil en cada paso. En cierta forma, sigue un método voraz para decidir la pregunta que mayor ganancia da en cada paso, es decir, aquella que me permite separar mejor los ejemplos entre sí respecto a la clasificación final.

Para poder aplicar el algoritmo hemos de comenzar sabiendo cómo se mide la ganancia de información, y para ello hay que introducir el concepto de **Entropía de Shannon**, que de alguna forma mide el grado de **incertidumbre** de una muestra.

Vamos a ver con detalle cómo se define el problema de ID3.

*   Las **entradas** son un conjunto de _ejemplos_ descritos mediante una serie de pares _atributo-valor_. Podemos pensar en ellos como una tabla en la que cada fila representa un ejemplo completo, y cada columna tiene el valor almacenado de cada uno de sus posibles atributos. Uno de esos atributos, generalmente el último de la tabla, debe almacenar la clasificación (_clase_) que corresponde con el ejemplo.

<img src="http://www.cs.us.es/~fsancho/images/2016-12/obras2.png"/>

*   La **salida** será un _árbol de decisión_ que separa a los ejemplos de acuerdo a las clases a las que pertenecen.

En definitiva, el algoritmo responde a un esquema clásico de clasificación en el que se imponen dos requisitos para las clases:

*   **Clases predefinidas**: Se parte de un problema de aprendizaje supervisado en el que el atributo que hace las veces de clase está perfectamente identificado de antemano y se conoce para todos los ejemplos iniciales.
*   **Clases discretas**: Se exige que haya un conjunto discreto y finito de clases que sirven para clasificar claramente todos los ejemplos presentados. Aunque hay variantes que permiten trabajar con clases con valores continuos, no se estudiará en esta entrada.

Además, se supone que el número de ejemplos presentados tiene que ser muy superior al de posibles clases, ya que el proceso de aprendizaje que vamos a ver se basa en un análisis estadísitico que puede arrojar errores en caso contrario. Un problema real puede requerir cientos o miles de ejemplos de entrenamiento.

### Entropía de Shannon

Supongamos que miramos cómo de homogéneos son los ejemplos de los que queremos aprender respecto a la clasificación:

*   Una **muestra completamente homogénea** (es decir, en la que todos se clasifican igual) tiene incertidumbre mínima, es decir, no tenemos dudas de cuál es la clasificación de cualquiera de sus elementos (si elegimos al azar cualquier de ellos, sabremos qué resultado tendremos). En este caso, fijaremos la incertidumbre (entropía) a \(0\).
*   Una **muestra igualmente distribuida**, es decir, que tiene el mismo número de ejemplos de cada posible clasificación, muestra una incertidumbre máxima, en el sentido de que es la peor situación para poder saber a priori cuál sería la clasificación de unos de sus ejemplos elegido al azar. Así pues, en este caso fijaremos la incertidumbre (entropía) a \(1\).

Con estos requisitos, y algunas propiedades más que hemos de añadir para que se comporte bien, buscamos dar una definición matemática de la entropía que nos sirva para medir la incertidumbre de un sistema. Shannon llega a la conclusión de que la mejor función matemática que mide este grado de incertidumbre es la siguiente:

\(E(S)=\sum_{i=1}^C -p_i \log_2(p_i)\)

donde \(S\) es el conjunto de muestras (el sistema analizado), \(C\) es el número de diferentes clasificaciones que usamos, y cada \(p_i\) es la proporción de ejemplos que hay de la clasificación \(i\) en la muestra.

<img style="float:right;margin:0 10px 10px 0;" src="http://www.cs.us.es/~fsancho/images/2016-12/entropia.png"/> En el caso particular de una clasificación binaria (ejemplos positivos / negativos), la fórmula anterior queda como:

\(E(S)=-P \log_2(P) - N \log_2(N)\)

donde \(P\) y \(N\) son, respectivamente, la proporción de ejemplos positivos y negativos. La figura adjunta muestra la variación de la función entropia en función de una de las dos opciones (en el caso explicado de tener 2 posibles opciones). 

(Recordemos que \(log_2(a)=\log_{10}(a) / \log_{10}(2)\), y que debido a que no está definido el \(\log_x(0)\), tomaremos siempre que \(0 \log_2(0) = 0\) en la suma anterior.)

### Aplicación de la Entropía a ID3

En el ejemplo presentado en la tabla anterior (la del juego de golf), la entropía que tiene el sistema respecto a la clasificación de si se juega al golf o no es la siguiente:

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id32.jpg"/>

Una vez definida matemáticamente la incertidumbre, entropía, tenemos más fácil entender qué es la información. Decimos que tenemos información acerca de un sistema cuando estamos más alejados de la incertidumbre, por tanto, la ganancia de información consiste en un decremento de la entropía del sistema. En nuesto caso, cuando dividimos la muestra respecto a los valores de cualquiera de los atributos conseguimos que la entropía del sistema disminuya.

¿Qué atributo crea las ramas más homogéneas y, por tanto, proporciona una ganancia de información mayor? Respondiendo a esta pregunta obtendríamos cuál sería la mejor pregunta posible en un determinado momento, para ello:

*   Se calcula la entropía del total.
*   Se divide el conjunto de datos en función de los diferentes atributos.
*   Se calcula la entropía de cada rama y se suman proporcionalmente las ramas para calcular la entropía del total:

\(E(T,X)=\sum_{c\in X}p(c)E(S_c)\)

*   Se resta este resultado de la entropía original, obteniendo como resultado la Ganancia de Información (descenso de entropía) usando este atributo.

\(Gain(T,X)=E(T)-E(T,X)\)

*   El atributo con mayor Ganancia es selecciona como nodo de decisión.

Una rama con entropía \(0\) se convierte en una hoja (nodo-respuesta), ya que representa una muestra completamente homogénea, en la que todos los ejemplos tienen la misma clasificación. Si no es así, la rama debe seguir subdividiéndose con el fin de clasificar mejor sus nodos.

El algoritmo ID3 se ejecuta recursivamente en nodos que no sean de respuesta (hojas) hasta llegar al caso de entropía nula. Las siguientes figuras muestran el proceso que hay que seguir para dar un paso completo en el ejemplo anterior. Recordemos que inicialmente, antes de realizar ninguna división por atributos, la entropía del sistema es:

<img  src="http://www.cs.us.es/~fsancho/images/2015-07/id33.jpg"/>

Calculemos la ganancia que obtendríamos si hicieramos una división usando el primer atributo (Outlook):

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id34.jpg"/>

Y se repite con cada uno de los atributos que tienen los ejemplos:

<img  src="http://www.cs.us.es/~fsancho/images/2015-07/id35.jpg"/>

Y nos quedamos con el atributo que proporciona mayor ganancia (en este caso, Outlook), con lo que tenemos construido el primer paso del árbol de decisión, identificando el primer nodo de decisión:

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id37.jpg"/>

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id38.jpg"/>

A continuación nos situamos en cada uno de los subconjuntos de ejemplos que define cada valor del atributo seleccionado y repetimos el proceso, construyendo poco a poco el árbol completo de decisión. Un nodo que tenga entropía nula se convierte en un nodo respuesta, ya que representa una muestra homogénea en el que la clasificación final es la misma para todos los ejemplos que contiene:

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id39.jpg"/>

<img src="http://www.cs.us.es/~fsancho/images/2015-07/id310.jpg"/>

Uno de los aspectos más interesantes que nos ofrecen los árboles de decisión como máquinas de predicción es que nos permiten explicar porqué un determinado ejemplo se clasifica de una cierta forma, y podemos extraer un procedimiento que se implementa fácilmente en cualquier sistema haciendo uso de reglas condicionales.

<img  src="http://www.cs.us.es/~fsancho/images/2015-07/id311.jpg"/>

<iframe width="180"  height="120" src="https://www.youtube.com/embed/ioX_DlrgOLA" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/PxPKZA87EXU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/q_ZFEtZdyF4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Extensiones de ID3
Como hemos visto, la heurística del ID3 es de búsqueda y consiste en preferir árboles que tengan atributos con mayor información más cerca de la raíz, y árboles más cortos, siguiendo la hipótesis de la **navaja de Occam** (preferir siempre las hipótesis más sencillas que describan los datos). También, por la heurística que emplea, favorece atributos con muchos valores.

Ya desde el principio Quinlan se dio cuenta de que el algoritmo ID3 era una primera aproximación que no cubría todos los casos que nos podíamos encontrar. Entre otros, destacan los siguientes problemas:

*   Está bien definido para aquellos atributos que podían tener un rango finito de valores (lo que se llaman "**atributos categóricos**"), pero no se puede usar para otros casos, por ejemplo cuando un atributo es numérico y puede tomar una cantidad infinita de posibles valores.
*   Además, no siempre da el mejor árbol posible, ya que se basa en un método voraz que optimiza cada paso por separado, pero quizás hay otras opciones en el orden de preguntas que, aunque inicialmente no sean las más óptimas localmente y no aporten la mayor ganancia inmediata, sí pueden ofrecer un resultado global más óptimo.
*   Por último, no se comporta bien con ejemplos para los que se desconoce el valor de alguno de sus atributos.

Para resolver estos problemas, el propio Quinlan propone el **algoritmo C4.5** como una extensión del ID3, y poco después el **C5.0** como versión más optimizada y completa (aunque también, con licencia comercial). Veremos a continuación cómo se pueden resolver los problemas anteriores de una forma relativamenrte sencilla (aunque quizás no sea la opción más óptima, sí que podremos implementarla muy sencillamente).

Respecto a la falta de información en algunos atributos de algunos ejemplos, la solución más directa es hacer uso en cada paso de aquellos ejemplos en los que sí hay información respecto al atributo que se está estudiando, de manera que tanto para el cálculo de la entropía como de las probabilidades asociadas se tengan en cuenta los que tienen ese atributo conocido. Es una ligera modificación del ID3 que se podría haber incluído directamente.

Respecto a encontrar variantes no voraces que den soluciones más óptimas globalmente, es un problema sin solución eficiente. Se sabe que este problema, el de la optimalidad global en los árboles de decisión, es un problema NP-completo, es decir, que está dentro de un importante conjunto para los que no se conoce solución eficiente (en el mejor de los casos, solo exponencial) y para los que es muy probable que dicha solución no exista. Así que podremos aplicar algunas heurísticas para mejorar un poco el ID3 (es lo que hacen C4.5 y C5.0), pero sabiendo que no conseguiremos una solución óptima en todos los casos.

Es mucho más interesante el tratamiento del problema de los atributos con infinitos valores. En el caso general, el problema consiste en ver qué pregunta se puede hacer respecto de estos atributos para dividir el conjunto de ejemplos de la forma más homogénea posible. Evidentemente, si disponemos de infinitos valores, se pueden hacer infinitas preguntas, por lo que el método de buscar entre todas ellas la mejor para la ganancia es inviable. Aquí disponemos de otras soluciones, dependiendo de qué estructura tenga ese atributo.

*   <img style="float:right;margin:0 10px 10px 0;width:300px" src="http://sherrytowers.com/wp-content/uploads/2013/10/kmeans_1.jpg"/> Si el atributo es de tipo general (depende de varias dimensiones, o no es un conjunto ordenado), podemos aplicar métodos de clusterización  (por ejemplo, algo parecido al algoritmo de las K-medias) para poder saber en qué bolsas se puede dividir de forma eficiente, y entonces utilizar como preguntas la pertenencia a una bolsa o no. Con este método podemos fijar el número de bolsas a priori, o hacerlo de forma dinámica, por lo que realmente estamos proyectando el atributo con infinitos valores en un nuevo atributo categórico. Este método se puede utilizar cuando el atributo toma valores en un conjunto numérico ordenado, como por ejemplo los números naturales o reales, pero en este caso existe otra solución que puede funcionar mejor.
*   La solución que se puede dar para el caso númerico habitual es mucho más sencilla. Si tenemos los \(N\) ejemplos, y estos toman los valores \(\{v_1,\dots,v_N\}\) en el atributo continuo que estamos estudiando, podemos trabajar con las \(N\) preguntas posibles de la forma "\(x\leq v_i\)". Con estas \(N\) se suelen conseguir resultados suficientemente buenos, y hay métodos para que el cálculo de la ganancia de información se pueda hacer sencilla y reutilizando los casos ya calculados. En estos casos, una solución habitual pasa por ordenar los ejemplos en función de este atributo, y analiza dónde se producen los cambios de clasificación.

<img src="http://www.frontiersin.org/files/Articles/54507/fnins-07-00133-HTML/image_m/fnins-07-00133-g005.jpg"/>

Hay otra consideración que puede ser interesante, y es el tratamiento de árboles que, debido a ruido en los datos, genera algún error en la clasificación incluso para los datos de entrenamiento. Uno de los tratamientos más habituales para reducir el error, o incluso para reducir el árbol sin afectar al error, es el que se conoce como **Poda**, y se realiza tras la construcción del árbol completo (hay métodos para realizar podas a medida que se va construyendo el árbol de decisión).

El método de poda del árbol consiste en generar el árbol tal y como hemos visto y, a continuación, analizar recursivamente, y desde las hojas, qué preguntas (nodos interiores) se pueden eliminar sin que se incremente el error de clasificación con el conjunto de test. Es decir, supongamos que se tiene un error calculado con todo el árbol de \(e_a\), y supongamos que se elimina un nodo interior cuyos sucesores son todos nodos hoja. Calculamos el error que se comete con este nuevo árbol sobre el conjunto de test. Si este error es menor que \(e_a\), entonces compensa eliminar el nodo y todos sus sucesores (hojas). Se continua recursivamente realizando este análisis hasta que no se puede eliminar ningún nodo interior adicional sin incrementar el error.

Esta poda también se podría realizar sobre el conjunto de reglas obtenidas a partir del árbol, ya que su uso es equivalente a trabajar con el árbol completo.

Como conclusión, desde el punto de vista de la búsqueda, el ID3 busca hipótesis en un espacio de búsqueda completo. En cada momento, mantiene una hipótesis única, suponiendo que el clasificador se puede representar como una disyunción de conjunciones. Esto le hace perder oportunidades, como, por ejemplo, cómo seleccionar el siguiente ejemplo, pero le hace ser más eficiente. Al utilizar un procedimiento voraz, por escalada de la colina, no realiza retrocesos por lo que se pueden alcanzar mínimos locales. Sin embargo, si no se tiene ruido y se tienen todos los atributos relevantes, se llega al mínimo global. Por otro lado, la heurística se basa en cálculos estadísticos sobre el conjunto de entrenamiento, lo que lo hace robusto al ruido: si un ejemplo es incorrecto, la estadística suavizará el efecto de ese ejemplo en el cálculo global. Por todas estas características, ha sido una de las técnicas más utilizadas en las aplicaciones de análisis de datos y de aprendizaje automático aplicado a tareas tan diversas como predicción de enfermedades, control de robots, o caracterización de clientes en bancos o entidades de seguros, y hoy en día sigue teniendo relevancia al ser usado como unidad simple para la construcción de métodos combinados de aprendizaje, como son los Random Forest.

! ### Para saber más...
! [Decision Trees](http://dms.irb.hr/tutorial/tut_dtrees.php)
! [Transparencias Algoritmo ID3](http://www.itnuevolaredo.edu.mx/takeyas/Apuntes/Inteligencia%20Artificial/Apuntes/IA/ID3.pdf)
! [Apuntes Algoritmo ID3](http://banzai-deim.urv.net/~riano/teaching/id3-m5.pdf)
! [Induction of decision trees (J.R.Quinlan,1985)](http://hunch.net/~coms-4771/quinlan.pdf)
! [Árboles de decisión (Miguell Cárdenas Montes)](http://wwwae.ciemat.es/~cardenas/docs/lessons/ArbolesDeDecision.pdf)
