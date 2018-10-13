---
title: 'Lógica Proposicional'
taxonomy:
    category: docs
visible: true
id: i1
class: images
background_color: 'rgba(255, 255, 255, 0.00)'
image_align: left
link: /home
link_text: 'Read more'
---

[TOC]
En esta entrada vamos a intentar dar un curso acelerado (aceleradísimo) acerca de qué es la **Lógica Proposicional** y de qué forma se pueden automatizar algunos de los problemas más habituales que se presentan dentro de ella. Debido a que es un curso acelerado, el lector no debe buscar aquí una formalización exahustiva acerca del tema, sino una aproximación intuitiva a cuáles son los fundamentos de la misma, a los problemas que resuelve, y a algunos de los algoritmos más habituales para automatizar las soluciones que se pueden dar a los mismos. Si el lector sabe algo de lógica, y ya ha visto algún curso de lógico proposicional con cierto detalle, lo más probable es que estas notas no le sirvan de mucho, encuentre muchas carencias e incluso alguna "mentira piadosa" (aunque prefiero llamarla "atajo")... en consecuencia, si este es tu caso, es muy probable que estas notas no estén hechas para ti... quedas avisado...

! Si quieres tener una visión más completa de la lógica, puedes ver el material del curso [Lógica Informática](http://www.cs.us.es/cursos/liti/) que se imparte en diversos grados de la E.T.S. Ingeniería Informática de la Universidad de Sevilla, así como las referencias bibliográficas que puedes encontrar en ellos.

## ¿Qué es la Lógica Proposicional?

Antes de responder a esta pregunta, vamos a definir un poco el contexto en el que nos moveremos: qué es la lógica en general.

La **Lógica** es la rama del conocimiento que se encarga de estudiar las formas en que se pueden inferir verdades de una forma válida. La visión matemática de la Lógica (lo que se llama la **Lógica Matemática**) añade toda la capa de formalismo necesaria para disponer de un lenguaje adecuado y de los métodos precisos para que este estudio tenga un soporte de validez universal. En este sentido, se pueden dar diversos formalismos para afrontar este gran problema de la inferencia válida, y la **Lógica Proposicional** fue, posiblemente, el primer intento serio al que se dio forma, por allá en tiempos de los famosos griegos atenienses.

![](http://cmapspublic2.ihmc.us/rid=1KNGMPJK1-1CSPCLM-31XG/L%C3%B3gica%20Proposicional.cmap?rid=1KNGMPJK1-1CSPCLM-31XG&partName=htmljpeg)
  
Todos estos sistemas intentan, de una u otra forma enfrentarse al problema de poder _asegurar cuándo, dada una base de conocimientos que se suponen ciertos, podemos asegurar que una afirmación es necesariamente cierta_... de forma coloquial, cuándo podemos deducir que esta última afirmación se deduce de los hechos observados (o supuestos). En particular, la Lógica Proposicional (que a partir de ahora notaremos abreviadamente como **LP**) se enfrenta a este problema definiendo:

1.  De qué forma se pueden representar los hechos y afirmaciones; es decir, dando un lenguaje formal.
2.  Qué entendemos por "_afirmación cierta_".
3.  Qué reglas podemos utilizar para garantizar la corrección de las deducciones que seamos capaces de obtener.

En el caso de la LP, las expresiones que podemos escribir con su lenguaje pueden tener dos posibles valoraciones: **verdad** o **mentira** (que, habitualmente, notaremos respectivamente por $V$ y $F$, o $1$ y $0$), y permiten usar los siguientes símbolos para poder expresar las afirmaciones del mundo:

1.  Un conjunto infinito (pero numerable) de símbolos, que llamaremos **variables proposicionales**: $p$, $q$, $r$, $s$, ..., $p\_1$, $p\_2$,...
2.  Una serie de conectivas que permiten combinar esos símbolos de forma adecuada: $\neg$, $\vee$, $\wedge$, $\rightarrow$ y $\leftrightarrow$, que se corresponden, respectivamente, con la **negación**, **disyunción** (u "o"), **conjunción** (o "y"), **implicación** (o "si ... entonces..."), y **doble implicación** (o "si y sólo si"). 
3.  Un par de **símbolos auxiliares**, $ ($ y $ )$, para facilitar la escritura de las expresiones.

Evidentemente, no vamos a admitir como correcta cualquier combinación de los símbolos anteriores, y llamaremos **fórmulas** a aquellas expresiones que sí sean correctas en nuestro sistema (por ejemplo: $(p \rightarrow q) \vee (\neg q \wedge r)$ es una fórmula correcta, mientras que $p \neg \wedge q$ no lo es). Se puede dar una definición formal de qué es una fórmula (es decir, una expresión que está correctamente escrita) y qué no lo es, pero con la idea intuitiva es suficiente para este curso acelerado. Basta tener en cuenta que una expresión es una fórmula si se puede construir usando las conectivas anteriores usando las variables proposicionales. De esta forma, las variables proposicionales representarán las afirmaciones atómicas del mundo real (o del que estamos formalizando), es decir, aquellas que no pueden ser descompuestas en afirmaciones más pequeñas; y las otras fórmulas representarán afirmaciones compuestas. 

De igual forma, podemos definir formalmente cuándo una fórmula es una subfórmula de otra.

El significado de las conectivas es el esperado en el lenguaje natural, aunque para determinar sin lugar a dudas su significado es habitual dar las tablas de verdad de las conectivas en función de la veracidad de las variables (o subfórmulas) que intervienen:

|$p$|$q$|$\neg p$|$\neg q$|$p\land q$|$p\lor q$|$p\rightarrow q$|$p\leftrightarrow q$|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|$1$|$1$|$0$|$0$|$1$|$1$|$1$|$1$|
|$1$|$0$|$0$|$1$|$0$|$1$|$0$|$0$|
|$0$|$1$|$1$|$0$|$0$|$1$|$1$|$0$|
|$0$|$0$|$1$|$1$|$0$|$0$|$1$|$1$|

Observa que las variables proposicionales no tienen un valor fijo de verdad, sino que, como su nombre indica, son variables que pueden tomar cualquiera de los dos valores posibles. Cuando tenemos una fórmula y prefijamos los valores de las variables que intervienen en ella, decimos que tenemos una **valoración**, **asignación**, o **interpretación**. Aplicando de forma iterada las reglas de la tabla anterior sobre la construcción de una fórmula, obtener el valor de verdad de la fórmula completa.

Por ejemplo, si la valoración $v$ asigna $v(p)=v(q)=1,\ v(r)=v(s)=0$, entonces el valor de $\neg(\neg(p\lor q)\lor (\neg r\lor s))$ es $1$, ya que: 

<img src="http://www.cs.us.es/~fsancho/images/2018-10/valorverdad.png" width=200px />

A pesar de que la Lógica Proposicional presenta claras limitaciones expresivas y no puede reflejar fielmente muchas de las afirmaciones que podemos hacer en sistemas un poco más ricos, suele ser más que suficiente para muchísimos problemas de la vida real, por lo que sigue siendo útil en campos como el de la Inteligencia Artificial. Además, muchos de los métodos que se utilizan en lógicas más potentes (como la **Lógica de Primer Orden**, la **Lógica Difusa**, etc.) son extensiones de los métodos que se han definido para la Lógica Proposicional, por lo que su estudio en profundidad está más que justificado.

## SAT y deducción de fórmulas
Una vez que hemos explicitado el lenguaje que usamos para formalizar las afirmaciones, y fijado lo que entendemos por su significado (de verdad o falsedad), es el momento de formalizar qué entendemos por **inferir de forma válida**.

*   Dada una valoración, $v$, diremos que una fórmula, $F$, es **válida** en $v$ si el valor de verdad de $F$ con esa valoración es $1$, $v(F)=1$, y lo notaremos $v\models F$.
*   Decimos que $F$ es una **Tautología** si siempre es válida, sea cual sea la valoración considerada.
*   Decimos que es **Insatisfactible** (o una **Contradicción**) cuando nunca es válida, y decimos que es **Satisfactible** si es válida al menos una vez.
*   Los mismos conceptos se pueden aplicar a conjuntos de fórmulas, y no solo a fórmulas aisladas (en este caso, es satisfactible si existe una valoración que hace simultáneamente válidas a todas las fórmulas del conjunto).

Por ejemplo, la fórmula $p\vee \neg p$ es una tautología, mientras que la fórmula $p\rightarrow q$ es satsifactible porque existen valoraciones que la hacen válida, pero no es tautología porque no lo hacen todas.

Además, **tenemos un método automático para saber si una fórmula es satisfactible**, **tautología** o **insatisfactible**, basta hacer la tabla de verdad de la fórmula y verificar si en el resultado hay algún $1$, si todos son $1$, o si todos son $0$ (respectivamente). El problema evidente es que es un proceso muy laborioso hacer la tabla de verdad de la fórmula cuando el número de variables que intervienen es alto (algo que suele ocurrir en los problemas del mundo real que son interesantes), ya que si tenemos $n$ variables en la fórmula, necesitaremos una tabla de verdad con $2^n$ casos distintos.

! <img style="float:right;margin:0 10px 10px 0; width:300px" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Clases_de_complejidad.svg/414px-Clases_de_complejidad.svg.png" /> Aunque esta no es la entrada adecuada para exponer este problema, es obligatorio decir aquí que el problema de saber si una fórmula es satisfactible (que se denomina **SAT**) cae dentro de los que se denominan problemas **NP**... esencialmente, aquellos problemas para los que se conoce solución, pero es tan mala desde el punto de vista de los recursos que necesitamos para resolverlos (en tiempo o en espacio) que son **intratables** desde un punto de vista práctico cuando el tamaño del problema (el tamaño de la fórmula) es grande. Es más, no solo es NP, sino que además es **NP-completo**, lo que significa que está entre los más complejos de los más complejos. Cuidado que no estamos diciendo que no tengan solución más sencilla, sino que ahora mismo no se conoce una solución sencilla, solo soluciones malas (la idea general es que no existen esas soluciones buenas para este tipo de problemas, aunque todavía no hemos sido capaces de probarlo). Por ello, las soluciones que veremos más adelante relacionadas con SAT conseguirán facilitar la solución en algunos casos, pero nunca serán suficientemente buenas en todos los casos como para considerarlas óptimas.

Ahora ya podemos decir qué entendemos por **consecuencia lógica** que, como veremos, y la intuición dice, está intimamente relacionado con la idea de implicación:

>Diremos que una fórmula, $F$, es **consecuencia lógica** de un conjunto de fórmulas, $U=\{F_1,\dots,F_n\}$, y lo  notaremos por $U\models F$, si se verifica que la fórmula $F\_1\wedge \dots \wedge F\_n \rightarrow F$ es una tautología.

<img style="float:center;width:500px" src="http://images.slideplayer.es/16/5213355/slides/slide_25.jpg" />
Como hemos dicho, la idea fundamental es la intuición de que la consecuencia lógica se relaciona, obviamente, con la implicación. Pero además, se puede probar (aunque no lo haremos) que _la definición anterior es equivalente a decir que el conjunto $\{F_1,\dots,F_n,\neg F\}$ es insatisfactible (una contradicción)_, que viene a reflejar el método habitual de probar que algo es consecuencia lógica por medio de la **reducción al absurdo** (si suponemos lo contrario, llegamos a una contradicción).

Al reducir la consecuencia lógica a comprobar una tautología o una satisfactibilidad, los métodos que tengamos para estos problemas podrán ser aplicados directamente para poder resolver el problema de la inferencia. Por tanto, ya tenemos un método, el de las tablas de verdad, para resolverlo... pero es un método demasiado primitivo e ineficiente para lo que buscamos, así que en lo que sigue nos orientaremos a buscar algunos otros métodos más elegantes, y sobre todo que nos proporcionen un mayor control para adaptarnos a las características particulares de la fórmula.











## Formas Clausales
Los métodos que vamos a ver aquí se podrán aplicar a fórmulas que estén escritas de una cierta forma, que se llama **forma clausal**. Para ello, definimos primero qué entendemos por un **literal**, que será una variable proposicional o la negación de una variable proposicional (por ejemlo, $p$, $\neg p$,...). En general, si tenemos que $L$ es un literal, notaremos por $L^c$ al literal contrario.

> Una fórmula se dice que está en **forma clausal** (también llamada **Forma Normal Conjuntiva**) si es conjunción de disyunciones de literales, es decir, si $L\_{ij}$ son literales, entonces:
> $F = (L_{11}\vee \dots \vee L_{1n_1}) \wedge (L_{21}\vee \dots \vee L_{2n_2}) \wedge \dots \wedge (L_{m1}\vee \dots \vee L_{mn_m})$

Por ejemplo: $(p \lor q \lor \neg r) \land (\neg p \lor \neg q) \land (q\lor r)$

Lo interesante es que se puede probar que cualquier fórmula se puede convertir en otra equivalente (es decir, que "dice" lo mismo, que tiene la misma tabla de verdad) expresada en forma clausal (o normal conjuntiva), por lo que los métodos que veamos a continuación se pueden aplicar a cualquier fórmula, siempre y cuando se transforme previamente a esta forma.

En realidad, debido a que la fórmula se ha expresado como una conjunción de disyunciones, podemos considerar que estamos trabajando con un conjunto de $m$ disyunciones, a cada disyunción se le llama **claúsula**. Por ello, podemos hablar de la forma clausal de una fórmula o de un conjunto de fórmulas, que pasaría a ser:

$F = \left\{\{L_{11},\dots, L_{1n_1}\},\ \{L_{21},\dots,L_{2n_2}\},\dots,\{L_{m1},\dots,L_{mn_m}\}\right\}$

<img src="http://www.cs.us.es/~fsancho/images/2015-10/fnc.png" />

! Aunque no lo vamos a usar, también se puede escribir cualquier fórmula en **Forma Normal Disyuntiva**, es decir como una disyunción de conjunciones.

Las leyes habituales que nos permiten transformar una fórmula cualquiera en una equivalente en Forma Normal Conjuntiva (o Forma Normal Disyuntiva) son:

<img src="http://www.cs.us.es/~fsancho/images/2018-09/fnc.jpg"  />



## Un algoritmo sencillo para SAT: DPLL
<img style="float:left;margin:0 10px 10px 0; width:300px" src="http://www.cs.us.es/~fsancho/images/2017-10/fredputm.jpg" /> DPLL es un algoritmo para decidir la satisfactibilidad de una fórmula (o conjunto de fórmulas) a partir de su forma clausal. Fue propuesto en 1960 por Davis y Putnam, y posteriormente refinado en 1962 por Davis, Logemann y Loveland (de ahí el nombre completo del algoritmo, DPLL). Este algoritmo es la base de la mayoría de los programas que resuelven el problema SAT y que se usan en entornos profesionales.
El algoritmo consta de dos partes bien diferenciadas que se van alternando en caso de necesidad:

1.  **Propagación de unidades,** simplifica el conjunto de claúsulas sobre el que se trabaja. Se elige una claúsula unitaria $L$ y se aplican consecutivamente las dos reglas siguientes (y se repite mientras queden claúsulas unitarias):
    1.  **Subsunción unitaria**. Se eliminan todas las claúsulas que contengan el literal $L$ (incluida la propia claúsula $L$).
    2.  **Resolución unidad**. Se elimina el literal complementario, $L^c$ de todas las claúsulas.
2.  **División**, si no hay unidades que propagar en el conjunto actual, $S$, se elige un literal $L$ que aparezca en una de las claúsulas que permanecen y se consideran por separado los conjuntos de claúsulas: $S\cup \{L\}$ y $S\cup \{L^c\}$. A continuación aplicamos recursivamente el procedimiento a ambos conjuntos (que ya tienen las claúsulas unitarias que acabamos de introducir).

El algoritmo va ramificando el proceso y cada rama puede ser una solución al problema de la satisfactibilidad. Si en una rama aparece una contradicción (una claúsula unitaria y su claúsula complementaria de forma simultánea), esa rama no proporciona una solución, pero podría haber otra rama que sí lo hiciera. Si en una rama no aparece una contradicción, esa rama proporciona una valoración que hace satisfactible la forma clausal original. Si todas las ramas son contradictorias, la forma clausal original es una contradicción.

Veamos un ejemplo de cómo aplicar este algoritmo:

<img src="http://www.cs.us.es/~fsancho/images/2015-10/dpll2.jpg" width=500px />

En el ejemplo anterior, la rama derecha proporciona un modelo ($p=0,\ q=0,\ r=1$), por lo que dice que la fórmula es satisfactible; mientras que las ramas izquierdas llegan a contradicción (ya que requiere que sean simultáneamente ciertas $r$ y $\neg r$) y no proporcionan modelos.

En cierta forma, este algoritmo es como el método habitual para resolver un sudoku, si tenemos ya algunos números seguros, su conocimiento se propaga a través del sudoku y nos permite asegurar más posiciones, y si llegamos a un callejón sin salida lo más normal es hacer suposiciones acerca de alguna de las casillas, valorando cómo evoluciona el juego para cada uno de sus posibles valores.



## Algoritmo de Resolución
En la lógica clásica hay varias reglas de deducción que son habituales: **Modus Ponens**, **Modus Tollens** y **Encadenamiento**. Vamos a escribir estas reglas en su versión normal y también veremos cómo quedan al escribirlas como claúsulas:

1.  **Modus Ponens**: $\{p\} + \{p\rightarrow q\} \models \{q\}$... en forma clausal: $\{p\} + \{\neg p,\ q\} \models \{q\}$.
2.  **Modus Tollens**: $\{\neg q\} + \{p\rightarrow q\} \models \{\neg p\}$... en forma clausal: $\{\neg q\} + \{\neg p,\ q\} \models \{\neg p\}$.
3.  **Encadenamiento**: $ \{p\rightarrow q\} +  \{q\rightarrow r\} \models \{p\rightarrow r\}$... en forma clausal: $ \{\neg p,\ q\} +  \{\neg q,\ r\} \models \{\neg p,\ r\}$.

Si observamos detenidamente las reglas anteriores, vemos que responden a un mismo patrón, que denominamos **Regla de Resolución**, y que podemos escribir como:

$\{L_1,\dots,\ L_n,\ L\} + \{M_1,\dots,\ M_k, L^c\} \models \{L_1,\dots,\ L_n,\ M_1,\dots,\ M_k\}$

> Concretamente, si tenemos dos claúsulas, $C_1$ y $C_2$, y un literal, $L$, de forma que $L\in C_1$ y $L^c\in C_2$, entonces se define la **resolvente de $C_1$ y $C_2$ respecto de $L$** como: $res_L(C_1,\ C_2)=(C_1-\{L\})\cup (C_2-\{L^c\})$.

Por ejemplo, si $C_1 = \{p,\ q,\ \neg r\}$ y $C_2 = \{\neg p,\ r,\ s\}$. Entonces $res\_p(C_1, C_2) = \{q,\ \neg r,\ r,\ s\}$. 

Es fácil probar que si $C=res\_L(C_1,\ C_2)$, entonces $\{C_1,\ C_2\}\models C$. Por tanto, la regla de resolución nos sirve para poder ir derivando claúsulas que son inferencias válidas a partir de las anteriores. Ha de tenerse en cuenta que la regla de resolución solo se puede aplicar respecto a un literal, aunque haya más de uno que aparezca complementado en ambas claúsulas, ya que si se aplicara a más de un literal simultáneamente, podemos llegar a obtener nuevas claúsulas que no son consecuencia lógica de las originales.

Se puede probar que si estamos buscando una contradicción, el sistema de aplicar la regla de resolución de forma iterada a partir de una forma clausal es completo... por lo que el sistema es válido para probar la satisfactibilidad/insatisfactibilidad de una fórmula. Esta aplicación sucesiva de la regla de resolución es lo que se conoce como **algoritmo de resolución**.

Veamos un ejemplo de aplicación:

<img src="http://www.cs.us.es/~fsancho/images/2015-10/resolucion.png" width=600px />

Como en el ejemplo anterior hemos llegado a obtener la claúsula vacía (que proviene de una contradicción), podemos afirmar que el conjunto original de cláusulas es contradictorio.



## Resumen de la Metodología

En resumen, si queremos resolver un problema habitua de saber si una cierta fórmula es consecuancia lógica (la podemos deducir) de un conjunto de fórmulas (hipótesis), formalmente, $\{F_1,\dots,F_n\}\models F$, los pasos a seguir serían:

1.  Convertimos el problema en **verificar si $\{F_1,\dots,F_n,\neg F\}$ es satisfactible o no**, es decir, si somos capaces de encontrar un modelo para esas fórmulas o no.
2.  **Pasamos cada una de esas fórmulas a forma clausal** (FNC) aplicando las reglas habituales para ello (ley distributiva, asociativa, de Morgan, etc). Podemos hacerlo por separado para cada fórmula y después simplemente consideramso el conjunto de todas las cláusulas obtenidas, cada fórmula dar un conjunto de cláusulas: $\{C_1,\dots,C_m\}$.
3.  **Aplicamos DPLL o Resolución** al conjunto de cláusulas obtenido.
4.  **Si encontramos un modelo** (en **DPLL**, una de las ramas obtiene una solución que no es contradicción; en **Resolución**, no somos capaces de encontrar la cláusula vacía), **entonces la consecuencia lógica NO es cierta**.
5.  **Si no encontramos un modelo** (en **DPLL**, todas las ramas llegan a una contradicción; en **Resolución**, encontramos una cadena de resolventes que llegan hasta la cláusula vacía), **entonces la consecuencia lógica SÍ es cierta**.

## Consideraciones finales
Aunque en general los algoritmos que existen para obtener nuevos resultados matemáticos no son automatizables (es decir, no se pueden programar en una máquina), el caso de la lógica proposicional, con todas sus limitaciones, sí que se puede automatizar. Ya vimos que el método más directo, y el más incómodo, para ello es el de la creación de la tabla de verdad. En esta entrada hemos visto algunos otros algoritmos que son fácilmente implementables (apenas usando algunas estructuras de listas o similares) y que pueden resultar más recomendables en caso de querer disponer de una implementación práctica. 

A pesar de todo, no debemos olvidar que el problema que está detrás es **SAT**, y que es un problema **NP**-completo, por tanto no debemos poner nuestras esperanzas en conseguir algoritmos que rebajen el problema de la inferencia (ni siquiera en la Lógica Proposicional) y que lo convierta en un problema tratable para todos los casos, y nos conformamos con obtener métodos que sean suficientemente buenos como para poder atacar problemas con gran número de variables en muchos casos.



