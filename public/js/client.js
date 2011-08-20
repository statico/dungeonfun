(function() {
  var log;
  log = function() {
    return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(Array.prototype.slice.call(arguments)) : void 0 : void 0;
  };
  $(function() {
    var bgcolor, body, ctx, el, socket, spritemap, tilesize, _base;
    body = $(document.body);
    spritemap = new Image();
    spritemap.src = '/images/nhtiles.png';
    tilesize = 16;
    bgcolor = '#476c6c';
    el = $('<canvas/>').appendTo(body);
    body.add(el).css({
      overflow: 'hidden',
      width: '100%',
      height: '100%'
    });
    ctx = typeof (_base = el[0]).getContext === "function" ? _base.getContext('2d') : void 0;
    if (!ctx) {
      body.append('Browser does not support canvas element');
      return;
    }
    ctx.fillStyle = bgcolor;
    ctx.fillRect(0, 0, el.width(), el.height());
    socket = io.connect('http://localhost');
    socket.on('connected', function(socket) {
      return log('connected', socket);
    });
    socket.on('tile', function(data) {
      return log('got tile', data.x, data.y);
    });
    socket.emit('getTile', {
      x: 0,
      y: 0
    });
    return log('welcome');
  });
}).call(this);
