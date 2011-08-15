###!
Infinite 2D graph data structure.

Uses the astar pathfinding algorithm from http:#github.com/bgrins/javascript-astar
###

heap = require('./heap.coffee')

class Graph

  constructor: ->
    @map = {}

  get: (x, y) ->
    return @map[x]?[y] or 0

  set: (x, y, value) ->
    a = @map[x]
    if not a?
      a = @map[x] = {}
    a[y] = value

  getRect: (x, y, w, h) ->
    result = []
    for k in [y..y+h-1]
      row = []
      for j in [x..x+w-1]
        row.push @get(j, k)
      result.push row
    return result

  neighbors: (x, y) ->
    return [
      [x - 1, y - 1],
      [x,     y - 1],
      [x + 1, y - 1],

      [x - 1, y],
      [x + 1, y],

      [x - 1, y + 1],
      [x,     y + 1],
      [x + 1, y + 1],
    ]

  astar: (x1, y1, x2, y2, allowed = 0, heuristic = null) ->
    start = [x1, y1]
    end = [x2, y2]

    heuristic or= (p1, p2) ->
      d1 = Math.abs(p2[0] - p1[0])
      d2 = Math.abs(p2[1] - p1[1])
      return d1 + d2

    open = new heap.BinaryHeap()
    open.push start

    while open.size() > 0

      # Grab the lowest f(x) to process next.  Heap keeps this sorted for us.
      current = open.pop()
      console.log 'CURRENT', current[0], current[1]

      # End case -- result has been found, return the traced path
      if current[0] == end[0] and current[1] == end[1]
        p = current
        ret = []
        while p.parent
          ret.push(p)
          p = p.parent
        return ret.reverse()

      # Normal case -- move current from open to closed, process each of
      # its neighbors
      current.closed = true

      for p in @neighbors(current[0], current[1])
        neighbor = @get(p[0], p[1])
        if neighbor.closed or not @get(p[0], p[1]) | allowed
          # not a valid node to process, skip to next neighbor
          continue

      # g score is the shortest distance from start to current node, we need to
      # check if the path we have arrived at this neighbor is the shortest one
      # we have seen yet 1 is the distance from a node to it's neighbor.  This
      # could be variable for weighted paths.
      gScore = (current.g or 0) + 1
      beenVisited = neighbor.visited

      if not beenVisited or gScore < (neighbor.g or 0)
        # Found an optimal (so far) path to this node.  Take score for node to
        # see how good it is.
        neighbor.visited = true
        neighbor.parent = current
        neighbor.h = neighbor.h or heuristic(neighbor, end)
        neighbor.g = gScore
        neighbor.f = (neighbor.g or 0) + (neighbor.h or 0)

        if not beenVisited
          # Pushing to heap will put it in proper place based on the 'f' value.
          open.push neighbor
        else
          # Already seen the node, but since it has been rescored we need to
          # reorder it in the heap
          open.rescoreElement neighbor

    # No result was found -- empty array signifies failure to find path
    return []



exports or= this
exports.Graph = Graph
