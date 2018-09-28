extensions [ nw string]

breed [nodes node]

nodes-own [
  betweenness
  eigenvector
  closeness
  clustering
  page-rank
  phi
  visits
  rank
  new-rank
  infected
  typ
]

globals [
  diameter
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  clear
end

to clear
  ca
  clear-all-plots
  set-default-shape nodes "circle"
end

to run-commands
  let cms string:rex-split script "\n"
  foreach cms [run ?]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generators / Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to ER-RN [N p]
  create-nodes N [
    setxy random-xcor random-ycor
    set color red
  ]
  ask nodes [
    ask other nodes [
      if random-float 1 < p [
        create-link-with myself
      ]
    ]
  ]
  post-process
end

to WS [N k p]
  create-nodes N [
    set color red
  ]
  layout-circle sort nodes max-pycor * 0.9
  let lis (n-values (K / 2) [? + 1])
  ask nodes [
    let w who
    foreach lis [create-link-with (node ((w + ?) mod N))]
  ]
  rewire p
  post-process
end

to rewire [p]
  ask links [
    let rewired? false
    if (random-float 1) < p
    [
      ;; "a" remains the same
      let node1 end1
      ;; if "a" is not connected to everybody
      if [ count link-neighbors ] of node1 < (count nodes - 1)
      [
        ;; find a node distinct from node1 and not already a neighbor of node1
        let node2 one-of nodes with [ (self != node1) and (not link-neighbor? node1) ]
        ;; wire the new edge
        ask node1 [ create-link-with node2 [ set rewired? true ] ]
      ]
    ]
    ;; remove the old edge
    if (rewired?)
    [
      die
    ]
  ]
end

to BA-PA [N m0 m]
  create-nodes m0 [
    set color red
  ]
  ask nodes [
    create-links-with other nodes
  ]
  repeat (N - m0) [
    create-nodes 1 [
      set color blue
      let new-partners turtle-set map [find-partner] (n-values m [?])
        create-links-with new-partners
    ]
  ]
  post-process
end


;; This code is the heart of the "preferential attachment" mechanism, and acts like
;; a lottery where each node gets a ticket for every connection it already has.
;; While the basic idea is the same as in the Lottery Example (in the Code Examples
;; section of the Models Library), things are made simpler here by the fact that we
;; can just use the links as if they were the "tickets": we first pick a random link,
;; and than we pick one of the two ends of that link.
to-report find-partner
  report [one-of both-ends] of one-of links
end


to KE [N m0 mu]
  create-nodes m0 [
    set color red
  ]
  ask nodes [
    create-links-with other nodes
  ]
  let active nodes with [self = self]
  let no-active no-turtles
  repeat (N - m0) [
    create-nodes 1 [
      set color blue
      foreach shuffle (sort active) [
        let ac ?
        ifelse (random-float 1 < mu or count no-active = 0)
        [
          create-link-with ac
        ]
        [
          let cut? false
          while [not cut?] [
            let nodej one-of no-active
            let kj [count my-links] of nodej
            let S sum [count my-links] of no-active
            if (kj / S) > random-float 1 [
              create-link-with nodej
              set cut? true
            ]
          ]
        ]
      ]
      set active (turtle-set active self)
      let cut? false
      while [not cut?] [
        let nodej one-of active
        let kj [count my-links] of nodej
        let S sum [1 / (count my-links)] of active
        let P (1 / (kj * S))
        if P > random-float 1 [
          set no-active (turtle-set no-active nodej)
          set active active with [self != nodej]
          set cut? true
        ]
      ]
    ]
  ]
  post-process
end

to Geom [N r]
  create-nodes N [
    setxy random-xcor random-ycor
    set color blue
  ]
  ask nodes [
    create-links-with other nodes in-radius r
  ]
  post-process
end

to SCM [N g]
  create-nodes N [
    setxy random-xcor random-ycor
    set color blue
  ]
  let num-links (g * N) / 2
  while [count links < num-links ]
  [
    ask one-of nodes
    [
      let choice (min-one-of (other nodes with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]
  post-process
end

to Grid [N M torus?]
  nw:generate-lattice-2d nodes links N M torus?
  ask nodes [set color blue]
  post-process
end

to BiP [nb-nodes nb-links]
  create-nodes nb-nodes [
    set typ one-of [0 1]
  ]
  let P0 nodes with [typ = 0]
  let P1 nodes with [typ = 1]
  repeat nb-links [
    ask one-of P0 [
      create-link-with one-of P1
    ]
  ]
  post-process
end

to Edge-Copying [Iter pncd k beta pecd]
  repeat Iter [
    ; Creation / Deletion of nodes
    ifelse random-float 1 > pncd
    [
      ask one-of nodes [die]
    ]
    [
      create-nodes 1 [
        setxy random-xcor random-ycor
        set color blue
      ]
    ]
    ; Edge Creation
    let v one-of nodes
    ifelse random-float 1 < beta
    [
      ;crea
      ask v [
        let other-k-nodes (other nodes) with [not link-neighbor? v]
        if count other-k-nodes >= k
        [
          set other-k-nodes n-of k other-k-nodes
        ]
        create-links-with other-k-nodes
      ]
    ]
    [
      ; copia
      let n k
      while [n > 0] [
        let u one-of other nodes
        let other-nodes (([link-neighbors] of u) with [self != v])
        if count other-nodes > k [
          set other-nodes n-of k other-nodes
        ]
        ask v [
          create-links-with other-nodes
        ]
        set n n - (count other-nodes)
        ]
    ]
    ; Creation / Deletion of edges
    ifelse random-float 1 < pecd [
      ask one-of nodes with [count my-links < (count nodes - 1)][
        let othernode one-of other nodes with [not link-neighbor? myself]
        create-link-with othernode
      ]
    ]
    [
      ask one-of links [die]
    ]
  ]
  post-process
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Centrality Measures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Takes a centrality measure as a reporter task, runs it for all nodes
;; and set labels, sizes and colors of turtles to illustrate result
to compute-centrality
  nw:set-context nodes links
  ask nodes [
    set betweenness nw:betweenness-centrality
    set eigenvector nw:eigenvector-centrality
    set closeness nw:closeness-centrality
    set clustering nw:clustering-coefficient
    set page-rank nw:page-rank
  ]
  update-plots
end

to plot-degree
  Let Dk [count my-links] of nodes
  let M max Dk
  set-current-plot "Degree Distribution"
  set-plot-x-range 0 (M + 1)
  set-plot-y-range 0 1
  histogram Dk
end

to plot-page-rank
  Let Dk [page-rank] of nodes
  let M max Dk
  set-current-plot "PageRank Distribution"
  set-plot-x-range 0 (M + M / 100)
  set-plot-y-range 0 1
  set-histogram-num-bars 100
  histogram Dk
end

to plot-betweenness
  Let Dk [nw:betweenness-centrality] of nodes
  let M max Dk
  set-current-plot "Betweenness Distribution"
  set-plot-x-range 0 (ceiling M)
  set-plot-y-range 0 1
  set-histogram-num-bars 100
  histogram Dk
end

to plot-eigenvector
  Let Dk [nw:eigenvector-centrality] of nodes
  let M max Dk
  set-current-plot "Eigenvector Distribution"
  set-plot-x-range 0 (ceiling M)
  set-plot-y-range 0 1
  set-histogram-num-bars 100
  histogram Dk
end

to plot-closeness
  Let Dk [nw:closeness-centrality] of nodes
  let M max Dk
  set-current-plot "Closeness Distribution"
  set-plot-x-range 0 (ceiling M)
  set-plot-y-range 0 1
  set-histogram-num-bars 100
  histogram Dk
end

to plot-clustering
  Let Dk [nw:clustering-coefficient] of nodes
  let M max Dk
  set-current-plot "Clustering Distribution"
  set-plot-x-range 0 (ceiling M)
  set-plot-y-range 0 1
  set-histogram-num-bars 100
  histogram Dk
end

to plots
  clear-all-plots
  compute-centrality
  carefully [plot-page-rank][]
  carefully [plot-degree][]
  carefully [plot-betweenness][]
  carefully [plot-eigenvector][]
  carefully [plot-closeness][]
  carefully [plot-clustering][]
  carefully [set diameter compute-diameter 1000][]
end

;; We want the size of the turtles to reflect their centrality, but different measures
;; give different ranges of size, so we normalize the sizes according to the formula
;; below. We then use the normalized sizes to pick an appropriate color.
to normalize-sizes-and-colors [c]
  if count nodes > 0 [
    let sizes sort [ size ] of nodes ;; initial sizes in increasing order
    let delta last sizes - first sizes ;; difference between biggest and smallest
    ifelse delta = 0 [ ;; if they are all the same size
      ask nodes [ set size 1 ]
    ]
    [ ;; remap the size to a range between 0.5 and 2.5
      ask nodes [ set size ((size - first sizes) / delta) * 1.5 + 0.4 ]
    ]
    ask nodes [ set color lput 200 extract-rgb scale-color c size 3.8 0] ; using a higher range max not to get too white...
  ]
end

; The diameter is cpmputed from a random search on distances between nodes
to-report compute-diameter [n]
  let s 0
  repeat n [
    ask one-of nodes [
      set s max (list s (nw:distance-to one-of other nodes))
    ]
  ]
  report s
end

to compute-phi
  ask nodes [
    set phi sum [exp -1 * ((nw:distance-to myself) ^ 2  / 100)] of nodes
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layouts & Visuals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to layout-once
  if layout = "radial" and count nodes > 1 [
    layout-radial nodes links ( max-one-of nodes [ count my-links ] )
  ]
  if layout = "spring" [
      layout-spring turtles links spring-K length-K rep-K
  ]
  if layout = "circle" [
    layout-circle sort nodes max-pycor * 0.9
  ]
  if layout = "bipartite" [
    layout-bipartite
  ]
  if layout = "tutte" [
    layout-circle sort nodes max-pycor * 0.9
    repeat 10 [
      layout-tutte max-n-of (count nodes * 0.5) nodes [ count my-links ] links 12
    ]
  ]
end

to layout-bipartite
  let P0 nodes with [typ = 0]
  let incp0 world-width / (1 + count p0)
  let P1 nodes with [typ = 1]
  let incp1 world-width / (1 + count p1)
  let x min-pxcor
  ask P0 [
    set color red
    setxy x max-pycor - 1
    set x x + incp0]
  set x min-pxcor
  ask P1 [
    set color blue
    setxy x min-pycor + 1
    set x x + incp1]
end

to refresh
  ask nodes [
    set size Size-N * size
    set label ""
;    set color red
  ]
  ask links [
    set color [150 150 150 100]
  ]
end

to post-process
  ask links [
    set color [150 150 150 100]
  ]
  set diameter compute-diameter 1000
end

to spring
  layout-spring turtles links spring-K length-K rep-K
  ask nodes [
    setxy (xcor * (1 - gravity / 1000)) (ycor * (1 - gravity / 1000))
  ]
end

to help
  user-message (word "Generators (see Info Tab):" "\n"
    "* ER-RN (N, p)" "\n"
    "* Small-World (N, k, p)" "\n"
    "* BA-PA (N, m0, m)" "\n"
    "* KE (N, m0, mu)" "\n"
    "* Geom (N, r)" "\n"
    "* SCM (N, g)" "\n"
    "* Grid (N,M,t?)" "\n"
    "* BiP (N, M)" "\n"
    "* Edge-Copying (N, pn, k, b, pe)" "\n"
    "-----------------------------" "\n"
    "* PRank (Iter)" "\n"
    "* Rewire (p)" "\n"
    "* Spread (Ni, ps, pr, pin, Iter)" "\n"
    "* DiscCA (Iter, pIn, p0_ac, p1_ac)" "\n"
    "* ContCA (Iter, pIn, p)" "\n"
    "-----------------------------" "\n"
    "* Save-Graphml file-name" "\n"
    "* Load-Graphml file-name")
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Saving and loading of network files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to save-graphml
  nw:set-context nodes links
  nw:save-graphml "demo.graphml"
end

to load-graphml
  nw:set-context nodes links
  nw:load-graphml "demo.graphml"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Page Rank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to PRank [n]
  let damping-factor 0.85
  ;ask links [ set color gray set thickness 0 ]
  ask nodes [
    set rank 1 / count nodes
    set new-rank 0 ]
  repeat N [
    ask nodes
    [
      ifelse any? link-neighbors
      [
        let rank-increment rank / count link-neighbors
        ask link-neighbors [
          set new-rank new-rank + rank-increment
        ]
      ]
      [
        let rank-increment rank / count nodes
        ask nodes [
          set new-rank new-rank + rank-increment
        ]
      ]
    ]
    ask nodes
    [
      ;; set current rank to the new-rank and take the damping-factor into account
      set rank (1 - damping-factor) / count nodes + damping-factor * new-rank
    ]
  ]

  let total-rank sum [rank] of nodes
  let max-rank max [rank] of nodes
  ask nodes [
    set size 0.2 + 2 * (rank / max-rank)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spread
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to spread [N-mi ps pr pin Iter]
  let t 0
  set-current-plot "General"
  clear-plot
  foreach [["Green" green] ["Red" red] ["Blue" blue]] [
    create-temporary-plot-pen first ?
    set-current-plot-pen first ?
    set-plot-pen-color last ?
    set-plot-pen-mode 0
  ]
  ask nodes [
    set infected 0
    set color green
  ]
  ask n-of N-mi nodes [
    set infected 1
    set color red
  ]
  repeat Iter [
    ask nodes with [infected = 1]
    [ ask link-neighbors with [infected = 0]
      [ if random-float 1 < ps
        [ set infected 1
          set color red
        ] ] ]
    ask nodes with [infected = 1]
    [ if random-float 1 < pr
      [ set color green
        set infected 0
        if random-float 1 < pin
        [ set color blue
          set infected 2
        ]
      ] ]
    set t t + 1
    set-current-plot-pen "Green"
    plotxy t count nodes with [infected = 0]
    set-current-plot-pen "Red"
    plotxy t count nodes with [infected = 1]
    set-current-plot-pen "Blue"
    plotxy t count nodes with [infected = 2]

    display
    wait 2 / Iter
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cellular Automata
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Uses Typ = [current-state new-state] to store the state of the node


; Discrete value states
; Iter - Number of iterations
; pI - Initial Probability of activation
; p0_ac - ratio of activated neighbors to activate if the node is 0
; p1_ac - ratio of activated neighbors to activate if the node is 1

to DiscCA [Iter pIn p0_ac p1_ac]
  set-current-plot "General"
  clear-plot
  set-plot-y-range 0 1
  let t 0
  ask nodes [
    ifelse random-float 1 < pIn
    [ set typ [1]]
    [ set typ [0]]
    set color ifelse-value (current_state = 0) [red][blue]
  ]
  repeat Iter [
    no-display
    ask nodes [
      let s current_state
      let pn 0
      if any? link-neighbors [
        set pn count (link-neighbors with [current_state = 1]) / count link-neighbors
      ]
      ifelse s = 0
      [
        ifelse pn >= p0_ac
        [ new-state 1 ]
        [ new-state 0 ]
      ]
      [
        ifelse pn >= p1_ac
        [ new-state 1 ]
        [ new-state 0 ]
      ]
    ]
    ask nodes [
      set-state
      set color ifelse-value (current_state = 0) [red][blue]
    ]
    plotxy t count (nodes with [current_state = 1]) / count nodes
    set t t + 1
    display
    ;wait .01
  ]
end

; Continuous value states
; Iter - Number of iterations
; pI - Initial Probability of activation
; p - ratio of memory in the new state

to ContCA [Iter pIn p]
  set-current-plot "General"
  clear-plot
  set-plot-y-range 0 1
  let t 0
  ask nodes [
    set typ (list random-float pIn)
    set color scale-color blue current_state 0 1
  ]
  repeat Iter [
    no-display
    ask nodes [
      let s current_state
      let pn sum ([current_state] of link-neighbors) / count link-neighbors
      new-state (p * current_state + (1 - p) * pn)
    ]
    ask nodes [
      set-state
    set color scale-color blue current_state 0 1
    ]
    plotxy t sum ([current_state] of nodes) / count nodes
    set t t + 1
    display
    ;wait .01
  ]
end

; Get the current state of the node
to-report current_state
  report first typ
end

; Set the new state of the node to s
to new-state [s]
  set typ (lput s typ)
end

; Move the new state to the current state
to set-state
  set typ (list (last typ))
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



@#$#@#$#@
GRAPHICS-WINDOW
10
10
709
470
26
16
13.0
1
10
1
1
1
0
0
0
1
-26
26
-16
16
0
0
1
ticks
30.0

PLOT
710
10
910
130
Degree Distribution
Degree
Nb Nodes
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -7500403 true "" "histogram [count my-links] of nodes"

CHOOSER
10
470
102
515
layout
layout
"circle" "radial" "tutte" "bipartite" "spring"
2

SLIDER
104
470
196
503
spring-K
spring-K
0
1
0.47
.01
1
NIL
HORIZONTAL

SLIDER
199
470
291
503
length-K
length-K
0
5
0.58
.01
1
NIL
HORIZONTAL

SLIDER
294
470
386
503
rep-K
rep-K
0
2
0.052
.001
1
NIL
HORIZONTAL

SLIDER
105
505
197
538
size-N
size-N
0
2
1.1
.1
1
NIL
HORIZONTAL

BUTTON
485
470
540
503
O-O
layout-once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
545
470
600
503
Spring
spring
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
200
505
255
538
NIL
refresh
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
710
130
910
250
Betweenness Distribution
Betweenness
Nb Nodes
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -8630108 true "" "histogram [betweenness] of nodes"

PLOT
910
10
1110
130
Eigenvector Distribution
Eigenvector
Nb Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -2674135 true "" ""

PLOT
910
130
1110
250
Closeness Distribution
Closeness
Nb Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -6459832 true "" ""

PLOT
710
250
910
370
Clustering Distribution
Clustering
Nb nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -10899396 true "" ""

BUTTON
910
370
1110
403
 _Λ_Λ_Λ_
Plots
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
260
505
315
538
clear
clear
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
710
370
772
415
Avg Pth L
nw:mean-path-length
3
1
11

MONITOR
775
370
837
415
Avg Clust
mean [clustering] of nodes
3
1
11

MONITOR
840
370
900
415
Avg Degr
mean [count my-links] of nodes
3
1
11

BUTTON
850
25
905
58
.o0O
ask nodes [set size (count my-links)]\nnormalize-sizes-and-colors 5
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1050
25
1105
58
.o0O
ask nodes [set size eigenvector]\nnormalize-sizes-and-colors 15
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
850
145
905
178
.o0O
ask nodes [set size betweenness]\nnormalize-sizes-and-colors violet\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1050
145
1105
178
.o0O
ask nodes [set size closeness]\nnormalize-sizes-and-colors 35
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
850
265
905
298
.o0O
ask nodes [set size clustering]\nnormalize-sizes-and-colors 55
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
910
250
1110
370
PageRank Distribution
Page-Ranking
Nb Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -13345367 true "" ""

BUTTON
1050
265
1105
298
.o0O
ask nodes [set size page-rank]\nnormalize-sizes-and-colors blue
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
710
420
760
465
Nb Nodes
count nodes
0
1
11

MONITOR
760
420
810
465
Nb Links
count Links
0
1
11

MONITOR
810
420
860
465
Density
2 * (count links) / ( (count nodes) * (-1 + count nodes))
3
1
11

INPUTBOX
1115
75
1275
255
Script
clear\nBA-PA 300 2 1\n
1
1
String (commands)

BUTTON
1220
220
1275
253
==>
run-commands
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
910
405
1110
525
General
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

INPUTBOX
1115
15
1275
75
OneCommand
Geom 300 5
1
0
String (commands)

BUTTON
1220
10
1275
43
~~>
run OneCommand
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
860
420
910
465
Diameter
diameter
0
1
11

BUTTON
1165
70
1220
103
?
help
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
390
470
482
503
gravity
gravity
0
10
1
1
1
NIL
HORIZONTAL

@#$#@#$#@
## Generators

### Erdős-Rényi Random Network:

In fact this is the Gilbert variant of the model introduced by Erdős and Rényi. Each edge has a fixed probability of being present (p) or absent (1-p), independently of the other edges.

N - Number of nodes,
p - link probability of wiring

    ER-RN N p

![Erdos-Renyi](http://mathworld.wolfram.com/images/eps-gif/RandomGraphs_1000.gif)

### Watts & Strogatz Small Worlds Networks:

The Watts–Strogatz model is a random graph generation model that produces graphs with small-world properties, including short average path lengths and high clustering. It was proposed by Duncan J. Watts and Steven Strogatz in their joint 1998 Nature paper.

Given the desired number of nodes N, the mean degree K (assumed to be an even integer), and a probability p, satisfying N >> K >> ln(N) >> 1, the model constructs an undirected graph with N nodes and NK/2 edges in the following way:

  1. Construct a regular ring lattice, a graph with N nodes each connected to K neighbors, K/2 on each side.
  2. Take every edge and rewire it with probability p. Rewiring is done by replacing (u,v) with (u,w) where w is chosen with uniform probability from all possible values that avoid self-loops (not u) and link duplication (there is no edge (u,w) at this point in the algorithm).

N - Number of nodes,
k - initial degree (even),
p - rewiring probability

    WS N k p

![WS](http://www.nature.com/nature/journal/v393/n6684/images/393440aa.eps.2.gif)

### Barabasi & Albert Preferential Attachtment:

The Barabási–Albert (BA) model is an algorithm for generating random scale-free networks using a preferential attachment mechanism. Scale-free networks are widely observed in natural and human-made systems, including the Internet, the world wide web, citation networks, and some social networks. The algorithm is named for its inventors Albert-László Barabási and Réka Albert.

The network begins with an initial connected network of m_0 nodes.

New nodes are added to the network one at a time. Each new node is connected to m <= m_0 existing nodes with a probability that is proportional to the number of links that the existing nodes already have. Formally, the probability p_i that the new node is connected to node i is

             k_i
    p_i = ----------
          sum_j(k_j)

where k_i is the degree of node i and the sum is made over all pre-existing nodes j (i.e. the denominator results in twice the current number of edges in the network). Heavily linked nodes ("hubs") tend to quickly accumulate even more links, while nodes with only a few links are unlikely to be chosen as the destination for a new link. The new nodes have a "preference" to attach themselves to the already heavily linked nodes.

N - Number of nodes,
m0 - Initial complete graph,
m - Number of links in new nodes

    BA-PA N m0 m

![BA](http://graphstream-project.org/media/img/barabasiAlber1.png)

### Klemm and Eguílez Small-World-Scale-Free Network:

The algorithm of Klemm and Eguílez manages to combine all three properties of many “real world” irregular networks – it has a high clustering coefficient, a short average path length (comparable with that of the Watts and Strogatz small-world network), and a scale-free degree distribution. Indeed, average path length and clustering coefficient can be tuned through a “randomization” parameter, mu, in a similar manner to the parameter p in the Watts and Strogatz model.

It begins with the creation of a fully connected network of size m0. The remaining N−m0 nodes in the network are introduced sequentially along with edges to/from m0 existing nodes. The algorithm is very similar to the Barabási and Albert algorithm, but a list of m0 “active nodes” is maintained. This list is biased toward containing nodes with higher degrees.

The parameter μ is the probability with which new edges are connected to non-active nodes. When new nodes are added to the network, each new edge is connected from the new node to either a node in the list of active nodes or with probability μ, to a randomly selected “non-active” node. The new node is added to the list of active nodes, and one node is then randomly chosen, with probability proportional to its degree, for removal from the list, i.e., deactivation. This choice is biased toward nodes with a lower degree, so that the nodes with the highest degree are less likely to be chosen for removal.

N -  Number of nodes,
m0 - Initial complete graph,
μ - Probability of connect with low degree nodes

    KE N m0 μ

### Geometric Network:

It is a simple algorithm to be used in metric spaces. It generates N nodes that are randomly located in 2D, and after that two every nodes u,v are linked if d(u,v) < r (a prefixed radius).

N - Number of nodes,
r - Maximum radius of connection

    Geom N r

![GN](http://i.stack.imgur.com/f8erO.png)

### Spatially Clustered Network:

This algorithm is similar to the geometric one, but we can prefix the desired mean degree of the network, g. It starts by creating N randomly located nodes, and then create the number of links need to reach the desired mean degree. This link creation is random in the nodes, but choosing the shortest links to be created from them.

N - Number of nodes,
g - Average node degree

    SCM N g

### Grid (2D-lattice):

A Grid of N x M nodes is created. It can be chosen to connect edges of the grid as a torus (to obtain a regular grid).

M - Number of horizontal nodes
N - Number of vertical nodes
t? - torus?

    Grid N M t?

![Grid](http://www.gigaflop.co.uk/comp/fig3_2_2_1-1.gif)

### Bipartite:

Creates a Bipartite Graph with N nodes (randomly typed to P0 P1 families) and M random links between nodes of different families.

N - Number of nodes
M - Number of links

    BiP N M

![Bip](http://www.ics.uci.edu/~eppstein/0xDE/bicycle-minor/bipartite.png)

### Edge Copying Dynamics

The model introduced by Kleinberg et al consists of a itearion of three steps:

  1. __Node creation and deletion__: In each iteration, nodes may be independently created and deleted under some probability distribution. All edges incident on the deleted nodes are also removed. pncd - creation, (1 - pncd) deletion.

  1. __Edge creation__: In each iteration, we choose some node v and some number of edges k to add to node v. With probability β, these k edges are linked to nodes chosen uniformly and independently at random. With probability 1 − β, edges are copied from another node: we choose a node u at random, choose k of its edges (u, w), and create edges (v, w). If the chosen node u does not have enough edges, all its edges are copied and the remaining edges are copied from another randomly chosen node.

  1. __Edge deletion__: Random edges can be picked and deleted according to some probability distribution.


Iter - Number of Iterations
pncd - probability of creation/deletion random nodes
k - edges to add to the new node
beta - probability of new node to uniform connet/copy links
pecd - probability of creation/deletion random edges

    Edge-Copying Iter pncd k beta pecd



## Utilities

### Page Rank

Applies the Page Rank diffusion algorithm to the current Network a number of prefixed iterations.

Iter - Number of iterations

    PRank Iter

![PR](http://3.bp.blogspot.com/-O_lDNCgia7s/URPR8mDUrFI/AAAAAAAAD5o/cdWts4tr8n0/s1600/pagerank+Network.JPG)

### Rewire

Rewires all the links of the current Network with a probability p. For every link, one of the nodes is fixed, while the other is rewired.

p - probability of rewire every link

    Rewire p


### Spread of infection/message

Applies a spread/infection algorithm on the current network a number of iterations. It starts with a initial number of infected/informed nodes and in every step:

  1. The infected/informed nodes can spread the infection/message to its neighbors with probability ps (independently for every neighbor).

  1. Every infected/informed node can recover/forgot with a probability of pr.

  1. Every recovered node can become inmunity with a probability of pin. In this case, he will never again get infected / receive the message, and it can't spread it.

N-mi - Number of initial infected nodes
ps - Probability of spread of infection/message
pr - Probability od recovery / forgotten
pin - Probability of inmunity after recovering
Iter - Number of iterations

    Spread N-mi ps pr pin Iter

![Spread](http://www.aquaculture.stir.ac.uk/public/aphaw/images/diseasespread.png)

### Save GraphML / Load GraphML
f - file-name

    Save-graphml f
    Load-graphml f

![GrpahML](http://viasco.lcc.uma.es/images/d/da/Graphml.jpg)

## Cellular Automata

### Discrete Totalistic Cellular Automata

The nodes have 2 possible values: on/off. In every step, every node changes its state according to the ratio of activated states.

Iter - Number of iterations
pIn - Initial Probability of activation
p0_ac - ratio of activated neighbors to activate if the node is 0
p1_ac - ratio of activated neighbors to activate if the node is 1

    DiscCA Iter pIn p0_ac p1_ac

### Continuous Totalistic Cellular Automata

The nodes have a continuous possitive value for state: [0,..]. In every step, every node changes its state according to the states of the neighbors:

    s'(u) = p * s(u) + (1 - p) * avg {s(v): v neighbor of u}

Iter - Number of iterations
pIn - Initial Probability of activation
p - ratio of memory in the new state

    ContCA Iter pIn p

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 15 15 270
Circle -1 false false 15 15 268

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

curve
1.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
