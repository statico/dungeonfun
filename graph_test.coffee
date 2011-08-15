assert = require('assert')
graph = require('./graph.coffee')

g = new graph.Graph()
g.set 0, 0, 'a'
g.set 1, 0, 'b'
g.set 0, 1, 'c'
g.set 1, 1, 'd'

assert.equal g.get(0, 0), 'a'
assert.equal g.get(1, 0), 'b'
assert.equal g.get(0, 1), 'c'
assert.equal g.get(1, 1), 'd'
assert.equal g.get(99, 99), undefined
assert.equal g.get(-1, -1), undefined

assert.deepEqual g.getRect(0, 0, 2, 2), [['a', 'b'], ['c', 'd']]
assert.deepEqual g.getRect(-1, -1, 2, 2), [[undefined, undefined], [undefined, 'a']]

console.log 'all tests ok'
