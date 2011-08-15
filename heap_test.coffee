assert = require('assert')
heap = require('./heap.coffee')

h = new heap.BinaryHeap()

assert.equal undefined, h.pop()

for x in [50..1]
  h.push x
for x in [1..50]
  assert.equal h.pop(), x

assert.equal undefined, h.pop()

console.log 'all tests ok'
