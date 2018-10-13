---
title: 'Introducción a la IA'
taxonomy:
    category: docs
visible: true
---

[TOC]
## Introducción
<img style="float:left;margin:0 10px 10px 0; width:200px" src="http://www.cs.us.es/~fsancho/images/2017-09/ia-imagen.png" /> El campo de la **Inteligencia Artificial (IA)** es un campo de investigación transdisciplinar que generalmente se relaciona con el desarrollo e investigación de sistemas que operan o actúan inteligentemente. Está considerada una disciplina de las ciencias de la computación ya que tiene un enfoque principalmente computacional, aunque cada día hay más aportaciones desde otras áreas (como neurociencia, estadística, psicología, etc.). La IA clásica aparece en los años 50 como resultado de la comprensión del cerebro por medio de la neurociencia, las nuevas teorías matemáticas de la información, la teoría de control que surge desde la cibernética y la aparición del ordenador digital. 

<iframe width="180"  height="120" src="https://www.youtube.com/embed/Ut6gDw_Onwk" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/kprlS_xVdsM" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/PXmnuXA1lrc" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
<iframe width="180"  height="120" src="https://www.youtube.com/embed/XQdt04iTfVI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

<img style="float: right;" src="https://yt3.ggpht.com/a-/AN66SAzIPtc5nxMnxMMxH7Z2pf9dZcHReiymkVhBKw=s288-mo-c-c0xffffffff-rj-k-no"  width=75px>

