###!
Infinite 2D graph data structure.

Uses the astar pathfinding algorithm from http://github.com/bgrins/javascript-astar
###

heap = require('./heap.coffee')

class Graph

  constructor: (initial = null) ->
    @map = {}

    if initial
      for y in [0..initial.length - 1]
        row = initial[y]
        for x in [0..row.length - 1]
          @set x, y, initial[y][x]

  get: (x, y) ->
    return @map[x]?[y] or 0

  getPoint: (p) ->
    return @get(p[0], p[1])

  set: (x, y, value) ->
    a = @map[x]
    if not a?
      a = @map[x] = {}
    a[y] = value

  setPoint: (p, value) ->
    @set p[0], p[1], value

  getRect: (x, y, w, h) ->
    result = []
    for k in [y..y+h-1]
      row = []
      for j in [x..x+w-1]
        row.push @get(j, k)
      result.push row
    return result

  neighbors: (x, y, includeDiagonals = true) ->
    if includeDiagonals
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
    else
      return [
        [x,     y - 1],
        [x - 1, y],
        [x + 1, y],
        [x,     y + 1],
      ]

  astar: (x1, y1, x2, y2, filter = null, heuristic = null, includeDiagonals = false) ->
    # x1, y1 - starting point
    # x2, y2 - endoing point
    # filter - a function(x) which given a cell returns whether it can be traversed
    # heuristic - a function used to decide the cost of path, defaults to Manhattan distance
    # includeDiagonals - whether the path can make use of tile corners

    # Going forward, all "points" are 2-tuples of (x, y) coords and "nodes" are
    # objects with at least 'x' and 'y' properties. We work with nodes in this
    # method but return a list of points.
    nodes = {}
    getNode = (x, y) =>
      key = x + ',' + y
      return nodes[key] or nodes[key] = x: x, y: y, value: @get(x, y)

    start = getNode x1, y1
    end = getNode x2, y2

    # Default filter allows all nonzero values in the graph.
    filter or= (node) -> node.value > 0

    # Default heuristic is Manhattan distance.
    heuristic or= (n1, n2) ->
      d1 = Math.abs(n2.x - n1.x)
      d2 = Math.abs(n2.y - n1.y)
      return d1 + d2

    open = new heap.BinaryHeap (node) -> node.f # f = heuristic + distance
    open.push start

    while open.size() > 0

      # Grab the lowest f(x) to process next.  Heap keeps this sorted for us.
      current = open.pop()

      # End case -- result has been found, return the traced path
      if current == end
        n = current
        ret = []
        while n.parent
          ret.push([n.x, n.y]) if n != end # Conditional cures an edge case..
          n = n.parent
        return ret.reverse()

      # Normal case -- move current from open to closed, process each of
      # its neighbors
      current.closed = true

      for p in @neighbors(current.x, current.y, includeDiagonals)
        neighbor = getNode p[0], p[1]

        if neighbor.closed or not filter(neighbor)
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
          neighbor.h or= heuristic(neighbor, end)
          neighbor.g = gScore
          neighbor.f = neighbor.g + neighbor.h

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
