globals
[
  obstacle-color ;; color of obstacles--see information about this
  space-color    ;; color of open space
  border-color   ;; color of the world border
]

breed [ bots bot ]       ;; bots use a*nodes to search the space
breed [ a*nodes a*node ] ;; each a*node occupies a place on the grid, contains the cost to get there
breed [ maza mazum ]     ;; a mazum is used to draw mazes.
breed [ indicators indicator ]

a*nodes-own
[ owner  ;; the bot that owns this node
  parent ;; the node that is the parent (that comes earlier in the path) of this node
  child  ;; the node that is the child (comes later in the path) of this node (not standard a*)
  g-score  ;; stores the cummulative cost of arriving at this point from the start
  h-score  ;; stores the estimated cost of getting from this point to the goal/target
  f-score  ;; the sum of g and h
  location ;; the patch that contains this node (duplicates "patch-here" when the node is on the path, but can be used in an -of expression, unlike patch-here)
  closed?  ;; node are open (0), or closed (1). Nodes start out open
  ; target   ;; copy of the PATCH that is the target patch
  ; start    ;; copy of the PATCH that is the start patch
  on-path? ;; is this node on the final route (or route-so-far, if needed) of the path to the target
]

bots-own
[ start     ;; the patch that the search starts from, may not be the current patch
  target    ;; the patch that is the goal / target of the search
  owner     ;; the owner of the search---always the bot itself... exists so it can be inherited by the a*nodes
  child     ;; the child of this bot is the first a*node of the path.. the a*node on the start
  g-score   ;; the bots own g-score is 0, unless the bot moves along its own path... then it might change...
  path-end  ;; the a*node at the end of the path... is nobody until the goal/target is reached.
            ;; the path-end node is the only node that can construct the entire path back to the start
  done?     ;; boolean that indicates the search is over--may mean that no path can be found
  current   ;; the current a*node being examined or expanding the search
  o-current ;; the node that was previously current
  d-mode    ;; directions mode, either 4 or 8
  heuristic ;; heuristic-mode used by this bot
]


maza-own
[ maze-wall-color        ;; color of maze walls--also color of unexplorred (not carved) paths
  maze-breadcrumb-color ;; color of bread-crumb trail, used to backtrack
  maze-path-color        ;; final color of carved-out paths in the maze
  maze-border-color      ;; color of maze-border
  maze-curviness         ;; probability that maza will choose a non-straight ahead path
  maze-timeout
]

to startup
   setup
end

