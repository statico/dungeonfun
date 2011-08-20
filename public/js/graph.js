(function() {
  /*!
  Infinite 2D graph data structure.
  
  Uses the astar pathfinding algorithm from http://github.com/bgrins/javascript-astar
  */
  var Graph, heap;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  heap = require('./heap.coffee');
  Graph = (function() {
    function Graph(initial) {
      var row, x, y, _ref, _ref2;
      if (initial == null) {
        initial = null;
      }
      this.MAX_HEAP_SIZE = 500;
      this.map = {};
      if (initial) {
        for (y = 0, _ref = initial.length - 1; 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
          row = initial[y];
          for (x = 0, _ref2 = row.length - 1; 0 <= _ref2 ? x <= _ref2 : x >= _ref2; 0 <= _ref2 ? x++ : x--) {
            this.set(x, y, initial[y][x]);
          }
        }
      }
    }
    Graph.prototype.get = function(x, y) {
      var _ref;
      return ((_ref = this.map[x]) != null ? _ref[y] : void 0) || 0;
    };
    Graph.prototype.getPoint = function(p) {
      return this.get(p[0], p[1]);
    };
    Graph.prototype.set = function(x, y, value) {
      var a;
      a = this.map[x];
      if (!(a != null)) {
        a = this.map[x] = {};
      }
      return a[y] = value;
    };
    Graph.prototype.setPoint = function(p, value) {
      return this.set(p[0], p[1], value);
    };
    Graph.prototype.getRect = function(x, y, w, h) {
      var j, k, result, row, _ref, _ref2;
      result = [];
      for (k = y, _ref = y + h - 1; y <= _ref ? k <= _ref : k >= _ref; y <= _ref ? k++ : k--) {
        row = [];
        for (j = x, _ref2 = x + w - 1; x <= _ref2 ? j <= _ref2 : j >= _ref2; x <= _ref2 ? j++ : j--) {
          row.push(this.get(j, k));
        }
        result.push(row);
      }
      return result;
    };
    Graph.prototype.neighbors = function(x, y, includeDiagonals) {
      if (includeDiagonals == null) {
        includeDiagonals = true;
      }
      if (includeDiagonals) {
        return [[x - 1, y - 1], [x, y - 1], [x + 1, y - 1], [x - 1, y], [x + 1, y], [x - 1, y + 1], [x, y + 1], [x + 1, y + 1]];
      } else {
        return [[x, y - 1], [x - 1, y], [x + 1, y], [x, y + 1]];
      }
    };
    Graph.prototype.astar = function(x1, y1, x2, y2, filter, heuristic, includeDiagonals) {
      var beenVisited, current, end, gScore, getNode, n, neighbor, nodes, open, p, ret, start, _i, _len, _ref;
      if (filter == null) {
        filter = null;
      }
      if (heuristic == null) {
        heuristic = null;
      }
      if (includeDiagonals == null) {
        includeDiagonals = false;
      }
      nodes = {};
      getNode = __bind(function(x, y) {
        var key;
        key = x + ',' + y;
        return nodes[key] || (nodes[key] = {
          x: x,
          y: y,
          value: this.get(x, y)
        });
      }, this);
      start = getNode(x1, y1);
      end = getNode(x2, y2);
      filter || (filter = function(node) {
        return node.value > 0;
      });
      heuristic || (heuristic = function(n1, n2) {
        var d1, d2;
        d1 = Math.abs(n2.x - n1.x);
        d2 = Math.abs(n2.y - n1.y);
        return d1 + d2;
      });
      open = new heap.BinaryHeap(function(node) {
        return node.f;
      });
      open.push(start);
      while (open.size() > 0 && open.size() < this.MAX_HEAP_SIZE) {
        current = open.pop();
        if (current === end) {
          n = current;
          ret = [];
          while (n.parent) {
            if (n !== end) {
              ret.push([n.x, n.y]);
            }
            n = n.parent;
          }
          return ret.reverse();
        }
        current.closed = true;
        _ref = this.neighbors(current.x, current.y, includeDiagonals);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          neighbor = getNode(p[0], p[1]);
          if (neighbor.closed || !filter(neighbor)) {
            continue;
          }
          gScore = (current.g || 0) + 1;
          beenVisited = neighbor.visited;
          if (!beenVisited || gScore < (neighbor.g || 0)) {
            neighbor.visited = true;
            neighbor.parent = current;
            neighbor.h || (neighbor.h = heuristic(neighbor, end));
            neighbor.g = gScore;
            neighbor.f = neighbor.g + neighbor.h;
            if (!beenVisited) {
              open.push(neighbor);
            } else {
              open.rescoreElement(neighbor);
            }
          }
        }
      }
      return [];
    };
    return Graph;
  })();
  exports || (exports = this);
  exports.Graph = Graph;
}).call(this);
