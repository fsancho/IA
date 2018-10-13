---
title: 'Sistemas Basados en Reglas'
taxonomy:
    category: docs
visible: true
---

<img style="float: right;margin:0 10px 10px 0" src="http://www.cs.us.es/~fsancho/images/2015-07/estructura-de-un-sistema-experto-basado-en-reglas.jpg">Hay muchos casos en los que podemos resolver situaciones complejas haciendo uso de reglas deterministas, hasta el punto de su uso consigue sistemas automáticos que se comportan como humanos expertos en un dominio particular permitiendo tomar decisiones delicadas, por ejemplo: en sistemas de control de tráfico, transacciones bancarias, o diagnóstico de enfermedades.

Entre las opciones disponibles, los sistemas basados en reglas se han convertido en una de las herramientas más eficientes para tratar de manera eficiente una buena colección de problemas, ya que las reglas deterministas constituyen la más sencilla de las metodologías utilizadas en sistemas expertos. En estos sistemas, la **base de conocimiento** de la que se parte contiene las variables y el conjunto de reglas que definen el problema, y el motor de inferencia es capaz de extraer conclusiones aplicando métodos de la lógica clásica sobre esta base. Una **regla** en este contexto es una proposición lógica que relaciona dos o más objetos del dominio e incluye dos partes, la **premisa** y la **conclusión**, que se suele escribir normalmente como “**Si premisa, entonces conclusión**”. Cada una de estas partes es una expresión lógica con una o más afirmaciones objeto-valor conectadas mediante operadores lógicos (**y**, **o**, o **no**). 

La siguiente figura es un ejemplo de las reglas que se podrían extraer de un sistema de cajero automático:

<img src="http://www.cs.us.es//~fsancho/images/2015-07/ejemploreglas.jpg">

