(function() {
  $(function() {
    var socket;
    return socket = io.connect('/');
  });
}).call(this);
