assert = require('assert')
graph = require('./graph.coffee')

g = new graph.Graph()
g.set 0, 0, 11
g.set 1, 0, 22
g.set 0, 1, 33
g.set 1, 1, 44

assert.equal g.get(0, 0), 11
assert.equal g.get(1, 0), 22
assert.equal g.get(0, 1), 33
assert.equal g.get(1, 1), 44
assert.equal g.get(99, 99), 0
assert.equal g.get(-1, -1), 0

assert.deepEqual g.getRect(0, 0, 2, 2), [[11, 22], [33, 44]]
assert.deepEqual g.getRect(-1, -1, 2, 2), [[0, 0], [0, 11]]

neighbors = (p.join(',') for p in g.neighbors(0, 0))
points = ['-1,-1', '0,-1', '1,-1',
          '-1,0',          '1,0',
          '-1,1',  '0,1',  '1,1']
for point in points
  assert.ok point in neighbors, "#{point} in neighbors"

# Let's try an A* pathfind from 'S' to 'E':
# +----+
# |.0.E|
# |.0.0|
# |S...|
# +----+
m = [[1, 0, 1, 1],
     [1, 0, 1, 0],
     [1, 1, 1, 1]]

g = new graph.Graph()
for x in [0..3]
  for y in [0..2]
    g.set x, y, m[y][x]

console.log g.astar(0, 1, 3, 0, allowed = 1)


console.log 'all tests ok'

