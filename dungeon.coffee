width = 90
height = 40

randInt = (x) -> Math.floor(Math.random() * x)

TILE_EMPTY = 0
TILE_WALL = 1
TILE_ROOM = 2
TILE_DOOR = 3

# Generate blank map
map = []
for y in [1..height]
  row = []
  for x in [1..width]
    row.push TILE_EMPTY
  map.push row

# Generate rooms
rooms = []
isCollision = (tuple1, tuple2, pad = 1) ->
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
      if isCollision current, other
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
      map[y][x] = TILE_ROOM

  # Draw the perimeter.
  for x in [l..r]
    map[t][x] = TILE_WALL
    map[b][x] = TILE_WALL
  for y in [t+1..b-1]
    map[y][l] = TILE_WALL
    map[y][r] = TILE_WALL

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
    map[y][x] = TILE_DOOR

# XXX
for row in map
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  console.log line
