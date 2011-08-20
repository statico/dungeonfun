perlin = require './third-party/perlin.js'
graph = require './graph.coffee'
heap = require './heap.coffee'

randInt = (x) -> Math.floor(Math.random() * x)

class World

  TILE_SIZE: 50
  CELL_EMPTY: 0
  CELL_WALL: 1
  CELL_ROOM: 2
  CELL_DOOR: 3
  CELL_HALLWAY: 6

  constructor: ->
    @map = new graph.Graph()

  getTile: (tx, ty) ->
    l = tx * @TILE_SIZE
    t = ty * @TILE_SIZE
    return @map.getRect(l, t, @TILE_SIZE, @TILE_SIZE)

  makeTile: (tx, ty) ->
    l = tx * @TILE_SIZE
    r = (tx + 1) * @TILE_SIZE
    t = ty * @TILE_SIZE
    b = (ty + 1) * @TILE_SIZE

    rooms = @makeRooms(t, r, b, l)
    @makeHallways(t, r, b, l, rooms)

  loadTile: (tx, ty, content) ->
    # This could probably be sped up.
    l = tx * @TILE_SIZE
    r = (tx + 1) * @TILE_SIZE
    t = ty * @TILE_SIZE
    b = (ty + 1) * @TILE_SIZE
    for y in [t..b]
      row = content[y - t]
      for x in [l..r]
        @map.set x, y, row?[x - l]

  makeRooms: (T, R, B, L) ->
    rooms = []

    roomCollision = (tuple1, tuple2, pad = 1) ->
      [t1, r1, b1, l1] = tuple1
      [t2, r2, b2, l2] = tuple2
      return false if b1 < t2 - pad
      return false if t1 > b2 + pad
      return false if r1 < l2 - pad
      return false if l1 > r2 + pad
      return true

    # Pick a reasonable number of rooms for the tile.
    for i in [1..Math.floor(@TILE_SIZE * @TILE_SIZE / 300)]

      while true
        l = L + randInt (R - L)
        t = T + randInt (B - T)
        r = l + 6 + randInt 12
        b = t + 3 + randInt 10
        continue if l <= L or t <= T # XXX ?
        continue if r >= R - 1
        continue if b >= B - 1

        current = [t, r, b, l]
        ok = true
        for other in rooms
          if roomCollision current, other
            ok = false
            break
        if ok
          rooms.push current
          break

    for i in [0..rooms.length - 1]
      room = rooms[i]
      [t, r, b, l] = room

      # Draw the room.
      for y in [t..b]
        for x in [l..r]
          @map.set x, y, @CELL_ROOM

      # Draw the perimeter.
      for x in [l..r]
        @map.set x, t, @CELL_WALL
        @map.set x, b, @CELL_WALL
      for y in [t+1..b-1]
        @map.set l, y, @CELL_WALL
        @map.set r, y, @CELL_WALL

      # Add at least one door.
      count = 1 + randInt (r-l) * 2 / 10
      for [1..count]
        rx = l + 1 + randInt(r - l - 1)
        ry = t + 1 + randInt(b - t - 1)
        switch randInt 4
          when 0 # top
            x = rx
            y = t
          when 1 # right
            x = r
            y = ry
          when 2 # bottom
            x = rx
            y = b
          when 3 # left
            x = l
            y = ry
        @map.set x, y, @CELL_DOOR

    return rooms

  makeHallways: (T, R, B, L, rooms) ->
    # Adding a little Perlin Simplex noise makes the hallways a little more
    # natural and windy.
    noise = new perlin.SimplexNoise random: -> 0.123 # Seed the noise.

    heuristic = (p1, p2) =>
      if p2.value == @CELL_HALLWAY
        return 0 # Bonus to reuse hallways.
      else
        d1 = Math.abs(p2.x - p1.x)
        d2 = Math.abs(p2.y - p1.y)
        n = Math.floor noise.noise(p1.x / 15, p1.y / 15) * 20
        return d1 + d2 + n

    filter = (node) =>
      #@map.set node.x, node.y, 5 if !node.value
      x = node.value
      return (!x or x == @CELL_EMPTY or x == @CELL_DOOR or x == @CELL_HALLWAY)

    findDoors = (room) =>
      [t, r, b, l] = room
      doors = []
      for x in [l..r]
        if @map.get(x, t) == @CELL_DOOR # top wall
          doors.push [x, t]
        if @map.get(x, b) == @CELL_DOOR # bottom wall
          doors.push [x, b]
      for y in [t..b]
        if @map.get(l, y) == @CELL_DOOR # left wall
          doors.push [l, y]
        if @map.get(r, y) == @CELL_DOOR # right wall
          doors.push [r, y]
      return doors

    # Connect each room with one other.
    hallwayPoints = []
    for i in [0..rooms.length - 1]

      # Pick another room at random.
      j = i
      while j == i
        j = randInt rooms.length
      room = rooms[i]
      other = rooms[j]

      a = findDoors(room)
      b = findDoors(other)
      continue if not a.length or not b.length
      [x1, y1] = a[0]
      [x2, y2] = b[0]

      path = @map.astar x1, y1, x2, y2, filter, heuristic
      for p in path
        @map.setPoint p, @CELL_HALLWAY
        hallwayPoints.push p

    # Pick some random parts of a hallway and make branches to nowhere.
    for i in [1..Math.floor(@TILE_SIZE * @TILE_SIZE / 600)]
      [x1, y1] = hallwayPoints[randInt hallwayPoints.length]

      x2 = undefined
      r = Math.floor(@TILE_SIZE * .2)
      while !x2
        x = x1 - r + randInt(r * 2)
        y = y1 - r + randInt(r * 2)
        if !@map.get(x, y)
          x2 = x
          y2 = y

      path = @map.astar x1, y1, x2, y2, filter, heuristic
      for p in path
        @map.setPoint p, @CELL_HALLWAY
      #@map.set x1, y1, 8
      #@map.set x2, y2, 9

  connectTiles: (tx1, ty1, tx2, ty2) ->
    # Basic algorithm: Find the edge (1=top, 2=right, 3=bottom, 4=left) on
    # which the tiles connect. Then search backward from the seam on both tiles
    # finding the first row/column containing a door or hallway. Then find the
    # two points on each row/column that are closest and find a path between
    # them.
    S = @TILE_SIZE
    PADDING = 10

    # Tiles must be adjacent (at the moment).
    if (tx2 - tx1) + (ty2 - ty1) != 1
      console.warn 'Tried to connect to non-adjacent tiles'
      return

    # Determine the edge direction relative to the first tile.
    dir = 1 if ty1 > ty2
    dir = 2 if tx1 < tx2
    dir = 3 if ty1 < ty2
    dir = 4 if tx1 > tx2

    # Find the row/column with one or more hallways or doors on each tile.
    #
    # This row/column needs to be at least N cells away (Manhattan distance),
    # otherwise there's a large chance that one tile has hallways that bleed on
    # another and we're not actually joining the tiles. There's still a small
    # chance, however, that the tiles won't be connected.
    if dir == 2
      # T1 column, right to left
      for x in [(tx1 * S + S - 1 - PADDING)..(tx1 * S)]
        points = []
        for y in [(ty1 * S)..(ty1 * S + S)]
          value = @map.get x, y
          if value == @CELL_HALLWAY or value == @CELL_DOOR
            #@map.set x, y, 5
            points.push [x, y]
        break if points.length
      t1p = points

      # T2 column, left to right
      for x in [(tx2 * S + PADDING)..(tx2 * S + S)]
        points = []
        for y in [(ty1 * S)..(ty1 * S + S)]
          value = @map.get x, y
          if value == @CELL_HALLWAY or value == @CELL_DOOR
            #@map.set x, y, 5
            points.push [x, y]
        break if points.length
      t2p = points

      # Pick a random point on T1 and the closest point to it on T2.
      p1 = t1p[randInt t1p.length]
      choices = new heap.BinaryHeap (obj) -> (obj.distance)
      for p2 in t2p
        choices.push
          x: p2[0]
          y: p2[1]
          distance: (p2[0] - p1[0]) + (p2[1] - p1[1])
      obj = choices.pop()
      p2 = [obj.x, obj.y]

      if not p1?.length or not p2?.length
        console.warn 'Could not join tiles', tx1, ty1, tx2, ty2
        return

      # Join them.
      filter = (node) =>
        x = node.value
        return (!x or x == @CELL_EMPTY or x == @CELL_DOOR or x == @CELL_HALLWAY)
      path = @map.astar p1[0], p1[1], p2[0], p2[1], filter
      for p in path
        @map.setPoint p, @CELL_HALLWAY
      #@map.setPoint p1, 7
      #@map.setPoint p2, 7



exports or= this
exports.World = World
