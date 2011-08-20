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

g.setPoint([0, 0], 55)
g.setPoint([1, 1], 66)
assert.equal g.getPoint([0, 0]), 55
assert.equal g.getPoint([1, 1]), 66

# Neighbor helper.
g = new graph.Graph()
g.set 0, 0, 1
g.set 1, 0, 2
g.set 2, 0, 3
g.set 0, 1, 4
g.set 1, 1, 5
g.set 2, 1, 6
g.set 0, 2, 7
g.set 1, 2, 8
g.set 2, 2, 9
diagonals = g.neighbors(1, 1, true)
assert.deepEqual diagonals, [1,2,3, 4,  6, 7,8,9]
cardinals = g.neighbors(1, 1, false)
assert.deepEqual cardinals, [  2,   4,  6, 8    ]

# Neighbor points with diagonals.
neighbors = (p.join(',') for p in g.neighborPoints(0, 0))
points = ['-1,-1', '0,-1', '1,-1',
          '-1,0',          '1,0',
          '-1,1',  '0,1',  '1,1']
for point in points
  assert.ok point in neighbors, "#{point} in neighbors"

# Neighbor points without diagonals.
neighbors = (p.join(',') for p in g.neighborPoints(0, 0, false))
points = [         '0,-1',
          '-1,0',          '1,0',
                   '0,1']
for point in points
  assert.ok point in neighbors, "#{point} in neighbors"

# Let's try an A* pathfind from 'S' to 'E':
# +-----+    +-----+
# |.X..E|    |.X**E|
# |.X.XX| -> |.X*XX|
# |S....|    |S**..|
# +-----+    +-----+
m = [[1, 0, 1, 1, 1],
     [1, 0, 1, 0, 0],
     [1, 1, 1, 1, 1]]
g = new graph.Graph(m)
path = g.astar(0,2, 4,0)
assert.deepEqual path, [[1,2],[2,2],[2,1],[2,0],[3,0]]

# Same thing, but with diagonals.
# +-----+
# |.X.*E|
# |.X*XX|
# |S*...|
# +-----+
path = g.astar(0,2, 4,0, null, null, true)
assert.deepEqual path, [[1,2],[2,1],[3,0]]

# Can only traverse values > 2
# +-----+    +-----+
# |1143E|    |11**E|
# |92929| -> |92*29|
# |S3392|    |S**92|
# +-----+    +-----+
m = [[1, 1, 4, 3, 3],
     [9, 2, 9, 2, 9],
     [3, 3, 3, 9, 2]]
g = new graph.Graph(m)

path = g.astar(4,2, 4,0, null, null, false)
assert.deepEqual path, [[4,1]]

filter = (node) -> node.value > 2
path = g.astar(0,2, 4,0, filter, null, false)
assert.deepEqual path, [[1,2],[2,2],[2,1],[2,0],[3,0]]

# Heuristic which looks for path of least resistance.
# +-----+    +-----+
# |2111E|    |1***E|
# |21248| -> |1*248|
# |2111S|    |1***S|
# +-----+    +-----+
m = [[2, 1, 1, 1, 1],
     [2, 1, 9, 9, 9],
     [1, 1, 1, 1, 1]]
g = new graph.Graph(m)

path = g.astar(4,2, 4,0, null, null, false)
assert.deepEqual path, [[4,1]]

heuristic = (n1, n2) -> n1.value
path = g.astar(4,2, 4,0, null, heuristic, false)
assert.deepEqual path, [[3,2],[2,2],[1,2],[1,1],[1,0],[2,0],[3,0]]

# Now an impossible path
# +-----+
# |S.0.E|
# +-----+
m = [[1, 1, 0, 1, 1]]
g = new graph.Graph(m)
path = g.astar(0,0, 4,0)
assert.deepEqual path, []

# A really long path
m = [[1..100000]]
g = new graph.Graph(m)
path = g.astar(0,0, 99999,0)
assert.equal path.length, 99998

console.log 'all tests ok'

