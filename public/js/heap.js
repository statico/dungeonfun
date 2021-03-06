// Generated by CoffeeScript 1.10.0

/*!
Binary heap data structure in CoffeeScript.

Ported from: http://github.com/bgrins/javascript-astar

Includes Binary Heap (with modifications) from Marijn Haverbeke
  URL: http://eloquentjavascript.net/appendix2.html
  License: http://creativecommons.org/licenses/by/3.0/
 */

(function() {
  var BinaryHeap, exports;

  BinaryHeap = (function() {
    function BinaryHeap(scoreFunction) {
      this.scoreFunction = scoreFunction;
      this.scoreFunction || (this.scoreFunction = function(x) {
        return x;
      });
      this.content = [];
    }

    BinaryHeap.prototype.push = function(el) {
      this.content.push(el);
      return this.sinkDown(this.content.length - 1);
    };

    BinaryHeap.prototype.pop = function() {
      var end, result;
      result = this.content[0];
      end = this.content.pop();
      if (this.content.length > 0) {
        this.content[0] = end;
        this.bubbleUp(0);
      }
      return result;
    };

    BinaryHeap.prototype.remove = function(node) {
      var end, i;
      i = this.content.indexOf(node);
      end = this.content.pop();
      if (i !== this.content.length - 1) {
        this.content[i] = end;
        if (this.scoreFunction(end) < this.scoreFunction(node)) {
          return this.sinkDown(i);
        } else {
          return this.bubbleUp(i);
        }
      }
    };

    BinaryHeap.prototype.size = function() {
      return this.content.length;
    };

    BinaryHeap.prototype.rescoreElement = function(node) {
      return this.sinkDown(this.content.indexOf(node));
    };

    BinaryHeap.prototype.sinkDown = function(n) {
      var el, parent, parentN, results;
      el = this.content[n];
      results = [];
      while (n > 0) {
        parentN = ((n + 1) >> 1) - 1;
        parent = this.content[parentN];
        if (this.scoreFunction(el) < this.scoreFunction(parent)) {
          this.content[parentN] = el;
          this.content[n] = parent;
          results.push(n = parentN);
        } else {
          break;
        }
      }
      return results;
    };

    BinaryHeap.prototype.bubbleUp = function(n) {
      var child1, child1N, child1Score, child2, child2N, child2Score, el, elemScore, length, results, swap;
      length = this.content.length;
      el = this.content[n];
      elemScore = this.scoreFunction(el);
      results = [];
      while (true) {
        child2N = (n + 1) << 1;
        child1N = child2N - 1;
        swap = null;
        if (child1N < length) {
          child1 = this.content[child1N];
          child1Score = this.scoreFunction(child1);
          if (child1Score < elemScore) {
            swap = child1N;
          }
        }
        if (child2N < length) {
          child2 = this.content[child2N];
          child2Score = this.scoreFunction(child2);
          if (child2Score < (swap === null ? elemScore : child1Score)) {
            swap = child2N;
          }
        }
        if (swap !== null) {
          this.content[n] = this.content[swap];
          this.content[swap] = el;
          results.push(n = swap);
        } else {
          break;
        }
      }
      return results;
    };

    return BinaryHeap;

  })();

  if (typeof exports === "undefined" || exports === null) {
    exports = this;
  }

  exports.BinaryHeap = BinaryHeap;

}).call(this);
