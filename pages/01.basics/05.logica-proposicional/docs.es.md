---
title: 'Lógica Proposicional'
taxonomy:
    category: docs
visible: true
---

<p>En esta entrada vamos a intentar dar un curso acelerado (acelerad&iacute;simo) acerca de qu&eacute; es la <strong>L&oacute;gica Proposicional</strong> y de qu&eacute; forma se pueden automatizar algunos de los problemas m&aacute;s habituales que se presentan dentro de ella. Debido a que es un curso acelerado, el lector no debe buscar aqu&iacute; una formalizaci&oacute;n exahustiva acerca del tema, sino una aproximaci&oacute;n intuitiva a cu&aacute;les son los fundamentos de la misma, a los problemas que resuelve, y a algunos de los algoritmos m&aacute;s habituales para automatizar las soluciones que se pueden dar a los mismos. Si el lector sabe algo de l&oacute;gica, y ya ha visto alg&uacute;n curso de l&oacute;gico proposicional con cierto detalle, lo m&aacute;s probable es que estas notas no le sirvan de mucho, encuentre muchas carencias e incluso alguna "mentira piadosa" (aunque prefiero llamarla "atajo")... en consecuencia, si este es tu caso, es muy probable que estas notas no est&eacute;n hechas para ti... quedas avisado...</p>
<p>Si quieres tener una visi&oacute;n m&aacute;s completa de la l&oacute;gica, puedes ver el material del curso <a href="http://www.cs.us.es/cursos/liti/" target="_blank" rel="noopener">L&oacute;gica Inform&aacute;tica </a>que se imparte en diversos grados de la E.T.S. Ingenier&iacute;a Inform&aacute;tica de la Universidad de Sevilla, as&iacute; como las referencias bibliogr&aacute;ficas que puedes encontrar en ellos.</p>
<h2>&iquest;Qu&eacute; es la L&oacute;gica Proposicional?</h2>
<p>Antes de responder a esta pregunta, vamos a definir un poco el contexto en el que nos moveremos: qu&eacute; es la l&oacute;gica en general.</p>
<p>La <strong>L&oacute;gica</strong> es la rama del conocimiento que se encarga de estudiar las formas en que se pueden inferir verdades de una forma v&aacute;lida. La visi&oacute;n matem&aacute;tica de la L&oacute;gica (lo que se llama la <strong>L&oacute;gica Matem&aacute;tica</strong>) a&ntilde;ade toda la capa de formalismo necesaria para disponer de un lenguaje adecuado y de los m&eacute;todos precisos para que este estudio tenga un soporte de validez universal. En este sentido, se pueden dar diversos formalismos para afrontar este gran problema de la inferencia v&aacute;lida, y la <strong>L&oacute;gica Proposicional</strong> fue, posiblemente, el primer intento serio al que se dio forma, por all&aacute; en tiempos de los famosos griegos atenienses.</p>
<p><img style="float: right; margin-left: 5px; margin-right: 5px;" src="http://cmapspublic2.ihmc.us/rid=1KNGMPJK1-1CSPCLM-31XG/L%C3%B3gica%20Proposicional.cmap?rid=1KNGMPJK1-1CSPCLM-31XG&amp;partName=htmljpeg" width="400" />Todos estos sistemas intentan, de una u otra forma enfrentarse al problema de poder <em>asegurar cu&aacute;ndo, dada una base de conocimientos que se suponen ciertos, podemos asegurar que una afirmaci&oacute;n es necesariamente cierta</em>... de forma coloquial, cu&aacute;ndo podemos deducir que esta &uacute;ltima afirmaci&oacute;n se deduce de los hechos observados (o supuestos). En particular, la L&oacute;gica Proposicional (que a partir de ahora notaremos abreviadamente como <strong>LP</strong>) se enfrenta a este problema definiendo:</p>
<ol>
<li>De qu&eacute; forma se pueden representar los hechos y afirmaciones; es decir, dando un lenguaje formal.</li>
<li>Qu&eacute; entendemos por "<em>afirmaci&oacute;n cierta</em>".</li>
<li>Qu&eacute; reglas podemos utilizar para garantizar la correcci&oacute;n de las deducciones que seamos capaces de obtener.</li>
</ol>
<p>En el caso de la LP, las expresiones que podemos escribir con su lenguaje pueden tener dos posibles valoraciones: <strong>verdad</strong> o <strong>mentira</strong> (que, habitualmente, notaremos respectivamente por \(V\) y \(F\), o \(1\) y \(0\)), y permiten usar los siguientes s&iacute;mbolos para poder expresar las afirmaciones del mundo:</p>
<ol>
<li>Un conjunto infinito (pero numerable) de s&iacute;mbolos, que llamaremos <strong>variables proposicionales</strong>: \(p\), \(q\), \(r\), \(s\), ..., \(p_1\), \(p_2\),...</li>
<li>Una serie de conectivas que permiten combinar esos s&iacute;mbolos de forma adecuada: \(\neg\), \(\vee\), \(\wedge\), \(\rightarrow\) y \(\leftrightarrow\), que se corresponden, respectivamente, con la <strong>negaci&oacute;n</strong>, <strong>disyunci&oacute;n</strong>&nbsp;(u "o"), <strong>conjunci&oacute;n</strong>&nbsp;(o "y"), <strong>implicaci&oacute;n</strong>&nbsp;(o "si ... entonces..."), y <strong>doble implicaci&oacute;n</strong>&nbsp;(o "si y s&oacute;lo si").&nbsp;</li>
<li>Un par de <strong>s&iacute;mbolos auxiliares</strong>, \( (\) y \( )\), para facilitar la escritura de las expresiones.</li>
</ol>
<p>Evidentemente, no vamos a admitir como correcta cualquier combinaci&oacute;n de los s&iacute;mbolos anteriores, y llamaremos <strong>f&oacute;rmulas</strong> a aquellas expresiones que s&iacute; sean correctas en nuestro sistema (por ejemplo: \((p \rightarrow q) \vee (\neg q \wedge r)\) es una f&oacute;rmula correcta, mientras que \(p \neg \wedge q\) no lo es). Se puede dar una definici&oacute;n formal de qu&eacute; es una f&oacute;rmula (es decir, una expresi&oacute;n que est&aacute; correctamente escrita) y qu&eacute; no lo es, pero con la idea intuitiva es suficiente para este curso acelerado. Basta tener en cuenta que una expresi&oacute;n es una f&oacute;rmula si se puede construir usando las conectivas anteriores usando las variables proposicionales. De esta forma, las variables proposicionales representar&aacute;n las afirmaciones at&oacute;micas del mundo real (o del que estamos formalizando), es decir, aquellas que no pueden ser descompuestas en afirmaciones m&aacute;s peque&ntilde;as; y las otras f&oacute;rmulas representar&aacute;n afirmaciones compuestas.&nbsp;</p>
<p>De igual forma, podemos definir formalmente cu&aacute;ndo una f&oacute;rmula es una subf&oacute;rmula de otra.</p>
<p>El significado de las conectivas es el esperado en el lenguaje natural, aunque para determinar sin lugar a dudas su significado es habitual dar las tablas de verdad de las conectivas en funci&oacute;n de la veracidad de las variables (o subf&oacute;rmulas) que intervienen:</p>
<table style="margin-left: auto; margin-right: auto;" border="0" align="center">
<thead>
<tr>
<td style="text-align: center;">$p$</td>
<td style="text-align: center;">$q$</td>
<td style="text-align: center;">$\neg\ p$</td>
<td style="text-align: center;">$\neg\ q$</td>
<td style="text-align: center;">$p\land q$</td>
<td style="text-align: center;">$p\lor q$</td>
<td style="text-align: center;">$p\rightarrow q$</td>
<td style="text-align: center;">$p\leftrightarrow q$</td>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
</tr>
<tr>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
</tr>
<tr>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
</tr>
<tr>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$0$</td>
<td style="text-align: center;">$1$</td>
<td style="text-align: center;">$1$</td>
</tr>
</tbody>
</table>
<p>Observa que las variables proposicionales no tienen un valor fijo de verdad, sino que, como su nombre indica, son variables que pueden tomar cualquiera de los dos valores posibles. Cuando tenemos una f&oacute;rmula y prefijamos los valores de las variables que intervienen en ella, decimos que tenemos una <strong>valoraci&oacute;n</strong>, <strong>asignaci&oacute;n</strong>, o <strong>interpretaci&oacute;n</strong>. Aplicando de forma iterada las reglas de la tabla anterior sobre la construcci&oacute;n de una f&oacute;rmula, obtener el valor de verdad de la f&oacute;rmula completa.</p>
<p>Por ejemplo, si la valoraci&oacute;n $v$ asigna $v(p)=v(q)=1,\ v(r)=v(s)=0$, entonces el valor de $\neg(\neg(p\lor q)\lor (\neg r\lor s))$ es $1$, ya que:&nbsp;</p>
<p>[[image file="2018-10/valorverdad.png" width=200px]]</p>
<p>A pesar de que la L&oacute;gica Proposicional presenta claras limitaciones expresivas y no puede reflejar fielmente muchas de las afirmaciones que podemos hacer en sistemas un poco m&aacute;s ricos, suele ser m&aacute;s que suficiente para much&iacute;simos problemas de la vida real, por lo que sigue siendo &uacute;til en campos como el de la Inteligencia Artificial. Adem&aacute;s, muchos de los m&eacute;todos que se utilizan en l&oacute;gicas m&aacute;s potentes (como la <strong>L&oacute;gica de Primer Orden</strong>, la <strong>L&oacute;gica Difusa</strong>, etc.) son extensiones de los m&eacute;todos que se han definido para la L&oacute;gica Proposicional, por lo que su estudio en profundidad est&aacute; m&aacute;s que justificado.</p>
<h2>Qu&eacute; significa que una f&oacute;rmula se pueda deducir de un conjunto de f&oacute;rmulas</h2>
<p>Una vez que hemos explicitado el lenguaje que usamos para formalizar las afirmaciones, y fijado lo que entendemos por su significado (de verdad o falsedad), es el momento de formalizar qu&eacute; entendemos por <strong>inferir de forma v&aacute;lida</strong>.</p>
<ul>
<li>Dada una valoraci&oacute;n, \(v\), diremos que una f&oacute;rmula, \(F\), es <strong>v&aacute;lida</strong> en \(v\) si el valor de verdad de \(F\) con esa valoraci&oacute;n es \(1\), \(v(F)=1\), y lo notaremos \(v\models F\).</li>
<li>Decimos que \(F\) es una T<strong>autolog&iacute;a</strong> si siempre es v&aacute;lida, sea cual sea la valoraci&oacute;n considerada.</li>
<li>Decimos que es I<strong>nsatisfactible</strong> (o una C<strong>ontradicci&oacute;n</strong>) cuando nunca es v&aacute;lida, y decimos que es S<strong>atisfactible</strong> si es v&aacute;lida al menos una vez.</li>
<li>Los mismos conceptos se pueden aplicar a conjuntos de f&oacute;rmulas, y no solo a f&oacute;rmulas aisladas (en este caso, es satisfactible si existe una valoraci&oacute;n que hace simult&aacute;neamente v&aacute;lidas a todas las f&oacute;rmulas del conjunto).</li>
</ul>
<p>Por ejemplo, la f&oacute;rmula \(p\vee \neg p\) es una tautolog&iacute;a, mientras que la f&oacute;rmula \(p\rightarrow q\) es satsifactible porque existen valoraciones que la hacen v&aacute;lida, pero no es tautolog&iacute;a porque no lo hacen todas.</p>
<p>Adem&aacute;s, <strong>tenemos un m&eacute;todo autom&aacute;tico para saber si una f&oacute;rmula es satisfactible</strong>, <strong>tautolog&iacute;a</strong> o <strong>insatisfactible</strong>, basta hacer la tabla de verdad de la f&oacute;rmula y verificar si en el resultado hay alg&uacute;n $1$, si todos son $1$, o si todos son $0$ (respectivamente). El problema evidente es que es un proceso muy laborioso hacer la tabla de verdad de la f&oacute;rmula cuando el n&uacute;mero de variables que intervienen es alto (algo que suele ocurrir en los problemas del mundo real que son interesantes), ya que si tenemos \(n\) variables en la f&oacute;rmula, necesitaremos una tabla de verdad con \(2^n\) casos distintos.</p>
<p><img style="float: right; margin-left: 5px; margin-right: 5px;" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Clases_de_complejidad.svg/414px-Clases_de_complejidad.svg.png" width="414" height="255" />Aunque esta no es la entrada adecuada para exponer este problema, es obligatorio decir aqu&iacute; que el problema de saber si una f&oacute;rmula es satisfactible (que se denomina <strong>SAT</strong>) cae dentro de los que se denominan problemas <strong>NP</strong>... esencialmente, aquellos problemas para los que se conoce soluci&oacute;n, pero es tan mala desde el punto de vista de los recursos que necesitamos para resolverlos (en tiempo o en espacio) que son <strong>intratables</strong> desde un punto de vista pr&aacute;ctico cuando el tama&ntilde;o del problema (el tama&ntilde;o de la f&oacute;rmula) es grande. Es m&aacute;s, no solo es NP, sino que adem&aacute;s es <strong>NP-completo</strong>, lo que significa que est&aacute; entre los m&aacute;s complejos de los m&aacute;s complejos. Cuidado que no estamos diciendo que no tengan soluci&oacute;n m&aacute;s sencilla, sino que ahora mismo no se conoce una soluci&oacute;n sencilla, solo soluciones malas (la idea general es que no existen esas soluciones buenas para este tipo de problemas, aunque todav&iacute;a no hemos sido capaces de probarlo). Por ello, las soluciones que veremos m&aacute;s adelante relacionadas con SAT conseguir&aacute;n facilitar la soluci&oacute;n en algunos casos, pero nunca ser&aacute;n suficientemente buenas en todos los casos como para considerarlas &oacute;ptimas.</p>
<p>Ahora ya podemos decir qu&eacute; entendemos por consecuencia l&oacute;gica que, como veremos, y la intuici&oacute;n dice, est&aacute; intimamente relacionado con la idea de implicaci&oacute;n:</p>
<p><em>Diremos que una f&oacute;rmula, \(F\), es <strong>consecuencia l&oacute;gica</strong> de un conjunto de f&oacute;rmulas, \(U=\{F_1,\dots,F_n\}\), y lo &nbsp;notaremos por \(U\models F\), si se verifica que la f&oacute;rmula \(F_1\wedge \dots \wedge F_n \rightarrow F\) es una tautolog&iacute;a.</em></p>
<p><em><img style="display: block; margin-left: auto; margin-right: auto;" src="http://images.slideplayer.es/16/5213355/slides/slide_25.jpg" width="500" /></em></p>
<p>Como hemos dicho, la idea fundamental es la intuici&oacute;n de que la consecuencia l&oacute;gica se relaciona, obviamente, con la implicaci&oacute;n. Pero adem&aacute;s, se puede probar (aunque no lo haremos) que <em>la definici&oacute;n anterior es equivalente a decir que el conjunto \(\{F_1,\dots,F_n,\neg F\}\) es insatisfactible (una contradicci&oacute;n)</em>, que viene a reflejar el m&eacute;todo habitual de probar que algo es consecuencia l&oacute;gica por medio de la <strong>reducci&oacute;n al absurdo</strong> (si suponemos lo contrario, llegamos a una contradicci&oacute;n).</p>
<p>Al reducir la consecuencia l&oacute;gica a comprobar una tautolog&iacute;a o una satisfactibilidad, los m&eacute;todos que tengamos para estos problemas podr&aacute;n ser aplicados directamente para poder resolver el problema de la inferencia. Por tanto, ya tenemos un m&eacute;todo, el de las tablas de verdad, para resolverlo... pero es un m&eacute;todo demasiado primitivo e ineficiente para lo que buscamos, as&iacute; que en lo que sigue nos orientaremos a buscar algunos otros m&eacute;todos m&aacute;s elegantes, y sobre todo que nos proporcionen un mayor control para adaptarnos a las caracter&iacute;sticas particulares de la f&oacute;rmula.</p>
<h2>Formas Clausales</h2>
<p>Los m&eacute;todos que vamos a ver aqu&iacute; se podr&aacute;n aplicar a f&oacute;rmulas que est&eacute;n escritas de una cierta forma, que se llama <strong>forma clausal</strong>. Para ello, definimos primero qu&eacute; entendemos por un <strong>literal</strong>, que ser&aacute; una variable proposicional o la negaci&oacute;n de una variable proposicional (por ejemlo, \(p\), \(\neg p\),...). En general, si tenemos que \(L\) es un literal, notaremos por \(L^c\) al literal contrario.</p>
<p>Una f&oacute;rmula se dice que est&aacute; en <strong>forma clausal</strong>&nbsp;(tambi&eacute;n llamada <strong>Forma Normal Conjuntiva</strong>) si es conjunci&oacute;n de disyunciones de literales, es decir, si \(L_{ij}\) son literales, entonces:</p>
<p>\[F = (L_{11}\vee \dots \vee L_{1n_1}) \wedge&nbsp;(L_{21}\vee \dots \vee L_{2n_2}) \wedge \dots \wedge&nbsp;(L_{m1}\vee \dots \vee L_{mn_m})\]</p>
<p>Por ejemplo: $(p \lor q \lor \neg r) \land (\neg p \lor \neg q) \land (q\lor r)$</p>
<p>Lo interesante es que se puede probar que cualquier f&oacute;rmula se puede convertir en otra equivalente (es decir, que "dice" lo mismo, que tiene la misma tabla de verdad) expresada en forma clausal (o normal conjuntiva), por lo que los m&eacute;todos que veamos a continuaci&oacute;n se pueden aplicar a cualquier f&oacute;rmula, siempre y cuando se transforme previamente a esta forma.</p>
<p>En realidad, debido a que la f&oacute;rmula se ha expresado como una conjunci&oacute;n de disyunciones, podemos considerar que estamos trabajando con un conjunto de \(m\) disyunciones, a cada disyunci&oacute;n se le llama <strong>cla&uacute;sula</strong>. Por ello, podemos hablar de la forma clausal de una f&oacute;rmula o de un conjunto de f&oacute;rmulas, que pasar&iacute;a a ser:</p>
<p>\[F = \left\{\{L_{11},\dots, L_{1n_1}\},\ \{L_{21},\dots,L_{2n_2}\},\dots,\{L_{m1},\dots,L_{mn_m}\}\right\} \]</p>
<p>[[image file="2015-10/fnc.png" ]]</p>
<p>Aunque no lo vamos a usar, tambi&eacute;n se puede escribir cualquier f&oacute;rmula en <strong>Forma Normal Disyuntiva</strong>, es decir como una disyunci&oacute;n de conjunciones.</p>
<p>Las leyes habituales que nos permiten transformar una f&oacute;rmula cualquiera en una equivalente en Forma Normal Conjuntiva (o Forma Normal Disyuntiva) son:</p>
<p>[[image file="2018-09/fnc.jpg" ]]</p>
<h2>Un algoritmo sencillo de satisfactibilidad: DPLL</h2>
<p>[[image file="2017-10/fredputm.jpg" align="left" width=300px]]DPLL es un algoritmo para decidir la satisfactibilidad de una f&oacute;rmula (o conjunto de f&oacute;rmulas) a partir de su forma clausal. Fue propuesto en 1960 por Davis y Putnam, y posteriormente refinado en 1962 por Davis, Logemann y Loveland (de ah&iacute; el nombre completo del algoritmo, DPLL). Este algoritmo es la base de la mayor&iacute;a de los programas que resuelven el problema SAT y que se usan en entornos profesionales.</p>
<p>El algoritmo consta de dos partes bien diferenciadas que se van alternando en caso de necesidad:</p>
<ol>
<li><strong>Propagaci&oacute;n de unidades,</strong>&nbsp;simplifica el conjunto de cla&uacute;sulas sobre el que se trabaja.&nbsp;Se elige una cla&uacute;sula unitaria \(L\) y se aplican consecutivamente las dos reglas siguientes (y se repite mientras queden cla&uacute;sulas unitarias):
<ol>
<li><strong>Subsunci&oacute;n unitaria</strong>. Se eliminan todas las cla&uacute;sulas que contengan el literal \(L\) (incluida la propia cla&uacute;sula \(L\)).</li>
<li><strong>Resoluci&oacute;n unidad</strong>. Se elimina el literal complementario, \(L^c\) de todas las cla&uacute;sulas.</li>
</ol>
</li>
<li><strong>Divisi&oacute;n</strong>, si no hay unidades que propagar en el conjunto actual, \(S\), se elige un literal \(L\) que aparezca en una de las cla&uacute;sulas que permanecen y se consideran por separado los conjuntos de cla&uacute;sulas: \(S\cup \{L\}\) y \(S\cup \{L^c\}\). A continuaci&oacute;n aplicamos recursivamente el procedimiento a ambos conjuntos (que ya tienen las cla&uacute;sulas unitarias que acabamos de introducir).</li>
</ol>
<p>El algoritmo va ramificando el proceso y cada rama puede ser una soluci&oacute;n al problema de la satisfactibilidad. Si en una rama aparece una contradicci&oacute;n (una cla&uacute;sula unitaria y su cla&uacute;sula complementaria de forma simult&aacute;nea), esa rama no proporciona una soluci&oacute;n, pero podr&iacute;a haber otra rama que s&iacute; lo hiciera. Si en una rama no aparece una contradicci&oacute;n, esa rama proporciona una valoraci&oacute;n que hace satisfactible la forma clausal original. Si todas las ramas son contradictorias, la forma clausal original es una contradicci&oacute;n.</p>
<p>Veamos un ejemplo de c&oacute;mo aplicar este algoritmo:</p>
<p>[[image file="2015-10/dpll2.jpg" width=500px]]</p>
<p>En el ejemplo anterior, la rama derecha proporciona un modelo (\(p=0,\ q=0,\ r=1\)), por lo que dice que la f&oacute;rmula es satisfactible; mientras que las ramas izquierdas llegan a contradicci&oacute;n (ya que requiere que sean simult&aacute;neamente ciertas \(r\) y \(\neg r\)) y no proporcionan modelos.</p>
<p>En cierta forma, este algoritmo es como el m&eacute;todo habitual para resolver un sudoku, si tenemos ya algunos n&uacute;meros seguros, su conocimiento se propaga a trav&eacute;s del sudoku y nos permite asegurar m&aacute;s posiciones, y si llegamos a un callej&oacute;n sin salida lo m&aacute;s normal es hacer suposiciones acerca de alguna de las casillas, valorando c&oacute;mo evoluciona el juego para cada uno de sus posibles valores.</p>
<h2>Regla de Resoluci&oacute;n y Algoritmo de Resoluci&oacute;n</h2>
<p>En la l&oacute;gica cl&aacute;sica hay varias reglas de deducci&oacute;n que son habituales: <strong>Modus Ponens</strong>, <strong>Modus Tollens</strong> y <strong>Encadenamiento</strong>. Vamos a escribir estas reglas en su versi&oacute;n normal y tambi&eacute;n veremos c&oacute;mo quedan al escribirlas como cla&uacute;sulas:</p>
<ol>
<li><strong>Modus Ponens</strong>: \(\{p\} + \{p\rightarrow q\} \models \{q\}\)... en forma clausal:&nbsp;\(\{p\} + \{\neg p,\ q\} \models \{q\}\).</li>
<li><strong>Modus Tollens</strong>: \(\{\neg q\} + \{p\rightarrow q\} \models \{\neg p\}\)... en forma clausal:&nbsp;\(\{\neg q\} + \{\neg p,\ q\} \models \{\neg p\}\).</li>
<li><strong>Encadenamiento</strong>: \(&nbsp;\{p\rightarrow q\} +&nbsp;&nbsp;\{q\rightarrow r\}&nbsp;\models \{p\rightarrow r\}\)... en forma clausal:&nbsp;\(&nbsp;\{\neg p,\ q\} +&nbsp;&nbsp;\{\neg q,\ r\}&nbsp;\models \{\neg p,\ r\}\).</li>
</ol>
<p>Si observamos detenidamente las reglas anteriores, vemos que responden a un mismo patr&oacute;n, que denominamos <strong>Regla de Resoluci&oacute;n</strong>, y que podemos escribir como:</p>
<p>\[\{L_1,\dots,\ L_n,\ L\} + \{M_1,\dots,\ M_k, L^c\} \models \{L_1,\dots,\ L_n,\ M_1,\dots,\ M_k\}\]</p>
<p>Concretamente, si tenemos dos cla&uacute;sulas, \(C_1\) y \(C_2\), y un literal, \(L\), de forma que \(L\in C_1\) y \(L^c\in C_2\), entonces se define la <strong>resolvente de \(C_1\) y \(C_2\) respecto de \(L\)</strong> como: \(res_L(C_1,\ C_2)=(C_1-\{L\})\cup (C_2-\{L^c\})\).</p>
<p>Por ejemplo, si \(C_1 = \{p,\ q,\ \neg r\}\) y \(C_2 = \{\neg p,\ r,\ s\}\). Entonces \(res_p(C_1, C_2) = \{q,\ \neg r,\ r,\ s\}\).&nbsp;</p>
<p>Es f&aacute;cil probar que si \(C=res_L(C_1,\ C_2)\), entonces \(\{C_1,\ C_2\}\models C\). Por tanto, la regla de resoluci&oacute;n nos sirve para poder ir derivando cla&uacute;sulas que son inferencias v&aacute;lidas a partir de las anteriores. Ha de tenerse en cuenta que la regla de resoluci&oacute;n solo se puede aplicar respecto a un literal, aunque haya m&aacute;s de uno que aparezca complementado en ambas cla&uacute;sulas, ya que si se aplicara a m&aacute;s de un literal simult&aacute;neamente, podemos llegar a obtener nuevas cla&uacute;sulas que no son consecuencia l&oacute;gica de las originales.</p>
<p>Se puede probar que si estamos buscando una contradicci&oacute;n, el sistema de aplicar la regla de resoluci&oacute;n de forma iterada a partir de una forma clausal es completo... por lo que el sistema es v&aacute;lido para probar la satisfactibilidad/insatisfactibilidad de una f&oacute;rmula. Esta aplicaci&oacute;n sucesiva de la regla de resoluci&oacute;n es lo que se conoce como <strong>algoritmo de resoluci&oacute;n</strong>.</p>
<p>Veamos un ejemplo de aplicaci&oacute;n:</p>
<p>[[image file="2015-10/resolucion.png" width=600px]]</p>
<p>Como en el ejemplo anterior hemos llegado a obtener la cla&uacute;sula vac&iacute;a (que proviene de una contradicci&oacute;n), podemos afirmar que el conjunto original de cl&aacute;usulas es contradictorio.</p>
<p>En el siguiente modelo de NetLogo puedes probar el proceso de resoluci&oacute;n para algunos conjuntos de cla&uacute;sulas precargados (el modelo implementa las funciones necesarias para la aplicaci&oacute;n del algoritmo de forma general, pero debido a las caracter&iacute;sticas de NetLogoWeb el conjunto de cl&aacute;usulas de ejemplo se ha restringido para facilitar su uso). Selecciona el conjunto de ejemplo con el <strong>slider Conjunto</strong>, c&aacute;rgalo con el bot&oacute;n <strong>Selecciona</strong>, y a continuaci&oacute;n pulsa en <strong>Go</strong>:</p>
<p><iframe style="display: block; margin-left: auto; margin-right: auto;" src="http://www.cs.us.es/~fsancho/Modelos/ResolucionLPweb.html" width="730" height="670"></iframe></p>
<h2>Resumen de la Metodolog&iacute;a</h2>
<p>En resumen, si queremos resolver un problema habitua de saber si una cierta f&oacute;rmula es consecuancia l&oacute;gica (la podemos deducir) de un conjunto de f&oacute;rmulas (hip&oacute;tesis), formalmente, $\{F_1,\dots,F_n\}\models F$, los pasos a seguir ser&iacute;an:</p>
<ol>
<li>Convertimos el problema en <strong>verificar si $\{F_1,\dots,F_n,\neg F\}$ es satisfactible o no</strong>, es decir, si somos capaces de encontrar un modelo para esas f&oacute;rmulas o no.</li>
<li><strong>Pasamos cada una de esas f&oacute;rmulas a forma clausal</strong> (FNC) aplicando las reglas habituales para ello (ley distributiva, asociativa, de Morgan, etc). Podemos hacerlo por separado para cada f&oacute;rmula y despu&eacute;s simplemente consideramso el conjunto de todas las cl&aacute;usulas obtenidas, cada f&oacute;rmula dar un conjunto de cl&aacute;usulas: $\{C_1,\dots,C_m\}$.</li>
<li><strong>Aplicamos DPLL o Resoluci&oacute;n</strong> al conjunto de cl&aacute;usulas obtenido.</li>
<li><strong>Si encontramos un modelo</strong> (en <strong>DPLL</strong>, una de las ramas obtiene una soluci&oacute;n que no es contradicci&oacute;n; en <strong>Resoluci&oacute;n</strong>, no somos capaces de encontrar la cl&aacute;usula vac&iacute;a), <strong>entonces la consecuencia l&oacute;gica NO es cierta</strong>.</li>
<li><strong>Si no encontramos un modelo</strong> (en <strong>DPLL</strong>, todas las ramas llegan a una contradicci&oacute;n; en <strong>Resoluci&oacute;n</strong>, encontramos una cadena de resolventes que llegan hasta la cl&aacute;usula vac&iacute;a), <strong>entonces la consecuencia l&oacute;gica S&Iacute; es cierta</strong>.</li>
</ol>
<h2>Algunas consideraciones finales: sobre la automatizaci&oacute;n</h2>
<p>Aunque en general los algoritmos que existen para obtener nuevos resultados matem&aacute;ticos no son automatizables (es decir, no se pueden programar en una m&aacute;quina), el caso de la l&oacute;gica proposicional, con todas sus limitaciones, s&iacute; que se puede automatizar. Ya vimos que el m&eacute;todo m&aacute;s directo, y el m&aacute;s inc&oacute;modo, para ello es el de la creaci&oacute;n de la tabla de verdad. En esta entrada hemos visto algunos otros algoritmos que son f&aacute;cilmente implementables (apenas usando algunas estructuras de listas o similares) y que pueden resultar m&aacute;s recomendables en caso de querer disponer de una implementaci&oacute;n pr&aacute;ctica.&nbsp;</p>
<p>A pesar de todo, no debemos olvidar que el problema que est&aacute; detr&aacute;s es SAT, y que es un problema NP-completo, por tanto no debemos poner nuestras esperanzas en conseguir algoritmos que rebajen el problema de la inferencia (ni siquiera en la L&oacute;gica Proposicional) y que lo convierta en un problema tratable para todos los casos, y nos conformamos con obtener m&eacute;todos que sean suficientemente buenos como para poder atacar problemas con gran n&uacute;mero de variables en muchos casos.</p>