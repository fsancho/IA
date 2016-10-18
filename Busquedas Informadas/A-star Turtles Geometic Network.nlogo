; In this case, we will work with turtles, not patches.
; Specifically with two types of turtles
breed[nodes node]         ; to represent the nodes of the network
breed[searchers searcher] ; to represent the agents that will make the search

; We don't need any extra property in the nodes. All the information will be stored
; in the searchers, and to know if a node has been explored it is enough to see of there
; is a searcher on it.

; Searchers will have som additional properties for their functioning.
searchers-own [
  memory               ; Stores the path from the start node to here
  cost                 ; Stores the real cost from the start
  total-expected-cost  ; Stores the total exepcted cost from Start to the Goal that is being computed
  localization         ; The node where the searcher is
  active?              ; is the seacrher active? That is, we have reached the node, but
                       ; we must consider it because its neighbors have not been explored
]

; Setup procedure: simply create the geometric network based on the number of random located nodes
; and the maximum radius to connect two any nodes of the network
to setup
  ca
  create-nodes Num-nodes [
    setxy random-xcor random-ycor
    set shape "circle"
    set size .5
    set color blue]
  ask nodes [
    create-links-with other nodes in-radius radius]
end

; Auxiliary procedure to test the A* algorithm between two random nodes of the network
to test
  ask nodes [set color blue set size .5]
  ask links with [color = yellow][set color grey set thickness 0]
  let start one-of nodes
  ask start [set color green set size 1]
  let goal one-of nodes with [distance start > max-pxcor]
  ask goal [set color green set size 1]
  ; We compute the path with A*
  let path (A* start goal)
  ; if any, we highlight it
  if path != false [highlight-path path]
end

; Searcher report to compute the heuristic for this searcher: in this case, one good option
; is the euclidean distance from the location of the node and the goal we want to reach
to-report heuristic [#Goal]
  report [distance [localization] of myself] of #Goal
end

; The A* Algorithm es very similar to the previous one (patches). It is supposed that the
; network is accesible by the algorithm, so we don't need to pass it as input. Therefore,
; it will receive only the initial and final nodes.
to-report A* [#Start #Goal]
  ; Create a searcher for the Start node
  ask #Start
  [
    hatch-searchers 1
    [
      set shape "circle"
      set color red
      set localization myself
      set memory (list localization) ; the partial path will have only this node at the beginning
      set cost 0
      set total-expected-cost cost + heuristic #Goal ; Compute the expected cost
      set active? true ; It is active, because we didn't calculate its neighbors yet
     ]
  ]
  ; The main loop will run while the Goal has not been reached and we have active searchers to
  ; inspect. Tha means that a path connecting start and goal is still possible
  while [not any? searchers with [localization = #Goal] and any? searchers with [active?]]
  [
    ; From the active searchers we take one of the minimal expected cost to the goal
    ask min-one-of (searchers with [active?]) [total-expected-cost]
    [
      ; We will explore its neighbors, so we deactivated it
      set active? false
      ; Store this searcher and its localization in temporal variables to facilitate their use
      let this-searcher self
      let Lorig localization
      ; For every neighbor node of this location
      ask ([link-neighbors] of Lorig)
      [
        ; Take the link that connect it to the Location of the searcher
        let connection link-with Lorig
        ; The cost to reach the neighbor in this path is the previous cost plus the lenght of the link
        let c ([cost] of this-searcher) + [link-length] of connection
        ; Maybe in this node there are other searchers (comming from other nodes).
        ; If this new path is better than the other, then we put a new searcher and remove the old ones
        if not any? searchers-in-loc with [cost < c]
        [
          hatch-searchers 1
          [
            set shape "circle"
            set color red
            set localization myself ; the location of the new searcher is this neighbor node
            set memory lput localization ([memory] of this-searcher) ; the path is built from the
                                                                     ; original searcher
            set cost c   ; real cost to reach this node
            set total-expected-cost cost + heuristic #Goal ; expected cost to reach the goal with this path
            set active? true  ; it is active to be explored
            ask other searchers-in-loc [die] ; Remove other seacrhers in this node
          ]
        ]
      ]
    ]
  ]
  ; When the loop has finished, we have two options: no path, or a searcher has reached the goal
  ; By default the return will be false (no path)
  let res false
  ; But if it is the second option
  if any? searchers with [localization = #Goal]
  [
    ; we will return the path located in the memory of the searcher that reached the goal
    let lucky-searcher one-of searchers with [localization = #Goal]
    set res [memory] of lucky-searcher
  ]
  ; Remove the searchers
  ask searchers [die]
  ; and report the result
  report res
end

; Auxiliary procedure the highlight the path when it is found. It makes use of reduce procedure with
; highlight report
to highlight-path [path]
  let a reduce highlight path
end

; Auxiliaty report to highlight the path with a reduce method. It recieives two nodes, as a secondary
; effect it will highlight the link between them, and will return the second node.
to-report highlight [x y]
  ask x
  [
    ask link-with y [set color yellow set thickness .4]
  ]
  report y
end

; Auxiliary nodes report to return the searchers located in it (it is like a version of turtles-here,
; but fot he network)
to-report searchers-in-loc
  report searchers with [localization = myself]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
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
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
22
76
85
109
NIL
setup\n
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
131
76
194
109
NIL
test
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
22
10
194
43
radius
radius
0
10
1.4
.1
1
NIL
HORIZONTAL

SLIDER
22
43
194
76
Num-Nodes
Num-Nodes
0
1000
1000
50
1
NIL
HORIZONTAL

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

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

@#$#@#$#@
0
@#$#@#$#@
