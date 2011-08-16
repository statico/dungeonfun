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

    # Going forward, all "points" are 2-tuples of (x, y) coords.
    start = [x1, y1]
    end = [x2, y2]

    # Default filter allows all nonzero values in the graph.
    filter or= (value) -> value > 0

    # Default heuristic is Manhattan distance.
    heuristic or= (p1, p2) ->
      d1 = Math.abs(p2[0] - p1[0])
      d2 = Math.abs(p2[1] - p1[1])
      return d1 + d2

    open = new heap.BinaryHeap()
    open.push start

    # A stupid/simple "flags" system so that we can add attributes to coords.
    flags = (->
      objects = {}
      return (p) ->
        key = p.join ','
        obj = objects[key]
        if obj == undefined
          obj = objects[key] = {}
        return obj
    )()

    while open.size() > 0

      # Grab the lowest f(x) to process next.  Heap keeps this sorted for us.
      current = open.pop()

      # End case -- result has been found, return the traced path
      if current[0] == end[0] and current[1] == end[1]
        p = current
        ret = []
        while flags(p).parent
          ret.push(p)
          p = flags(p).parent
        return ret.reverse()

      # Normal case -- move current from open to closed, process each of
      # its neighbors
      flags(current).closed = true

      for p in @neighbors(current[0], current[1], includeDiagonals)
        value = @getPoint(p)
        f = flags(p)

        if f.closed or not filter(value)
          # not a valid node to process, skip to next neighbor
          continue

        # g score is the shortest distance from start to current node, we need to
        # check if the path we have arrived at this neighbor is the shortest one
        # we have seen yet 1 is the distance from a node to it's neighbor.  This
        # could be variable for weighted paths.
        gScore = (f.g or 0) + 1
        beenVisited = f.visited

        if not beenVisited or gScore < (f.g or 0)
          # Found an optimal (so far) path to this node.  Take score for node to
          # see how good it is.
          f.visited = true
          f.parent = current
          f.h or= heuristic(p, end)
          f.g = gScore
          f.f = f.g + f.h

          if not beenVisited
            # Pushing to heap will put it in proper place based on the 'f' value.
            open.push p
          else
            # Already seen the node, but since it has been rescored we need to
            # reorder it in the heap
            open.rescoreElement p

    # No result was found -- empty array signifies failure to find path
    return []



exports or= this
exports.Graph = Graph
