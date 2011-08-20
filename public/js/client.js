(function() {
  var log;
  log = function() {
    return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(Array.prototype.slice.call(arguments)) : void 0 : void 0;
  };
  $(function() {
    var CELL_HEIGHT, CELL_WIDTH, SPRITE_BG, SPRITE_SIZE, body, canvas, canvasH, canvasW, ctx, redraw, socket, spritemap, w;
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
    redraw = function() {
      var dx, dy, sx, sy, value, vb, vl, vr, vt, vx, vy, _results;
      vl = 0;
      vt = 0;
      vr = canvasW / CELL_WIDTH + 1;
      vb = canvasH / CELL_HEIGHT + 1;
      _results = [];
      for (vx = vl; vl <= vr ? vx <= vr : vx >= vr; vl <= vr ? vx++ : vx--) {
        _results.push((function() {
          var _results2;
          _results2 = [];
          for (vy = vt; vt <= vb ? vy <= vb : vy >= vb; vt <= vb ? vy++ : vy--) {
            value = w.map.get(vx, vy);
            dx = (vx - vl) * CELL_WIDTH;
            dy = (vy - vt) * CELL_HEIGHT;
            switch (value) {
              case w.CELL_WALL:
                sx = 31;
                sy = 20;
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
            _results2.push(ctx.drawImage(spritemap, sx * SPRITE_SIZE, sy * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE, dx, dy, CELL_WIDTH, CELL_HEIGHT));
          }
          return _results2;
        })());
      }
      return _results;
    };
    socket = io.connect('http://localhost');
    socket.on('connected', function(socket) {
      return log('connected', socket);
    });
    socket.on('tile', function(data) {
      w.loadTile(data.x, data.y, data.content);
      return redraw();
    });
    socket.emit('getTile', {
      x: 0,
      y: 0
    });
    socket.emit('getTile', {
      x: 1,
      y: 0
    });
    return log('welcome');
  });
}).call(this);