to setup
  ca

   ;;
   ;; Initialize the color variables
   ;;

   set obstacle-color blue
   set border-color pink
   set space-color black
   let bread-crumb-color red


   ;;
   ;; define the start and target patches
   ;; (for this demo, they are fixed, but you they could be dynamic
   ;;

   let setup-start patch (min-pxcor + 2) ( min-pycor + 2 )
   let setup-target patch (max-pxcor - 2) ( max-pycor - 2 )

   ;;
   ;; Setup the search space, based on the selected senario
   ;;

   ;;
   ;; A completely blank field
   ;;

   if senario = "blank"
   [ fill-patches space-color
     do-terrain
     border
   ]

   ;;
   ;; A Random scattering of obstaces
   ;;

   if senario = "random" ;; random scattering of patches
   [ do-terrain
     ask patches [ if random 100 < density [ set pcolor obstacle-color ] ]
     border
     ;; make sure that there is at least a clearing around
     ;; the start and target patches--prevents needlessly creating
     ;; a large number of unpassable configurations
     clear-around setup-start
     clear-around setup-target
   ]

   ;;
   ;; A single path maze
   ;;

   if senario = "maze"
   [ senario-maze maze-new setup-start obstacle-color bread-crumb-color space-color border-color straightness 1
   ]

   ;;
   ;; A maze with loops
   ;;

   if senario = "looped maze"
   [ senario-maze-looped density maze-new setup-start obstacle-color bread-crumb-color space-color border-color straightness 1
   ]

   ;;
   ;; A random collection of circular regions that may overlap
   ;;

   if senario = "blobs"
   [ fill-patches space-color
     do-terrain
     ask patch (min-pxcor + world-width * .5) (min-pycor + world-height * .55)
     [ ask n-of (density * .8) (patches in-radius (world-width * .5))
       [ ask patches in-radius-nowrap ((world-width * .05) + random (world-width * .05))
         [ set pcolor obstacle-color ]
       ]
     ]
     ;ifelse terrain?
     ;[ border-3 ]
     ;[ border-2 ]
     border
     clear-around setup-start
     clear-around setup-target
   ]

   ;;
   ;; A pair of bars, crossing the center
   ;;

   if senario = "bars"
   [ fill-patches space-color
     do-terrain
     ;; draw horizontal and vertical bars, to within 5 units of edges
     ask patches with [ pxcor = 0 or pycor = 0 and abs pxcor + 5 < max-pxcor and abs pycor + 5 < max-pycor ]
     [ set pcolor obstacle-color ]


     ask patches with [ (    pxcor = int ( min-pxcor + world-width * .25 )
                          or pxcor = int ( max-pxcor - world-width * .25 )
                        )
                         and
                       ( pycor > max-pycor - (world-height * .33)
                         or pycor < min-pycor + (world-height * .33)
                       )
                      ]
     [ set pcolor obstacle-color ]
     border
   ]


   ;;
   ;; Create the search bot with the start and target previously selected
   ;;


   create-bot setup-start setup-target extract-heuristic

   set-default-shape indicators "indicator"
   ask setup-start
   [ sprout-indicators 1
     [ set color orange
       set size 4
       set heading 180
     ]
   ]
   ask setup-target
   [ sprout-indicators 1
     [ set color orange
       set size 4
       set heading 0
     ]
   ]

   reset-ticks
end

to go
   ask bots
   [ go-bot
     ifelse is-turtle? path-end
     [ show-path-nodes get-path yellow
     ]
     [ ;if show-path-in-progress?
       ;[ ask a*nodes with [ owner = myself and color != magenta ]
       ;  [ set color magenta ]
       ;  show-path-nodes get-path white
       ; ]
     ]
   ]
   if show-path-in-progress? [ tick ]
   if not any? bots with [ done? = false ]
   [ ask bots
     [ ifelse is-turtle? path-end
       [ ask center-patch [ set plabel  "Path Solved." ] ]
       [ ask center-patch [ set plabel  "No Path." ] ]
     ]
     tick
     stop
   ]
end

to go-bot
   ;;
   ;; when path-end is not nobody, that means the target has been reached.
   ;; and path-end contains the a*node that lies on the target.
   ;; path-end can then be used to trace the path back to the start
   ;;
   ;; when done? is true, that means that no more locations
   ;; need to be searched.
   ;;
   ;; if path-end is nobody when done? is true, that means there is
   ;; NO path from the start to the target.
   ;;
   if path-end = nobody
     [ ;;
     ;; collect the nodes that are this bots nodes
       ;; (if netlogo had mutable lists, or mutable agentsets, this could be made faster!)
       ;;
       let my-nodes  a*nodes with [ owner = myself ]
       ;;
       ;; are any of the nodes open?
       ;;
       ifelse any? my-nodes with [ closed? = 0 ]
       [ ;;
         ;; yes. do the path search
         ;;
         set current a*build-path
         ;;
         ;; having done that, was the target found?
         ;;
         if [location] of current = target
         [ set path-end current
           set done? true
         ]
       ]
       [ ;;
         ;; no more open nodes means no where left to search, so we are done.
         ;;
         set done? true
       ]
     ]
end


to fill-patches [ #color ]
   ask patches [ set pcolor #color ]
end

to maze-border
   ask patches with [ pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor ]
   [ set pcolor [ maze-border-color ] of myself ]
end

to maze-field
   ask patches with [ pxcor > min-pxcor and pxcor < max-pxcor and pycor > min-pycor and pycor < max-pycor ]
   [ set pcolor [ maze-wall-color ] of myself ]
end

to border
   ;;
   ;; colors the edge of the world to prevent searches and maze-making from leaking
   ;;
   ask patches with [ pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor ]
   [ set pcolor border-color ]
end

to border-2
   ;;
   ;; creates open space along the border
   ;;
   ask patches with [     ( pxcor = ( min-pxcor + 1 ) or pxcor = ( max-pxcor - 1 ) )
                      or ( pycor = ( min-pycor + 1 ) or pycor = ( max-pycor - 1 ) )]
   [ set pcolor space-color
   ]
end

to border-3
   ;;
   ;; creates a border of randomly "elevated" terrain just inside the border
   ;;
   ask patches with [     ( pxcor = ( min-pxcor + 1 ) or pxcor = ( max-pxcor - 1 ) )
                      or ( pycor = ( min-pycor + 1 ) or pycor = ( max-pycor - 1 ) )]
   [ set pcolor 5 + random-float 5
   ]
end

to do-terrain
 ;;
 ;; puts elevation data in the world
 ;; black = minimum elevation
 ;; white = max-mum elevation
 ;;
 ;; when terrain? is on, path seeks best balance of shortness of path and lowness of elevation
 ;;
 if terrain?
         [ ask patches [ set pcolor 140 - ((distancexy-nowrap 0 0 ) / (.75 * world-width) * 140) ]
           repeat 3 [ diffuse pcolor .5 ]
           ask patches [ set pcolor scale-color gray pcolor 0 140 ]

         ]
end


to clear-around [ agent ]
   ;;;
   ;;; clears obstacles from under and around the given agent
   ;;;
   ask agent [ ask neighbors [ set pcolor space-color ] set pcolor space-color ]
end

to senario-maze [ #maze ]
     ;; takes a maze object, generates a maze using that object
     maze #maze
end

to senario-maze-looped [ #density #maze ]
     ;; capture color info from maze
     let #wall [maze-wall-color] of #maze
     let #path [maze-path-color] of #maze

     ;; make a standard maze using the maze object
     senario-maze #maze

     ;; punch holes in the maze walls at random to create loops
     ;; depends on the maze starting on an even patch,
     ;; so can assume that any patch with both coords odd
     ;; is definitely a wall (obstacle) patch
     ask n-of (2 * #density) (patches with [ pcolor = #wall and pxcor mod 2 != pycor mod 2 ])
     [ set pcolor #path ]
end


to-report maze-new [ #start #wall #crumb #path #border #curve #timeout ]
   let me nobody
   ask #start [ sprout-maza 1
   [ set me self
     set maze-wall-color #wall
     set maze-breadcrumb-color #crumb
     set maze-path-color #path
     set maze-border-color #border
     set maze-curviness #curve
     set maze-timeout #timeout
   ] ]
   report me
end

to maze [ #maze ]
   ;; given a maze turtle, create a single path maze in the field,
   ;;
   ask #maze
   [
     maze-border
     maze-field
     let #timeout timer + maze-timeout
     set pcolor maze-breadcrumb-color
     ;; timeout prevents possibility that an infinite loop may occur
     ;; (which may not even be possible with this algorithm...
     ;; each call to maze-drawing carves out or backtracks the maze path
     ;; this is a reporter with special effects, returns TRUE when there
     ;; is no more maze to be carved.
     while [ maze-drawing and timer < #timeout ]
     [  ]
     ;; mazum die when they are through carving a maze
     die
   ]
end

to-report maze-drawing
   ;; a maze can make a maze drawing
   ;; draw a maze by first drawing a path with a marker color, then backtracking with the space color
   ;; allows drawing of mazes iterively, rather than recursively, and without using a stack!
   ;; essentially uses the patches themselves to remember the path and the path-so-far
   ;;
   ;; assume no path from here
   let path nobody
   ;; candidates for the next step are previously unexplored paths (ie, still colored as obstacles
   let candidates (patches at-points [ [ -2 0][0 -2 ] [ 2 0 ][ 0 2] ]) with [ pcolor = [maze-wall-color] of myself ]
   if-else any? candidates
   [ ;;if there are any unexplored paths, select one of them

     ;; which path is the straight-ahead path?
     let straight-patch patch-ahead 2 ; -at (dx * 2) (dy * 2)

     ;; either co straight (if curve test fails or straight is only choice)
     ;; or turn left or right (if possible)
     ifelse member? straight-patch  candidates and (count candidates = 1 or random 100 < maze-curviness )
     [ set path straight-patch]
     [ set path one-of candidates with [ self != straight-patch ] ]
     ;; point to it
     face-nowrap path
     ;; jump to it, in two steps, two draw a path from here to that patch
     ;; (note that jump is first, then color, leaving starting patch color that it was!
     repeat 2 [ jump 1 set pcolor maze-breadcrumb-color ]

     ;; report that the maze-drawing still has some exploring to do!
     report true
   ]
   [ ;; if we are here, then there are no unexplored paths in the vicinity.
     ;; so, candidates are previously carved (open) paths, that we have likely backed up to
     ;; or have just finished tracing (i.e. colored with the bread-crumb color

     set candidates (patches at-points [ [ -1 0][0 -1 ] [ 1 0 ][ 0 1] ])
                        with [ pcolor = [maze-breadcrumb-color] of myself ]

     ifelse any? candidates
     [ ;; there is a breadcrumb to retrace. trace it.
       set path one-of candidates
       face-nowrap path
       repeat 2 [ set pcolor maze-path-color jump 1 ]

       report true
     ]
     [ ;; we are finally back at the beginning
       ;; carve out the starting point, and we are done
       set pcolor maze-path-color
       report false
     ]
   ]
   ;; avoid coordinate creep
   ;; center maza in the patch
   ;; setxy pxcor pycor
end

to-report same-patch [ a b ]
   ;;
   ;; reports true if both agent a and b, whether turtles or patches, are on the same patch
   ;;
   report ([pxcor] of a = [pxcor] of b and [pycor] of a = [pycor] of b )
end

to highlight-path [ path-color ]
   ;;
   ;; recursive routine that colors the nodes, tracing back up through the node parents
   ;; until the start node is reached
   ;;
   set on-path? true
   set color path-color
   if color = yellow [ ifelse heading mod 90 = 0 [set shape "path" ] [ set shape "path-long" ] ]
   if is-turtle? parent
   [ set heading towards-nowrap parent
     ask parent
     [ highlight-path path-color
     ]
   ]
end

to-report get-path
   let n path-end
   if not is-turtle? n
   [ set n current ]
   if not is-turtle? n
   [ report false ]

   let p (list n )
   while [ [location] of n != start ]
   [ set n [parent] of n
     set p fput n p
   ]
   report p
end

to show-path-nodes [ p hue ]
   ask (turtle-set p)
   [ set color hue
     if color = yellow [ ifelse heading mod 90 = 0 [set shape "path" ] [ set shape "path-long" ] ]
   ]
   ; ask a*nodes with [ member? self p ] [ set color hue ]
   display
   ;;   foreach p
   ;;   [ set color hue
   ;;     if color = yellow [ ifelse heading mod 90 = 0 [set shape "path" ] [ set shape "path-long" ] ]
   ;;   ]
end


to color-path-patches [ p ]
   ;;
   ;; non-recursive routine that,
   ;; given the path-end, increments the pcolor of the patches covered by the path,
   ;; tracing back to the start
   ;;
   foreach p
   [ if pcolor = 0 [ set pcolor 2 ]
     if pcolor < 9.5 [ set pcolor pcolor + .5 ]
   ]
end


to create-bot [ starting-patch target-patch #heuristic ]
   ;;
   ;; creates a search bot
   ;; and the first a*node for that bot.
   ;; so: a bot always has at least one a*node, and that first node is
   ;; the child of the bot
   ;; the first node, however, does not have any "parent"...
   ;; that is, its parent is always "nobody"
   ;; this is how a trace-back routine can know that it has reached
   ;; the begining of a path: when there is no more parents to trace-back to...
   ;;
   create-bots 1
   [ set color gray
     set start starting-patch
     set target target-patch
     set owner self
     set path-end nobody
     set g-score 0
     setxy [pxcor] of start [pycor] of start
     set shape "bot"
     set done? false
     set current nobody
     set o-current self
     set child nobody
     set heuristic #heuristic
     expand-into self start
     ask child [ set closed? 0 set shape "node" set parent nobody set on-path? true ]
   ]
end

to expand-into [ parent-agent location-agent ]
   ;;
   ;; causes the given parent agent to
   ;; expand into the given location (patch)
   ;;
   ;; this means that nodes are created in the given patch, and the parent
   ;; of these nodes is the given parent agent.
   ;;
   ask parent-agent
   [ hatch-a*nodes 1
     [ set location location-agent
       setxy [pxcor] of location [pycor] of location
       ;; first thing--is this a dead end? if so, don't
       ;; bother to add it to any list... just die.
       let my-owner owner
       ifelse location = [ target ] of owner or any? neighbors with [ shade-of? pcolor space-color and not any? a*nodes-here with [ owner = my-owner ] ]
       [ set breed a*nodes
         set shape "node"
         set size 1.01
         set color green
         set parent parent-agent
         set owner [owner] of parent-agent
         ask parent-agent [set child myself]
         set child nobody



         face parent

         ;; target is inherited
         set g-score calculate-g parent-agent
         set h-score calculate-h
         set f-score calculate-f
         set closed? -1 ;; new... neither open or closed
         set on-path? false
       ]
       [ die ]
     ]
   ]
end

to-report calculate-f
  ;;
  ;; calculates the f score for this s*node
  ;;

  ifelse location = [ target ] of owner
  [ report -999999 ]
  [ report g-score + h-score  ]
end

to-report calculate-g [ candidate ]
  ;;
  ;; calculates the g score relative to the candidate for this s*node
  ;;

   let g [g-score] of candidate + distance-nowrap candidate
   if terrain? [ set g g + pcolor * 10]
   report g
end

to-report calculate-h
   let result 0
   if [ heuristic ] of owner = 0  ;; euclidian distance to target
   [ set result distance-nowrap [ target ] of owner ]

   if [ heuristic ] of owner = 1 ;; manhattan distance
   [ let xdiff abs(pxcor - [pxcor] of [ target ] of owner)
     let ydiff abs(pycor - [pycor] of [ target ] of owner)
     set result ( xdiff + ydiff )
   ]

  if [ heuristic ] of owner = 2 ;; diagonal distance
   [

     let D  1
     let D2 1.414214
     let xdiff abs(pxcor - [pxcor] of [ target ] of owner)
     let ydiff abs(pycor - [pycor] of [ target ] of owner)
     let h_diagonal min (list xdiff ydiff)
     let h_straight xdiff + ydiff
     set result D2 * h_diagonal + D * ( h_straight - 2 * h_diagonal )
   ]

   if [ heuristic ] of owner = 3 ;; diagonal distance + tie-breaker
   [

     let D  1
     let D2 1.414214
     let xdiff abs(pxcor - [ [pxcor] of target ] of owner)
     let ydiff abs(pycor - [ [pycor] of target ] of owner)
     let h_diagonal min (list xdiff ydiff)
     let h_straight xdiff + ydiff
     set result D2 * h_diagonal + D * ( h_straight - 2 * h_diagonal )
     ;; tie-breaker: nudge H up by a small amount
     let h-scale (1 + (16 / directions / world-width * world-height))
     set result result * h-scale
   ]
   if [ heuristic ] of owner = 4  ;; euclidian distance to target with tie-breaker
   [ set result distance-nowrap [ target ] of owner
     let h-scale (1 + (16 / directions / world-width + world-height))
     set result result * h-scale
   ]
   report result
end

to-report a*build-path
   let o-c o-current
   set current min-one-of a*nodes with [ owner = myself and closed? = 0 ] [ f-score ] ; + distance-nowrap o-c ]
   set o-current current
   let cc current
   if is-turtle? cc
   [ ask cc
     [ set closed? 1
       set color magenta

       if not same-patch location [ target ] of owner
       [ let me owner
         let paths nobody
         ifelse directions = 8
         [ set paths neighbors with [ shade-of? pcolor space-color ] ]
         [ set paths neighbors4 with [ shade-of? pcolor space-color ] ]

         let new-paths (paths with [ not any? a*nodes-here with [ owner = me ] ] )
         if any? new-paths [ ask  new-paths [ expand-into cc self ] ]

         set new-paths  (a*nodes-on paths ) with [ owner = me and closed? < 1 ]
         ; if any? new-paths [ set new-paths min-one-of new-paths [ f-score ] ]
         ask  new-paths
         [ ifelse closed? = 0 ;; already open
           [ ;; see if g from current is better than prior g
             let new-g calculate-g cc
             set f-score calculate-f
             if new-g < g-score
             [ ;; if it is, then change path to go from this point
               ;; set parent of this node to current
               set parent cc
               set shape "node"
               face parent
               ask parent [ set child myself ]
               set g-score new-g
               set f-score calculate-f
             ]
           ]
           [ ;; must be new (not yet open, not previously closed.
             set closed? 0 ;; open it
               set parent cc
           ]
         ]
       ]
     ]
   ]
   report current
end

to-report extract-heuristic
   report first choose-heuristic
end

to reset-bots
   ask a*nodes [ die ]
   ask bots [ die ]
   let setup-start patch (min-pxcor + 2) ( min-pycor + 2 )
   let setup-target patch (max-pxcor - 2) ( max-pycor - 2 )
   create-bot setup-start setup-target extract-heuristic
end

to-report center-patch
   report patch (int (min-pxcor + world-width * .5)) (int (min-pycor + world-height * .5))
end
   ;;  1) Add the starting square (or node) to the open list.
   ;;  2) Repeat the following:
   ;;     a) Look for the lowest F cost square on the open list. We refer to this as the current square.
   ;;     b) Switch it to the closed list.
   ;;     c) For each of the 8 squares adjacent to this current square �
   ;;
   ;;        * If it is not walkable or if it is on the closed list, ignore it.
   ;;          Otherwise do the following.
   ;;      * If it is on the open list already...
   ;;          Check to see if this path to that square is better,
   ;;          using G cost as the measure.
   ;;          A lower G cost means that this is a better path.
   ;;          If so, change the parent of the square to the current square,
   ;;          and recalculate the G and F scores of the square.
   ;;          If you are keeping your open list sorted by F score,
   ;;          you may need to resort the list to account for the change.
   ;;        * If it isn�t on the open list...
   ;;            Add it to the open list.
   ;;            Make the current square the parent of this square.
   ;;            Record the F, G, and H costs of the square.
  ;;
   ;;  d) Stop when you:
   ;;
   ;;      * Add the target square to the closed list, in which case the path has been found (see note below), or
   ;;      * Fail to find the target square, and the open list is empty. In this case, there is no path.
   ;;
   ;;  3) Save the path. Working backwards from the target square, go from each square to its parent square until you reach the starting square. That is your path.

@#$#@#$#@
GRAPHICS-WINDOW
255
10
689
445
-1
-1
6.0
1
20
1
1
1
0
1
1
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
10
235
65
268
NIL
setup
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
70
255
125
288
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
255
475
340
520
NIL
count a*nodes
3
1
11

SLIDER
120
30
215
63
density
density
0
100
21.0
1
1
NIL
HORIZONTAL

BUTTON
70
295
125
328
go 1x
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
10
30
102
75
senario
senario
"blank" "bars" "blobs" "maze" "looped maze" "random"
4

BUTTON
130
235
195
268
reset-bots
reset-bots ask patch 0 0 [ set plabel \"\" ]
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
10
190
105
223
directions
directions
4
8
4.0
4
1
NIL
HORIZONTAL

SWITCH
10
340
197
373
show-path-in-progress?
show-path-in-progress?
0
1
-1000

SWITCH
10
80
113
113
terrain?
terrain?
0
1
-1000

MONITOR
345
475
430
520
nodes in path
count a*nodes with [ color = yellow ]
3
1
11

MONITOR
435
475
520
520
path-length
ifelse-value (any? bots) [[ [g-score] of current ] of one-of bots] [\"\"]
3
1
11

CHOOSER
10
140
205
185
choose-heuristic
choose-heuristic
[0 "euclician distance"] [1 "manhattan distance"] [2 "diagonal distance"] [3 "diag-dist + tie-breaker"] [4 "euclid-dist + tie-breaker"]
4

TEXTBOX
20
395
195
480
After selecting senario and bot parameters, click SETUP, then GO. To see how different heuristics and number of directions affect solution, select new heuristic or directions, click RESET, then glick GO.
11
0.0
1

TEXTBOX
10
125
160
143
Search bot parameters
11
0.0
1

TEXTBOX
10
10
160
28
Senario parameters
11
0.0
1

SLIDER
120
70
215
103
straightness
straightness
0
100
8.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## == NOTES ==

=== "Shortest" Paths ===

This model does find the shortest paths, as far as the g-score is concerned. Since the bot can only move one patch per step, in either 4 or eight directions, its "shortest" paths are not the same as would be obtained if steps in any direction were allowed, or if the graph was not made of every patch, connected to its adjactent pathes.

For example, if we could process the map so that only "important" patches were included in the graph (in the set of connected patches searched), then both search efficiency and path-length would improve. In this situation, since shortest paths tend to skirt around obstacles, "important" patches are patches that border an obstacle. Further, they are the patches at the "corners" of obstacles. That is, space patches with exactly one obstacle patch among their neighbors.

Now, once the patches are identified, how are they connected?

Clearly, every patch is connected to every other patch, so long as no obstacle lies on the line connecting the two patches.

The line is clear if it does not pass through any obstacle patch. Note that this is not the same as not passing through the *center* of the obstacle patch!

Last, the score of the connection is the distance bewteen the patches.

## == CREDIT AND ACKNOWLEDGEMENTS ==

Thanks to Amit J. Patel at http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html for great expanations and insight into the A* algorithm, and the role of the heuristic cost function.

<modelinfo>
<summary>;; A framework for using the famous path-finding algorithm</summary>
<copy>Copyright � 2009 James P. Steiner</copy>
</modelinfo>
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bot
true
6
Circle -13840069 true true 30 30 240

indicator
true
2
Polygon -955883 false true 150 75 210 15 285 90 225 150 285 210 210 285 150 225 90 285 15 210 75 150 15 90 90 15
Polygon -955883 false true 105 150 60 105 105 60 150 105 195 60 240 105 195 150 240 195 195 240 150 195 105 240 60 195
Polygon -955883 false true 135 150 105 120 120 105 150 135 180 105 195 120 165 150 195 180 180 195 150 165 120 195 105 180

node
true
6
Circle -13840069 true true 75 75 150
Polygon -13840069 true true 75 150 150 -150 225 150

path
true
6
Rectangle -13840069 true true 75 -75 225 225
Polygon -16777216 true false 75 195 105 195 150 135 195 195 225 195 150 90
Polygon -16777216 true false 75 60 105 60 150 0 195 60 225 60 150 -45

path-long
true
6
Rectangle -16777216 true false 75 -195 225 225
Polygon -13840069 true true 75 0 75 -195 225 -195 225 -60 150 -165 75 -60 105 -60 150 -120 195 -60 225 -60 225 60 150 -45 75 60 105 60 150 0 195 60 225 60 225 195 150 90 75 195 105 195 150 135 195 195 225 195 225 225 75 225
@#$#@#$#@
NetLogo 6.0.4
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
