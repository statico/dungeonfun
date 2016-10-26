###!
Binary heap data structure in CoffeeScript.

Ported from: http://github.com/bgrins/javascript-astar

Includes Binary Heap (with modifications) from Marijn Haverbeke
  URL: http://eloquentjavascript.net/appendix2.html
  License: http://creativecommons.org/licenses/by/3.0/
###

class BinaryHeap

  constructor: (@scoreFunction) ->
    @scoreFunction or= (x) -> x
    @content = []

  push: (el) ->
    @content.push el
    @sinkDown @content.length - 1

  pop: ->
    result = @content[0]
    end = @content.pop()
    if @content.length > 0
      @content[0] = end
      @bubbleUp(0)
    return result

  remove: (node) ->
    i = @content.indexOf(node)
    end = @content.pop()
    if i != @content.length - 1
      @content[i] = end
      if @scoreFunction(end) < @scoreFunction(node)
        @sinkDown(i)
      else
        @bubbleUp(i)

  size: ->
    return @content.length

  rescoreElement: (node) ->
    @sinkDown(@content.indexOf(node))

  sinkDown: (n) ->
    el = @content[n]
    while n > 0
      parentN = ((n + 1) >> 1) - 1
      parent = @content[parentN]
      if @scoreFunction(el) < @scoreFunction(parent)
        @content[parentN] = el
        @content[n] = parent
        n = parentN
      else
        break

  bubbleUp: (n) ->
    length = @content.length
    el = @content[n]
    elemScore = @scoreFunction(el)
    while true
      child2N = (n + 1) << 1
      child1N = child2N - 1
      swap = null
      if child1N < length
        child1 = @content[child1N]
        child1Score = @scoreFunction(child1)
        if child1Score < elemScore
          swap = child1N
      if child2N < length
        child2 = @content[child2N]
        child2Score = @scoreFunction(child2)
        if child2Score < (if swap == null then elemScore else child1Score)
          swap = child2N
      if swap != null
        @content[n] = @content[swap]
        @content[swap] = el
        n = swap
      else
        break

if not exports? then exports = this
exports.BinaryHeap = BinaryHeap
