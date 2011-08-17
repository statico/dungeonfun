perlin = require './third-party/perlin.js'
graph = require './graph.coffee'

randInt = (x) -> Math.floor(Math.random() * x)

class World

  TILESIZE: 50
  CELL_EMPTY: 0
  CELL_WALL: 1
  CELL_ROOM: 2
  CELL_DOOR: 3
  CELL_HALLWAY: 6

  constructor: ->
    @map = new graph.Graph()

  getTile: (tX, tY) ->
    l = tX * @TILESIZE
    t = tY * @TILESIZE
    return @map.getRect(l, t, @TILESIZE, @TILESIZE)

  makeTile: (tX, tY) ->
    l = tX * @TILESIZE
    r = (tX + 1) * @TILESIZE
    t = tY * @TILESIZE
    b = (tY + 1) * @TILESIZE

    rooms = @makeRooms(t, r, b, l)
    @makeHallways(t, r, b, l, rooms)

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
    for i in [1..Math.floor(@TILESIZE * @TILESIZE / 300)]

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

    # Connect all the rooms.
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

      # Add at least two doors.
      count = 2 + randInt (r-l) * 2 / 10
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
      d1 = Math.abs(p2.x - p1.x)
      d2 = Math.abs(p2.y - p1.y)
      n = Math.floor noise.noise(p1.x / 15, p1.y / 15) * 20
      return d1 + d2 + n

    filter = (node) =>
      #@map.set node.x, node.y, 5 if !node.value
      !node.value or node.value == @CELL_EMPTY or node.value == @CELL_DOOR

    findDoors = (room) =>
      [t, r, b, l] = room
      doors = []
      for x in [l..r]
        if @map.get(x, t) == @CELL_DOOR # top wall
          doors.push [x, t]
        if @map.get(x, b) == @CELL_DOOR # bottom wall
          doors.push [x, b]
      for y in [t+1..b-1]
        if @map.get(l, y) == @CELL_DOOR # left wall
          doors.push [l, y]
        if @map.get(r, y) == @CELL_DOOR # right wall
          doors.push [r, y]
      return doors

    for i in [0..rooms.length - 1]
      j = i
      while j == i
        j = randInt rooms.length
      room = rooms[i]
      other = rooms[j]

      [x1, y1] = findDoors(room)?[0]
      [x2, y2] = findDoors(other)?[0]

      path = @map.astar x1, y1, x2, y2, filter, heuristic
      for p in path
        @map.setPoint p, @CELL_HALLWAY


exports or= this
exports.World = World
