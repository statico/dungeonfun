log = () -> console?.log?(Array.prototype.slice.call(arguments))

$ ->
  body = $(document.body)
  canvas = $('<canvas/>').appendTo body

  socket = io.connect 'http://localhost'

  socket.on 'connected', (socket) ->
    log 'connected', socket

  socket.on 'tile', (data) ->
    log 'got tile', data.x, data.y

  socket.emit 'getTile', {x: 0, y: 0}

  log 'welcome'
