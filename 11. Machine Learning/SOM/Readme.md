# [Self-Organizing Maps](http://www.cs.us.es/~fsancho/?e=76)

Contenido aproximado de los ficheros de esta carpeta:

+ `SOM.nls`: **Fichero Fuente NetLogo (NetLogo Source)** con la librería general para la ejecución del algoritmo SOM.
+ `SOM-color.nlogo`: Un ejemplo de aplicación de SOM para la aproximación de colores RGB.
+ `SOM-hexaClassifier.nlogo`: Ejemplo de aplicación de SOM (con topología hexagonal) para la clasificación de objetos.
+ `SOM-TSP.nls`: Ejemplo de aplicación de SOM (con topología de anillo) para la resolción de TSP.
+ `****.txt`: Diversas tablas de objetos para ser usados con SOM-hexaClassifier.

## Instrucciones de Uso de SOM:

Los nodos de aprendizaje son elementos de la familia de tortugas _SOM:Lnodes_, que deben contener (al menos) las siguientes propiedades:

+ `weight` : Almacena el vector de pesos asociado al nodo, y con el que intenta aprender un vector de aprendizaje. Su dimensión vendrá dada por las necesidades del problema.
+ `err`  : Almacena el error relativo de este nodo respecto a su vecindad.

Además, el sistema usa 2 variables globales para almacenar el radio inicial que tendrán los entornos para actualizar los pesos (`SOM:R0`) y el valor mínimo del radio de los entornos para que contengan únicamente un punto (`SOM:min-dis`), y que, una vez alcanzado, determinará el final de ejecución del algoritmo.

La función principal de la librería **SOM** es el procedimiento `SOM:SOM`, que se encarga de repetir el bucle principal de iteraciones para ajustar los pesos de los nodos de aprendizaje en su aproximación a los vectores de entrada. Además, este procedimiento permite que tras cada iteración se ejecute un procedimiento externo (que puede ser personalizado para cada problema) con el fin de actualizar las visualizaciones del modelo o de hacer los cálculos pertinentes que corresponden a la situación actual. La función `SOM:SOM` no devuelve nada, por lo que el resultado de aprendizaje se mantiene en los nodos de aprendizaje.

Los datos de entrada que espera el procedimiento `SOM:SOM`son:

+ `#TSet` : Lista de vectores que pretenden ser aprendidos.
+ `#Training-Time` : Número de iteraciones que serán ejecutadas por el algoritmo SOM.

Además, previamente, debe indicarse al sistema que cree los nodos de aprendizaje por medio de `SOM:setup-Lnodes`, que recibe como datos de entrada:

+ `#N` : Influye en el número de nodos que formarán la red SOM. El número exacto de éstos depende finalmente de la topología seleccionada.
+ `#Top` : Topología que conforman en la red. Aunque puede darse cualquier red, ahora mismo el sistema admite 3 opciones: **Anillo** (`Ring`), de radio 1, N nodos; **Malla Cuadrada** (`SqGrid`), NxN nodos, ocupan todo el mundo; **Malla Hexagonal** (`HxGrid`), NxN nodos, ocupan todo el mundo. 
+ `#D` : Dimensión de los pesos de aprendizaje de cada nodo.
+ `#W` : Indica cómo se inicializarán los pesos: "G", geométricamente, es decir, las coordenadas de los nodos (en este caso, debido a que las topologías se preparan en R^2, la dimensión del sistema se supone que es 2); "R", peso de valores aleatorios en [0,1] de dimensión D.

Para el correcto funcionamiento de esta librería en el modelo principal se deben definir los siguientes procedimientos (que permitirán adaptarla al problema concreto que se quiera resolver con algoritmos genéticos):
   
+ `AI:ExternalUpdate` : Procedimiento auxiliar que se ejecutará tras cada iteración del bucle principal. Normalmente, contendrá instrucciones para mostrar o actualizar información del modelo. Entre otras cosas, puede ser necesario usar agentes auxiliares para representar la información visual de los nodos de aprendizaje (pueden ser patches, por ejemplo). 

En los modelos de ejemplo se pueden ver algunas definiciones válidas para distintos problemas.

