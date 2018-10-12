---
title: 'Heurísticas en PSR'
taxonomy:
    category: docs
visible: true
---

[TOC]
## Heurísticas

Los algoritmos de búsqueda para PSR vistos hasta el momento requieren el orden en el cual se van a estudiar las variables, así como el orden en el que se van a instanciar los valores de cada una de las variables. Seleccionar el orden correcto de las variables y de los valores puede mejorar notablemente la eficiencia de resolución. De igual forma, puede resultar importante una ordenación adecuada de las restricciones del problema.

Veamos algunas de las más importantes heurísticas de ordenación de variables y de ordenación de valores.

### Ordenación de Variables

Muchos resultados experimentales han mostrado que el orden en el cual las variables son asignadas durante la búsqueda puede tener una impacto significativo en el tamaño del espacio de búsqueda explorado. Generalmente, las heurísticas de ordenación de variables tratan de seleccionar lo antes posible las variables que más restringen a las demás. La intuición indica que es mejor tratar de asignar lo antes posible las variables más restringidas y de esa manera identificar las situaciones sin salida lo antes posible y así reducir el número de vueltas atrás.

La ordenación de variables puede ser estática y dinámica. Las heurísticas de ordenación de variables estáticas generan un orden fijo de las variables antes de iniciar la búsqueda, basado en información global derivada del grafo de restricciones inicial. Las heurísticas de ordenación de variables dinámicas pueden cambiar el orden de las variables dinámicamente basándose en información local que se genera durante la búsqueda.

**Heurísticas de ordenación de variables estáticas**

Se han propuesto varias heurísticas de ordenación de variables estáticas. Estas heurísticas se basan en la información global que se deriva de la topología del grafo de restricciones original que representa el PSR:

1.  **Minimum Width (MW)**: La anchura de la variable \(x\) es el número de variables que están antes de \(x\), de acuerdo a un orden dado, y que son adyacentes a \(x\). La anchura de un orden es la máxima anchura de todas las variables bajo ese orden. La anchura de un grafo de restricciones es la anchura mínima de todos los posibles ordenes. Después de calcular la anchura de un grafo de restricciones, las variables se ordenan desde la última hasta la primera en anchura decreciente. Esto significa que las variables que están al principio de la ordenación son las más restringidas y las variables que están al final de la ordenación son las menos restringidas. Asignando las variables más restringidas al principio, las situaciones sin salida se pueden identificar antes y además se reduce el número de vueltas atrás.
2.  **Maximun Degree (MD)**: ordena las variables en un orden decreciente de su grado en el grafo de restricciones. El grado de un nodo se define como el número de nodos que son adyacentes a él. Esta heurística también tiene como objetivo encontrar un orden de anchura mínima, aunque no lo garantiza.
3.  **Maximun Cardinality (MC)**: selecciona la primera variable arbitrariamente y después en cada paso, selecciona la variable que es adyacente al conjunto más grande de las variables ya seleccionadas.

**Heurísticas de ordenación de variables dinámicas**

El problema de los algoritmos de ordenación estáticos es que no tienen en cuenta los cambios en los dominios de las variables causados por la propagación de las restricciones durante la búsqueda, o por la densidad de las restricciones. Esto se debe a que estas heurísticas generalmente se utilizan en algoritmos de comprobación hacia atrás donde no se lleva a cabo la propagación de restricciones.

Se han propuesto varias heurísticas de ordenación de variables dinámicas que abordan este problema. La más común se basa en el **principio del primer fallo** (**FF**) que sugiere que para tener éxito deberíamos intentar primero donde sea más probable que falle. De esta manera las situaciones sin salida pueden identificarse antes y además se ahorra espacio de búsqueda. De acuerdo con el principio de FF, en cada paso seleccionaríamos la variable más restringida.

La heurística FF también conocida como **heurística Minimum Remaining Values (MRV)**, trata de hacer lo mismo seleccionando la variable con el dominio más pequeño. Se basa en la intuición de que si una variable tiene pocos valores, entonces es más difícil encontrar un valor consistente. Cuando se utiliza MRV junto con algoritmos look-back, equivale a una heurística estática que ordena las variables de forma ascendente con el tamaño del dominio antes de llevar a cabo la búsqueda. Cuando MRV se utiliza en conjunción con algoritmos look-ahead, la ordenación se vuelve dinámica, ya que los valores de las futuras variables se pueden podar después de cada asignación de variables. En cada etapa de la búsqueda, la próxima variable a asignarse es la variable con el dominio más pequeño.

Algunos resultados experimentales prueban que todas las heurísticas de ordenación de variables estáticas son peores que el algoritmo MRV.

### Ordenación de Valores

Se ha realizado poco trabajo sobre heurísticas para la ordenación de valores. La idea básica que hay detrás de las heurísticas de ordenación de valores es seleccionar el valor de la variable actual que más probabilidad tenga de llevarnos a una solución. La mayoría de las heurísticas propuestas tratan de seleccionar el valor menos restringido de la variable actual, es decir, el valor que menos reduce el número de valores útiles para las futuras variables.

Una de las heurísticas de ordenación de valores más conocidas es la **heurística min-conflicts**. Básicamente, esta heurística ordena los valores de acuerdo a los conflictos en los que éstos están involucrados con las variables no instanciadas. Esta heurística asocia a cada valor \(a\) de la variable actual, el número total de valores en los dominios de las futuras variables adyacentes que son incompatibles con \(a\). El valor seleccionado es el asociado a la suma más baja. Esta heurística se puede generalizar para PSR no binarios de forma directa.

### Otras Técnicas: Métodos Estocásticos
Además de las técnicas sistemáticas y completas, existen también aproximaciones no sistemáticas e incompletas incluyendo heurísticas (tales como hill climbing, búsqueda tabú, enfriamiento simulado, algoritmos genéticos o algoritmos de hormigas).

Estas técnicas pueden considerarse como adaptativas en el sentido de que comienzan su búsqueda en un punto aleatorio del espacio de búsqueda y lo modifican repetidamente utilizando heurísticas hasta que alcanza la solución (con un cierto número de iteraciones), y ya las hemos revisado, en otros contextos, en entradas anteriores. Estos métodos son generalmente robustos y buenos para encontrar un mínimo global en espacios de búsqueda grandes y complejos, aunque no aseguran que se pueda encontrar debido a la aleatoriedad del punto de inicio. Por ello, es común repetir varias veces la aplicación de estos algoritmos cambiando al azar el punto de partida.

