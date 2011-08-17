world = require('./world.coffee')

w = new world.World()
w.makeTile 0, 0

for row in w.getTile 0, 0
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  console.log line
