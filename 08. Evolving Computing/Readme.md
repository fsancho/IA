# [Computación Evolutiva](http://www.cs.us.es/~fsancho/?e=65)

Contenido aproximado de los ficheros de esta carpeta:

+ `Biomorphs Girasol.nlogo`: Modelo básico de demostración de reproducción sexual y asexual para analizar cómo se puede dirigir la descendencia.
+ `Tiburones y pececillos evolutivos.nlogo`: Un ejemplo de optimizción por selección natural en entornos hostiles.
+ `Paisaje Evolutivo.nlogo`: Muestra cómo los métodos de optimización por poblaciones pueden ser eficientes cuando las condiciones del problema cambian dinámicamente.
+ `Algoritmo Genético.nlogo`: Ejemplo muy básico de algoritmo genético para la optimización de un problema.

Faltan por explicar los modelos relacionados con la librería general.

## Instrucciones de Uso de GeneticAlgorithm:

Los **individuos** de la población son elementos de la familia de tortugas _AI:individuals_, que deben contener (al menos) las siguientes propiedades:

+ `content`   : Almacena el contenido (valor) del estado
+ `fitness?`  : Almacena el valor de Fitness del individuo

La función principal de la librería **GeneticAlgorithm** es el procedimiento `AI:GeneticAlgorithm`, que se encarga de repetir el bucle principal de iteraciones para la creación de la nueva generación de inviduos a partir de la población actual. Además, este procedimiento permite que tras la creación de la nueva generación se ejecute un procedimiento externo (que puede ser personalizado para cada problema) con el fin de actualizar las visualizaciones del modelo o de hacer los cálculos pertinentes que corresponden con la generación existente. Esta función devuelve uno de los individuos com mayor fitness de la población final.

Los datos de entrada que espera este procedimiento son:

+ `#num-iters`       : Número de iteraciones (generaciones) que dará el algoritmo
+ `#population`      : Población (número) de individuos que tendrá cada generación (en la versión actual, no cambia de una generación a otra)
+ `#crossover-ratio` : % de cruzamientos que se harán en cada iteración
+ `#mutation-ratio`  : Probabilidad de mutación de cada únidad informativa del ADN de los individuos

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir los siguientes procedimientos (que permitirán adaptarla al problema concreto que se quiera resolver con algoritmos genéticos):
   
+ `AI:Initial-Population [#population]` : Crea la población inicial de individuos, estableciendo su contenido (código genético).

+ `AI:Compute-fitness`: Report de AI:individual que calcula el valor de fitness que tiene (en función de su contenido).

+ `AI:Crossover [c1 c2]` : Procedimiento personalizado de cruzamiento. Recibe como dato de entrada el contenido de 2 padres y devuelve una lista con los contenidos de los hijos tras haber realizado el cruzamiento. Cuando el contenido se puede expresar en forma de lista, es normal usar como cruzamiento el __corte aleatorio por un punto__, de forma que si `a1|a2`, `b1|b2` son las dos listas y se elige un corte de forma que `long(ai)=long(bi)`, entonces se devuelven las nuevas listas: `a1|b2`, `b1|a2`.

+ `AI:mutate [#mutation-ratio]` : Procedimiento de mutación. Lo ejecutan los individuos, y recibe como parámetro la probabilidad de que cada unidad de su contenido mute.

+ `AI:ExternalUpdate` : Procedimiento auxiliar que se ejecutará tras cada iteración del bucle principal. Normalmente, contendrá instrucciones para mostrar o actualizar información del modelo.

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

Además, esta librería incluye algunos procedimientos para calcular la *diversidad* existente en la población a partir de una distancia predefinida y que se puede personalizar. La diversidad se define como la media de todas las posibles distancias entre lso individuos de la población. Para el caso de contenidos en forma de lista suele ser habitual trabajar con la distancia de Hamming, que viene predefinida en la librería.
