perlin = require './third-party/perlin.js'
graph = require './graph.coffee'

width = 90
height = 40

randInt = (x) -> Math.floor(Math.random() * x)

TILE_EMPTY = 0
TILE_WALL = 1
TILE_ROOM = 2
TILE_DOOR = 3
TILE_HALLWAY = 6

map = new graph.Graph()

# Generate rooms
rooms = []
roomCollision = (tuple1, tuple2, pad = 1) ->
  [t1, r1, b1, l1] = tuple1
  [t2, r2, b2, l2] = tuple2
  return false if b1 < t2 - pad
  return false if t1 > b2 + pad
  return false if r1 < l2 - pad
  return false if l1 > r2 + pad
  return true
for i in [1..8]
  while true
    l = randInt width
    t = randInt height
    r = l + 6 + randInt 12
    b = t + 3 + randInt 10
    continue if l <= 0 or t <= 0
    continue if r >= width - 1
    continue if b >= height - 1

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
      map.set x, y, TILE_ROOM

  # Draw the perimeter.
  for x in [l..r]
    map.set x, t, TILE_WALL
    map.set x, b, TILE_WALL
  for y in [t+1..b-1]
    map.set l, y, TILE_WALL
    map.set r, y, TILE_WALL

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
    map.set x, y, TILE_DOOR

# Connect the rooms
noise = new perlin.SimplexNoise random: -> 0.123 # Seed the noise.
heuristic = (p1, p2) ->
  d1 = Math.abs(p2.x - p1.x)
  d2 = Math.abs(p2.y - p1.y)
  n = Math.floor noise.noise(p1.x / 15, p1.y / 15) * 20
  return d1 + d2 + n
filter = (node) ->
  #map.set node.x, node.y, 5 if !node.value
  !node.value or node.value == TILE_EMPTY or node.value == TILE_DOOR

for i in [0..rooms.length - 1]
  j = i
  while j == i
    j = randInt rooms.length
  room = rooms[i]
  other = rooms[j]

  [t, r, b, l] = room
  for y in [t..b]
    for x in [l..r]
      if map.get(x, y) == TILE_DOOR
        x1 = x
        y1 = y

  [t, r, b, l] = other
  for y in [t..b]
    for x in [l..r]
      if map.get(x, y) == TILE_DOOR
        x2 = x
        y2 = y

  path = map.astar x1, y1, x2, y2, filter, heuristic
  for p in path
    map.setPoint p, TILE_HALLWAY

# XXX
for row in map.getRect 0,0, width,height
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  console.log line
