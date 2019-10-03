In this folder you can find several models and libraries related to Propositional Logic in NetLogo (LP) (and also the Extension Fuzzy Logic, it is not mine):

* __Fuzzy Logic__
* __LP.nls__: the main library. The main functions are detailed bellow, and there are also several models to illustrate how it works (`Tree&CNF.nlogo`, `TS.nlogo`, `DPLL.nlogo`, `DPLL - Consecuencia Lógica.nlogo`).
* __RBS.nls__: library for a simple Rule Based System (Knowledge Bases). There are several models with it (`RuleBasedSystemForwardReasoning Agents.nlogo` and `RuleBasedSystemForwardReasoning.nlogo`).
* __Resolucion LP.nlogo__, __ResolutionPropositionalLogic.nlogo__: some models that performs resolution procedure (in a near future, it will be integrated with __LP__ library).

# LP Library

In the following:

* `S`: Formula in string format
* `L`: Formula in tree (list) format
* `C`: Formula in Clause format (list of lists of literals)

In the algorithms using graphs (trees with NetLogo agents) we work with families LP:nodes (turtle breed) and
LP:links (directed link breed)

## ParseCNFLP

* __LP:parse-to-tree S__: Transforms a formula in string format to tree (list) format

```
    LP:parse-to-tree "((a->b)|(-c))" : ["|" ["->" "a" "b"] ["-" "c"]]
    LP:parse-to-tree "(a <-> (b|c))" : ["<->" "a" ["|" "b" "c"]]
```
	
* __LP:pretty-formula L__: Rewrites a single tree-list formula into infix way string using pretty symbols

```
    LP:pretty-formula ["|" ["->" "a" "b"] ["-" "c"]] : "((a→b)v¬c)"
```

* __LP:pretty-set S__: Rewrites (pretty) all the formulas in a set of formulas

```
	LP:pretty-set [["|" ["->" "a" "b"] ["-" "c"]] ["&" ["<->" "a" "b"] ["-" "c"]]] : "{((a→b)v¬c) , ((a↔b)^¬c)}"
```

* __LP:TreeLayout L__: Visual representation of the formula `L` (in tree-list format)

* __LP:extract-vars S__: Returns a list of pairs `[var n]` to identify vars of a formula with natural numbers 
(the vars are sorted in alphabetical order)

```
	LP:extract-vars "(p->q)"     : [["p" 1] ["q" 2]]
	LP:extract-vars "(-(b&c)|a)" : [["a" 1] ["b" 2] ["c" 3]]
```

* __LP:CNF L__: Takes a formula tree and convert it into CNF (returns `(- a)`...)

```
	LP:CNF ["|" ["->" "a" "b"] ["-" "c"]] : ["|" ["|" ["-" "a"] "b"] ["-" "c"]]
	LP:CNF ["<->" "a" ["|" "b" "c"]] : ["&" ["|" ["-" "a"] ["|" "b" "c"]] ["&" ["|" ["-" "b"] "a"] ["|" ["-" "c"] "a"]]]
```

* __LP:CNF2 L__: Takes a formula tree and convert it into CNF, In contrast with previous version, 
this one returns literals (`-a`,`-b`,...)

```
	LP:CNF2 ["|" ["->" "a" "b"] ["-" "c"]] : ["|" ["|" "-a" "b"] "-c"]
	LP:CNF2 ["<->" "a" ["|" "b" "c"]] : ["&" ["|" "-a" ["|" "b" "c"]] ["&" ["|" "-b" "a"] ["|" "-c" "a"]]]
```

* __LP:clause-form L__: Clause Form conversion from CNF2 formula

```
	LP:clause-form ["|" ["|" "-a" "b"] "-c"] : [["-a" "b" "-c"]]
	LP:clause-form ["&" ["|" "-a" ["|" "b" "c"]] ["&" ["|" "-b" "a"] ["|" "-c" "a"]]] : [["-a" "b" "c"] ["-b" "a"] ["-c" "a"]]
```

* __LP:CleanCF L__: Returns a Clause Form removing duplicated clauses and tautologies (works with CNF and CNF2)

```
	LP:cleanCF [["-a" "b" "-a"]] : [["-a" "b"]]
	LP:cleanCF [["-a" "b"] ["-a" "b"] ["-a" "-b"]] : [["-a" "b"] ["-a" "-b"]]
```

## Semantic Tableau (TS)

* __LP:TS L__: Performs the Semantic Tableau of a tree-list formula (return the complete tree)

(see sample models)

## DPLL

* __LP:DPLL C #debug__: applies DPLL (building the tree of clause sets) to a set of clause forms. (Reports `true/false`)

(see sample models)

## Logical Consequence

* __LP:DPLL-Consequence? f S #debug__: Uses DPLL to see if `f` (string) is a logical consequence of `S` (list of strings). 
(Reports `true/false`)

(see sample models)

## ToDo

* Add Resolution to LP.
* Add Forward Chaining to LP (RBS will be a part of LP).
* Add __LP:TS-Consequence?__, __LP:SAT?__, __LP:TAUT?__,...
* Add `eval` function to evaluate formulas in valuations.
* Add Truth tables.
* Add some models that make use of LP for _intelligent agents_.
* Add some approach to __First Order Logic__ (write and decode formulas, unification, Herbrand, resolution,...)-> In a _LPO_ library.
