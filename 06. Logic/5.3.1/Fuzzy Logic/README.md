# netlogo-fuzzy-logic-extension
NetLogo extension that facilitates the use of fuzzy logic within NetLogo

Copyright (C) 2015 Luis R. Izquierdo & Marcos Almendres

## Contents
This folder contains:

+ subfolder fuzzy, which contains
  - Fuzzy.jar: the actual extension.
  - subfolder src: the source code.
  - subfolder doc: the documentation of the source code

+ documentation.pdf: a document explaining in detail how to use each of the functions implemented in the extension.

+ cheat-sheet.pdf: a cheat sheet with all the functions implemented in the extension.

+ tutorial.pdf: a tutorial created to illustrate how researchers can use the extension to build agent-based models in which individual agents hold their own fuzzy concepts and use their own fuzzy rules, which may also change over time.

+ fuzzy-logic-extension-model.nlogo: the Netlogo model used in the tutorial.

+ fuzzy-system-of-IF-THEN-rules.nlogo: a Netlogo program created to illustrate the so-called "Interpolation Method" for systems of fuzzy IF-THEN rules, including defuzzification. A particular instance of this method is Mamdani inference (also called max-min inference), which is often used in fuzzy control. Another particular instance is max-prod inference. You can find a detailed explanation of how this program works in the "Info" tab of the program.

## Versions
+ Version 1.0.1 (current)
  - Fixed bug: fuzzy:sum did not add more than two sets

+ Version 1.0
  - First official release.

## More on Fuzzy Logic
For further details, have a look at the paper: Izquierdo, L.R., Olaru, D., Izquierdo, S.S., Purchase, S. & Soutar, G.N. (2015). Fuzzy Logic for Social Simulation using NetLogo. Journal or Artificial Societies and Social Simulation 18 (4) 1 <[http://jasss.soc.surrey.ac.uk/18/4/1.html](http://jasss.soc.surrey.ac.uk/18/4/1.html "Introductory paper on Fuzzy Logic for Social Simulation")>. doi: 10.18564/jasss.2885
