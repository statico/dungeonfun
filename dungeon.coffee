width = 60
height = 30

# Generate blank map
map = []
for y in [1..height]
  row = []
  for x in [1..width]
    row.push 0
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

for i in [1..Math.round(width * height / 350)]
  while true
    l = Math.round(Math.random() * width)
    t = Math.round(Math.random() * height)
    r = l + Math.round(Math.random() * 15) + 3
    b = t + Math.round(Math.random() * 15) + 3
    continue if r >= width
    continue if b >= height

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
  for y in [t..b]
    for x in [l..r]
      map[y][x] = i + 1


# XXX
for row in map
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  console.log line