!  Como medio de recopilar un poc de cultura en las últimas novedades relacionadas con la IA es recomendable seguir el canal [DOT CSV de youtube](https://www.youtube.com/channel/UCy5znSnfMsDwaLlROnZ7Qbg/featured), donde se van colgando videos divulgativos muy interesantes del tema.

## Diversas aproximaciones

Russell y Norvig proporcionan una perspectiva que describe esencialmente 4 posibles aproximaciones a la hora de entender cómo se puede desarrollar la IA, dependiendo de las combiaciones posibles entre si consideramos una IA basada en cómo piensan los humanos o si se considera una racionalidad ideal, y si consideramos una IA basada en el razonamiento o en el comportamiento:

 
| |**Basado en humanos**|**Racionalidad Ideal**|
|---|---|---|
|**Basado en razonamiento**|Sistemas que piensan  como humanos|Sistemas que piensan  racionalmente|
**Basado en comportamiento**|Sistemas que actúan  como humanos|Sistemas que actúan  racionalmente|


1. <img style="float:right;margin:0 10px 10px 0; width:300px"  src="http://www.atariarchives.org/deli/artificial_intelligence1.jpg"/> _**Sistemas que piensan como humanos**_: modelan las propiedades del procesamiento cognitivo de los humanos, como por ejemplo un resolvedor general de problemas y sistemas que construyen modelos internos de su mundo.
2.  _**Sistemas que actúan como humanos**_: pueden realizar cosas específicas que hacen los humanos, lo que incluye tareas como el **Test de Turing**, procesamiento de lenguaje natural, razonamiento automático, repersentación del conocimiento, aprendizaje automático, visión computacional y robótica.
3.  _**Sistemas que piensan racionalmente**_: sugiere leyes de racionalismo y un pensamiento estructurado, tales como silogismos y lógica formal. 
4.  _**Sistemas que actúan racionalmente**_: hacen cosas racionales tales como maximizar la utilidad esperada y los agentes racionales.

## Arquetipos de la Inteligencia Artificial
En cualquier caso, una de las grandes problemáticas que se observan dentro de la Inteligencia Artificial se debe a la falta de una definición clara acerca de qué se considera IA y qué no, y se puede observar que muchas de las encendidas disputas que hay al respecto tienen su origen en que los interlocutores están asumiendo definiciones distintas del tema de discusión. Es importante tener en cuenta estas diferencias ya que puede haber suposiciones provenientes de visiones distintas que pueden generar contradicciones e inconsistencias a la hora de planificar un proyecto de IA a largo plazo.

En este sentido, Beau Cronin en su artículo _[AI's dueling definitions](https://beta.oreilly.com/ideas/ais-dueling-definitions)_ presenta los siguiente arquetipos de IA, todos ellos presentes en diversas líneas de investigación y desarrollo de la IA, aunque no son los únicos posibles:

* <img style="float:right;margin:0 10px 10px 0; width:100px" src="http://www.ipodtotal.com/archivos/notas/eb7d_iris_9000_detail_0.jpg" />  **IA como interlocutor**: es el concepto que se esconde tras ideas como [HAL](https://es.wikipedia.org/wiki/HAL_9000), [Apple Siri](http://www.apple.com/es/ios/siri/), [Microsoft Cortana](https://es.wikipedia.org/wiki/Microsoft_Cortana) o [IBM Watson](http://www.ibm.com/smarterplanet/us/en/ibmwatson/), un ordenador que puede comunicarse en lenguaje natural, y que es capaz de responder a nuestras dudas de forma tan eficiente (y a veces mejor) a como lo harían expertos humanos. Mucha de la investigación más llamativa y de los productos/servicios que se desarrollan últimamente van en esta línea y son el centro de negocio de muchos de los actuales gigantes de Internet. Además, está también en la línea del famoso Test de Turing para la IA.
*   **IA como androide**: A la vista de la imaginería resultante de películas como [Blade Runner](https://es.wikipedia.org/wiki/Blade_Runner), [Yo Robot](https://es.wikipedia.org/wiki/Yo,_robot_(pel%C3%ADcula)), [Alien](https://es.wikipedia.org/wiki/Alien:_el_octavo_pasajero), [Terminator](https://es.wikipedia.org/wiki/The_Terminator), etc. es común tranferir las expectativas de estos ejemplos de ficción a los desarrollos industriales del mundo real, como lo demuestran los últimos productos de empresas como [Boston Dynamics](http://www.bostondynamics.com/) (recientemente adquirido por Google), o [SoftBank](https://www.aldebaran.com/en/a-robots/who-is-pepper) (con su nuevo robot Pepper). Para muchos entusiastas de la IA, ésta debe ser dotada de un cuerpo para que complete las verdaderas ambiciones del área. Por ahora, sin embargo, no parece ser más que un movimiento sentimental que calma nuestra necesidad de ver un componente corporal en la (limitada) inteligencia que se desarrolla.
*  <img style="float:right;margin:0 10px 10px 0" src="http://www.cs.us.es/~fsancho/images/2017-09/goodcomputerfunnel.jpg" />  **IA como razonador y resolvedor de problemas**: aunque los robots humanoides y los sistemas de conversación mantienen la atracción del público, los pioneros de la IA se dirigieron originalmente a crear sistemas mucho más refinados y orientados a actividades mentales elevadas, tales como jugar al ajedrez, generar pruebas lógicas, o planificar tareas complejas. En uno de los errores colectivos más llamativos de la ciencia, resultó que las máquinas eran especialmente aptas para la ejecución de estas tareas abstractas, y que sin embargo no sería nada fácil resolver problemas que animales con poca inteligencia aprendían a resolver de forma natural, como moverse por un entorno desconocido valorando las diversas opciones que se presentan. Los sistemas que se desarrollaron para resolver juegos como el ajedrez resultaron ser de muy poca utilidad para resolver tareas del mundo real. A pesar de ello, estas tareas superinteligentes que parecen más asequibles son las que generan las mayores reservas a la hora de plantear una inteligencia abstracta elevada, ¿qué pasaría si consiguieramos una IA que resuelva problemas generales tan bien como [Deep Blue](https://es.wikipedia.org/wiki/Deep_Blue_(computadora)) juega al ajedrez?
*   **IA como modelador de datos**: este se ha convertido en el arquetipo por excelencia en la actualidad, donde cantidades ingentes de datos son devoradas por compañías de internet y gobiernos. Así como en el pasado se equiparaba la IA con la habilidad de tener una conversación aceptable o de jugar al ajedrez, hoy en día se relaciona con la capacidad de obtener sistemas de predicción, optimización y recomendación (la mayoría de las veces orientado a fines comerciales). Esta versión de la IA le ha devuelto el halo de respetabilidad perdido tras muchos años de éxitos y fracasos alternos. Sin embargo, no parece que los paradigmas recurrentes del aprendizaje automático acerca de la clasificación, regresión, clusterización y reducción de la dimensionallidad contenga la riqueza suficiente como para expresar los problemas que una inteligencia sofisticada debe resolver.

Aunque esta lista no es exhaustiva, en ella hemos podido encontrar las principales líneas que se reconocen como parte de la IA en la actualidad. Cuál de ellas es la más prometedora es una pregunta que cae fuera de esta entrada, pero lo más seguro es que ninguna de ellas por separado pueda ser suficientemente rica como para resolver los problemas que queremos resolver, y que una combinación de ellas, junto con la creación de nuevos enfoques, puede ser una vía a seguir en el futuro de esta disciplina. 

! ## Para saber más...
! [Wikipedia: Historia de la Inteligencia Artificial](http://es.wikipedia.org/wiki/Historia\_de\_la\_inteligencia\_artificial)
! [El País: La nueva era de la computación](http://elpais.com/m/elpais/2015/07/02/eps/1435845247\_202110.html)
! [AI: 15 key moments in the story of Artificial Intelligence](http://www.bbc.co.uk/timelines/zq376fr)
