(function() {
  var log;
  log = function() {
    return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(Array.prototype.slice.call(arguments)) : void 0 : void 0;
  };
  $(function() {
    var body, canvas, socket;
    body = $(document.body);
    canvas = $('<canvas/>').appendTo(body);
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
