world = require('./world.coffee')

w = new world.World()
w.makeTile 0, 0
w.makeTile 1, 0

t1 = w.getTile 0, 0
t2 = w.getTile 1, 0

format = (row) ->
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  return line

for y in [0..t1.length-1]
  process.stdout.write(format(t1[y]))
  process.stdout.write(format(t2[y]))
  process.stdout.write('\n')
