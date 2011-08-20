(function() {
  var log, str;
  log = function() {
    return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(Array.prototype.slice.call(arguments)) : void 0 : void 0;
  };
  str = function(x) {
    return JSON.stringify(x);
  };
  $(function() {
    var CELL_HEIGHT, CELL_WIDTH, SPRITE_BG, SPRITE_SIZE, body, canvas, canvasH, canvasW, ctx, drawCell, drawSprite, fullRedraw, onUpdate, p, players, socket, spritemap, w;
    body = $(document.body);
    SPRITE_SIZE = 16;
    SPRITE_BG = '#476c6c';
    spritemap = new Image();
    spritemap.src = '/images/nhtiles.png';
    CELL_WIDTH = 16;
    CELL_HEIGHT = 16;
    body.css({
      overflow: 'hidden'
    });
    canvas = document.getElementById('canvas');
    canvas.width = document.width;
    canvas.height = document.height;
    canvasW = canvas.width;
    canvasH = canvas.height;
    ctx = typeof canvas.getContext === "function" ? canvas.getContext('2d') : void 0;
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, canvasW, canvasH);
    w = new World();
    p = new Graph();
    players = {};
    drawSprite = function(sx, sy, dx, dy) {
      var S;
      S = SPRITE_SIZE;
      return ctx.drawImage(spritemap, sx * S, sy * S, S, S, dx, dy, CELL_WIDTH, CELL_HEIGHT);
    };
    drawCell = function(vx, vy, dx, dy) {
      var W, n, sx, sy, value, x;
      value = w.map.get(vx, vy);
      W = w.CELL_WALL;
      switch (value) {
        case W:
          sy = 20;
          n = (function() {
            var _i, _len, _ref, _results;
            _ref = w.map.neighbors(vx, vy, false);
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              x = _ref[_i];
              _results.push(x === W);
            }
            return _results;
          })();
          if (n[0] && n[1] && n[2] && n[3]) {
            sx = 34;
          } else if (n[0] && n[3]) {
            sx = 30;
          } else if (n[1] && n[2]) {
            sx = 31;
          } else if (n[3]) {
            sx = 32;
          } else {
            sx = 34;
          }
          break;
        case w.CELL_ROOM:
          sx = 8;
          sy = 21;
          break;
        case w.CELL_DOOR:
          sx = 2;
          sy = 21;
          break;
        case w.CELL_HALLWAY:
          sx = 9;
          sy = 21;
          break;
        default:
          sx = 39;
          sy = 29;
      }
      return drawSprite(sx, sy, dx, dy);
    };
    fullRedraw = function() {
      var dx, dy, p, pid, vb, vl, vr, vt, vx, vy, _results;
      vl = 0;
      vt = 0;
      vr = canvasW / CELL_WIDTH + 1;
      vb = canvasH / CELL_HEIGHT + 1;
      for (vx = vl; vl <= vr ? vx <= vr : vx >= vr; vl <= vr ? vx++ : vx--) {
        for (vy = vt; vt <= vb ? vy <= vb : vy >= vb; vt <= vb ? vy++ : vy--) {
          dx = (vx - vl) * CELL_WIDTH;
          dy = (vy - vt) * CELL_HEIGHT;
          drawCell(vx, vy, dx, dy);
        }
      }
      _results = [];
      for (pid in players) {
        p = players[pid];
        dx = p.x * CELL_WIDTH;
        dy = p.y * CELL_HEIGHT;
        _results.push(drawSprite(15 + (pid % 14), 8, dx, dy));
      }
      return _results;
    };
    socket = io.connect('http://localhost');
    socket.on('connected', function(socket) {
      return log('connected', socket);
    });
    socket.on('tile', function(data) {
      log('received tile', data.x, data.y);
      w.loadTile(data.x, data.y, data.content);
      return fullRedraw();
    });
    socket.on('allPlayers', function(data) {
      var p, pid;
      for (pid in data) {
        p = data[pid];
        players[p.id] = p;
      }
      return fullRedraw();
    });
    onUpdate = function(p) {
      players[p.id] = p;
      return fullRedraw();
    };
    socket.on('playerUpdate', onUpdate);
    socket.on('newPlayer', onUpdate);
    socket.emit('getTile', {
      x: 0,
      y: 0
    });
    socket.emit('getTile', {
      x: 1,
      y: 0
    });
    $(document).bind('keydown', function(e) {
      switch (String.fromCharCode(e.which)) {
        case 'H':
          socket.emit('movePlayer', {
            direction: 'w'
          });
          break;
        case 'L':
          socket.emit('movePlayer', {
            direction: 'e'
          });
          break;
        case 'J':
          socket.emit('movePlayer', {
            direction: 's'
          });
          break;
        case 'K':
          socket.emit('movePlayer', {
            direction: 'n'
          });
          break;
        case 'Y':
          socket.emit('movePlayer', {
            direction: 'nw'
          });
          break;
        case 'U':
          socket.emit('movePlayer', {
            direction: 'ne'
          });
          break;
        case 'B':
          socket.emit('movePlayer', {
            direction: 'sw'
          });
          break;
        case 'N':
          socket.emit('movePlayer', {
            direction: 'se'
          });
      }
      if (!e.altKey && !e.ctrlKey && !e.metaKey) {
        return false;
      }
    });
    return log('welcome');
  });
}).call(this);
