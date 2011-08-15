class Graph

  constructor: ->
    @map = {}

  get: (x, y) ->
    return @map[x]?[y]

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

exports or= this
exports.Graph = Graph