Puedes ver una web con ejemplos de Sistemas Basados en Reglas [aquí](https://visiruleexamples.com/vregs.html).

## El Motor de Inferencia

Como hemos comentado, las bases de conocimiento se conforman a partir de dos tipos de elementos básicos, por una parte los **datos** (también conocidos como **hechos** o **evidencias**), y por otra el **conocimiento** (representado por el conjunto de **reglas** que rigen las relaciones entre los datos). Pero una vez tenemos esta información almacenada, necesitamos un mecanismo para manipular automáticamente sus componentes y extraer conclusiones.

A este mecanismo se le denomina **motor de inferencia**, que a partir de la base de conocimiento obtiene nuevas conclusiones, ampliando de esta forma el conjunto de hechos de la propia base de conocimiento Por ejemplo, si la premisa de una regla es cierta, entonces aplicando la regla lógica de Modus Ponens, la conclusión de la regla debe ser también cierta, y de esta forma los datos iniciales se incrementan incorporando las nuevas conclusiones. Por ello, tanto los hechos iniciales o datos de partida como las conclusiones derivadas de ellos forman parte de los hechos o datos de que se dispone en un instante dado, obteniendo un proceso dinámico en el que el conocimiento se va generando por etapas.

Para obtener conclusiones, se pueden utilizar diferentes tipos de reglas y estrategias de inferencia y control, pero nosotros mostraremos aquí las más básicas y universales: **Modus Ponens** y **Modus Tollens** como sistemas básicos de inferencia, y **encadenamiento de reglas hacia adelante** y **encadenamiento de reglas hacia atrás** (orientado por objetivos), como estrategias de inferencia.

El Modus Ponens y Modus Tollens se corresponden con los siguientes esquemas básicos de inferencia. Obsérvese que el Modus Tollens se deduce del Modus Ponens teniendo en cuenta que la lógica que usamos es bivaluada (una afirmación, o es verdadera o es falsa, no hay una tercera opción).

<img  src="http://www.cs.us.es//~fsancho/images/2015-07/modusponens.jpg" width="400px">

<img  src="http://www.cs.us.es//~fsancho/images/2015-07/modustollens.jpg" width="400px">

El **encadenamiento de reglas hacia delante** puede utilizarse cuando las premisas de algunas reglas coinciden con las conclusiones de otras, de forma que al aplicarlas sucesivamente sobre los hechos iniciales podemos obtener nuevos hechos. A medida que obtenermos más hechos, podemos repetir el proceso hasta que no pueden obtenerse más conclusiones.

El **encadenamiento de reglas hacia atrás** parte del hecho que se quiere concluir y se mira qué reglas lo tienen como conclusión, se toman las premisas de estas reglas y se consideran como objetivos parciales que se quieren verificar. Por un proceso de comparación con los hechos de la base de conocimiento un proceso de backtracking, se va decidiendo cuáles de los objetivos parciales se van cumpliendo y cuáles quedan pendientes.

<img  src="http://www.cs.us.es//~fsancho/images/2015-07/encadenamientoadelante.jpg" width="400px">

En la figura anterior, el encadenamiento hacia adelante partiría desde los hechos de la izquierda y avanzaría aplicando las reglas hacia la derecha, mientras que el encadenamiento hacia atrás partiría de la conclusión de la derecha y va buscando los hechos necesarios y suficientes hacia la izquierda. Debe tenerse en cuenta que el uso de cualquiera de las dos estrategias no es excluyente, y que suelen usarse conjuntamente para obtener mejores resultados (si no se introducen más estrategias, suele ser necesario el uso de las dos para estar seguros de obtener todas las conclusiones factibles). 

Junto a la posibilidad de inferir nuevos conocimientos, este sistema también puede mostrarnos **incoherencias** dentro de la base de conocimiento, ya sea porque es imposible obtener ciertas conclusiones, o porque hay **inconsistencias** entre los hechos iniciales y las reglas de la base. En todo caso, un motor de inferencia útil debería ser capaz de encontrar estas inconsistencias y presentarlas al usuario. 

Asimismo, una vez encontrada la cadena de reglas que llevan de los hechos iniciales hasta la conclusión encontrada, podemos **extraer una explicación** adecuada de porqué se obtiene ese resultado, por lo que no es un motor tipo caja negra, sino que ofrece una herramienta explicativa que amplía nuestro conocimiento del sistema.

## Ventajas e Inconvenientes

Entre las ventajas de los Sistemas Basados en Reglas, podemos destacar:

1.  **Representan de forma natural el conocimiento explícito de los expertos**: normalmente, los expertos humanos explican el procedimiento de resolución de problemas por medio de expresiones del tipo "Si estamos en esta situación, entonces yo haría esto...", que se adapta fielmente al modelo seguido aquí.
2.  **Estructura uniforme**: Todas las reglas de producción tienen la misma estructura "Si... entonces...". Cada regla es una pieza de conocimiento independiente de las demás.
3.  **Separación entre la base de conocimiento y su procesamiento**.
4.  **Capacidad para trabajar con conocimiento incompleto e incertidumbre** (introduciendo variantes)**.**

Entre las desventajas principales que han llevado a complementarlo o sustituirlo con otros procedimientos de razonamiento podemos destacar:

1.  **Relaciones opacas entre reglas**: Aunque las reglas de producción son muy simples desde un punto de vista individual, las interacciones que se producen a larga distancia entre la red de reglas existentes pueden ser muy opacas, lo que hace que generalmente sea difícil saber qué papel juega una regla en particular en la estrategia global de razonamiento que hay detrás.
2.  **Estrategias de búsqueda muy ineficientes**: esencialmente, el motor de inferencia realiza una búsqueda exahustiva en todas las reglas en cada ciclo de iteración, por lo que los sistemas de reglas con muchas reglas (que pueden llegar a ser miles) son lentos y, a menudo, inviables en problemas del mundo real.
3.  **Incapaz de aprender**: los sistemas de reglas sin aditivos no son capaces de aprender de la experiencia, por lo que haber extraido un conocimiento nuevo del sistema no te proporciona métodos para poder aprender más cosas de forma más rápida posteriormente.

! ## Para saber más...
! [Sistemas Expertos Basados en Reglas](http://personales.unican.es/gutierjm/cursos/expertos/Reglas.pdf "Sistemas Expertos Basados en Reglas")
! [Sistemas Expertos y Modelos de Redes Probabilísticas](http://personales.unican.es/gutierjm/papers/BookCGH.pdf "Sistemas Expertos y Modelos de Redes Probabilísticas")
! [CLIPS: A Tool for Building Expert Systems](http://clipsrules.sourceforge.net/ "CLIPS: A Tool for Building Expert Systems")
! [Comparing Rule-based systems](http://www.w3.org/2000/10/swap/doc/rule-systems "Comparing Rule-based systems")
