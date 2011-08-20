(function() {
  var World, graph, heap, perlin, randInt;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  perlin = require('./third-party/perlin.js');
  graph = require('./graph.coffee');
  heap = require('./heap.coffee');
  randInt = function(x) {
    return Math.floor(Math.random() * x);
  };
  World = (function() {
    World.prototype.TILE_SIZE = 50;
    World.prototype.CELL_EMPTY = 0;
    World.prototype.CELL_WALL = 1;
    World.prototype.CELL_ROOM = 2;
    World.prototype.CELL_DOOR = 3;
    World.prototype.CELL_HALLWAY = 6;
    function World() {
      this.map = new graph.Graph();
    }
    World.prototype.getTile = function(tx, ty) {
      var l, t;
      l = tx * this.TILE_SIZE;
      t = ty * this.TILE_SIZE;
      return this.map.getRect(l, t, this.TILE_SIZE, this.TILE_SIZE);
    };
    World.prototype.makeTile = function(tx, ty) {
      var b, l, r, rooms, t;
      l = tx * this.TILE_SIZE;
      r = (tx + 1) * this.TILE_SIZE;
      t = ty * this.TILE_SIZE;
      b = (ty + 1) * this.TILE_SIZE;
      rooms = this.makeRooms(t, r, b, l);
      return this.makeHallways(t, r, b, l, rooms);
    };
    World.prototype.loadTile = function(tx, ty, content) {
      var b, l, r, row, t, x, y, _results;
      l = tx * this.TILE_SIZE;
      r = (tx + 1) * this.TILE_SIZE;
      t = ty * this.TILE_SIZE;
      b = (ty + 1) * this.TILE_SIZE;
      _results = [];
      for (y = t; t <= b ? y <= b : y >= b; t <= b ? y++ : y--) {
        row = content[y - t];
        _results.push((function() {
          var _results2;
          _results2 = [];
          for (x = l; l <= r ? x <= r : x >= r; l <= r ? x++ : x--) {
            _results2.push(this.map.set(x, y, row != null ? row[x - l] : void 0));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };
    World.prototype.makeRooms = function(T, R, B, L) {
      var b, count, current, i, l, ok, other, r, room, roomCollision, rooms, rx, ry, t, x, y, _i, _j, _len, _ref, _ref2, _ref3, _ref4;
      rooms = [];
      roomCollision = function(tuple1, tuple2, pad) {
        var b1, b2, l1, l2, r1, r2, t1, t2;
        if (pad == null) {
          pad = 1;
        }
        t1 = tuple1[0], r1 = tuple1[1], b1 = tuple1[2], l1 = tuple1[3];
        t2 = tuple2[0], r2 = tuple2[1], b2 = tuple2[2], l2 = tuple2[3];
        if (b1 < t2 - pad) {
          return false;
        }
        if (t1 > b2 + pad) {
          return false;
        }
        if (r1 < l2 - pad) {
          return false;
        }
        if (l1 > r2 + pad) {
          return false;
        }
        return true;
      };
      for (i = 1, _ref = Math.floor(this.TILE_SIZE * this.TILE_SIZE / 300); 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        while (true) {
          l = L + randInt(R - L);
          t = T + randInt(B - T);
          r = l + 6 + randInt(12);
          b = t + 3 + randInt(10);
          if (l <= L || t <= T) {
            continue;
          }
          if (r >= R - 1) {
            continue;
          }
          if (b >= B - 1) {
            continue;
          }
          current = [t, r, b, l];
          ok = true;
          for (_i = 0, _len = rooms.length; _i < _len; _i++) {
            other = rooms[_i];
            if (roomCollision(current, other)) {
              ok = false;
              break;
            }
          }
          if (ok) {
            rooms.push(current);
            break;
          }
        }
      }
      for (i = 0, _ref2 = rooms.length - 1; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
        room = rooms[i];
        t = room[0], r = room[1], b = room[2], l = room[3];
        for (y = t; t <= b ? y <= b : y >= b; t <= b ? y++ : y--) {
          for (x = l; l <= r ? x <= r : x >= r; l <= r ? x++ : x--) {
            this.map.set(x, y, this.CELL_ROOM);
          }
        }
        for (x = l; l <= r ? x <= r : x >= r; l <= r ? x++ : x--) {
          this.map.set(x, t, this.CELL_WALL);
          this.map.set(x, b, this.CELL_WALL);
        }
        for (y = _ref3 = t + 1, _ref4 = b - 1; _ref3 <= _ref4 ? y <= _ref4 : y >= _ref4; _ref3 <= _ref4 ? y++ : y--) {
          this.map.set(l, y, this.CELL_WALL);
          this.map.set(r, y, this.CELL_WALL);
        }
        count = 1 + randInt((r - l) * 2 / 10);
        for (_j = 1; 1 <= count ? _j <= count : _j >= count; 1 <= count ? _j++ : _j--) {
          rx = l + 1 + randInt(r - l - 1);
          ry = t + 1 + randInt(b - t - 1);
          switch (randInt(4)) {
            case 0:
              x = rx;
              y = t;
              break;
            case 1:
              x = r;
              y = ry;
              break;
            case 2:
              x = rx;
              y = b;
              break;
            case 3:
              x = l;
              y = ry;
          }
          this.map.set(x, y, this.CELL_DOOR);
        }
      }
      return rooms;
    };
    World.prototype.makeHallways = function(T, R, B, L, rooms) {
      var a, b, filter, findDoors, hallwayPoints, heuristic, i, j, noise, other, p, path, r, room, x, x1, x2, y, y1, y2, _i, _len, _ref, _ref2, _ref3, _ref4, _ref5, _results;
      noise = new perlin.SimplexNoise({
        random: function() {
          return 0.123;
        }
      });
      heuristic = __bind(function(p1, p2) {
        var d1, d2, n;
        if (p2.value === this.CELL_HALLWAY) {
          return 0;
        } else {
          d1 = Math.abs(p2.x - p1.x);
          d2 = Math.abs(p2.y - p1.y);
          n = Math.floor(noise.noise(p1.x / 15, p1.y / 15) * 20);
          return d1 + d2 + n;
        }
      }, this);
      filter = __bind(function(node) {
        var x;
        x = node.value;
        return !x || x === this.CELL_EMPTY || x === this.CELL_DOOR || x === this.CELL_HALLWAY;
      }, this);
      findDoors = __bind(function(room) {
        var b, doors, l, r, t, x, y;
        t = room[0], r = room[1], b = room[2], l = room[3];
        doors = [];
        for (x = l; l <= r ? x <= r : x >= r; l <= r ? x++ : x--) {
          if (this.map.get(x, t) === this.CELL_DOOR) {
            doors.push([x, t]);
          }
          if (this.map.get(x, b) === this.CELL_DOOR) {
            doors.push([x, b]);
          }
        }
        for (y = t; t <= b ? y <= b : y >= b; t <= b ? y++ : y--) {
          if (this.map.get(l, y) === this.CELL_DOOR) {
            doors.push([l, y]);
          }
          if (this.map.get(r, y) === this.CELL_DOOR) {
            doors.push([r, y]);
          }
        }
        return doors;
      }, this);
      hallwayPoints = [];
      for (i = 0, _ref = rooms.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        j = i;
        while (j === i) {
          j = randInt(rooms.length);
        }
        room = rooms[i];
        other = rooms[j];
        a = findDoors(room);
        b = findDoors(other);
        if (!a.length || !b.length) {
          continue;
        }
        _ref2 = a[0], x1 = _ref2[0], y1 = _ref2[1];
        _ref3 = b[0], x2 = _ref3[0], y2 = _ref3[1];
        path = this.map.astar(x1, y1, x2, y2, filter, heuristic);
        for (_i = 0, _len = path.length; _i < _len; _i++) {
          p = path[_i];
          this.map.setPoint(p, this.CELL_HALLWAY);
          hallwayPoints.push(p);
        }
      }
      _results = [];
      for (i = 1, _ref4 = Math.floor(this.TILE_SIZE * this.TILE_SIZE / 600); 1 <= _ref4 ? i <= _ref4 : i >= _ref4; 1 <= _ref4 ? i++ : i--) {
        _ref5 = hallwayPoints[randInt(hallwayPoints.length)], x1 = _ref5[0], y1 = _ref5[1];
        x2 = void 0;
        r = Math.floor(this.TILE_SIZE * .2);
        while (!x2) {
          x = x1 - r + randInt(r * 2);
          y = y1 - r + randInt(r * 2);
          if (!this.map.get(x, y)) {
            x2 = x;
            y2 = y;
          }
        }
        path = this.map.astar(x1, y1, x2, y2, filter, heuristic);
        _results.push((function() {
          var _j, _len2, _results2;
          _results2 = [];
          for (_j = 0, _len2 = path.length; _j < _len2; _j++) {
            p = path[_j];
            _results2.push(this.map.setPoint(p, this.CELL_HALLWAY));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };
    World.prototype.connectTiles = function(tx1, ty1, tx2, ty2) {
      var PADDING, S, choices, dir, filter, obj, p, p1, p2, path, points, t1p, t2p, value, x, y, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _results;
      S = this.TILE_SIZE;
      PADDING = 10;
      if ((tx2 - tx1) + (ty2 - ty1) !== 1) {
        console.warn('Tried to connect to non-adjacent tiles');
        return;
      }
      if (ty1 > ty2) {
        dir = 1;
      }
      if (tx1 < tx2) {
        dir = 2;
      }
      if (ty1 < ty2) {
        dir = 3;
      }
      if (tx1 > tx2) {
        dir = 4;
      }
      if (dir === 2) {
        for (x = _ref = tx1 * S + S - 1 - PADDING, _ref2 = tx1 * S; _ref <= _ref2 ? x <= _ref2 : x >= _ref2; _ref <= _ref2 ? x++ : x--) {
          points = [];
          for (y = _ref3 = ty1 * S, _ref4 = ty1 * S + S; _ref3 <= _ref4 ? y <= _ref4 : y >= _ref4; _ref3 <= _ref4 ? y++ : y--) {
            value = this.map.get(x, y);
            if (value === this.CELL_HALLWAY || value === this.CELL_DOOR) {
              points.push([x, y]);
            }
          }
          if (points.length) {
            break;
          }
        }
        t1p = points;
        for (x = _ref5 = tx2 * S + PADDING, _ref6 = tx2 * S + S; _ref5 <= _ref6 ? x <= _ref6 : x >= _ref6; _ref5 <= _ref6 ? x++ : x--) {
          points = [];
          for (y = _ref7 = ty1 * S, _ref8 = ty1 * S + S; _ref7 <= _ref8 ? y <= _ref8 : y >= _ref8; _ref7 <= _ref8 ? y++ : y--) {
            value = this.map.get(x, y);
            if (value === this.CELL_HALLWAY || value === this.CELL_DOOR) {
              points.push([x, y]);
            }
          }
          if (points.length) {
            break;
          }
        }
        t2p = points;
        p1 = t1p[randInt(t1p.length)];
        choices = new heap.BinaryHeap(function(obj) {
          return obj.distance;
        });
        for (_i = 0, _len = t2p.length; _i < _len; _i++) {
          p2 = t2p[_i];
          choices.push({
            x: p2[0],
            y: p2[1],
            distance: (p2[0] - p1[0]) + (p2[1] - p1[1])
          });
        }
        obj = choices.pop();
        p2 = [obj.x, obj.y];
        if (!(p1 != null ? p1.length : void 0) || !(p2 != null ? p2.length : void 0)) {
          console.warn('Could not join tiles', tx1, ty1, tx2, ty2);
          return;
        }
        filter = __bind(function(node) {
          x = node.value;
          return !x || x === this.CELL_EMPTY || x === this.CELL_DOOR || x === this.CELL_HALLWAY;
        }, this);
        path = this.map.astar(p1[0], p1[1], p2[0], p2[1], filter);
        _results = [];
        for (_j = 0, _len2 = path.length; _j < _len2; _j++) {
          p = path[_j];
          _results.push(this.map.setPoint(p, this.CELL_HALLWAY));
        }
        return _results;
      }
    };
    return World;
  })();
  exports || (exports = this);
  exports.World = World;
}).call(this);
