log = () -> console?.log?(Array.prototype.slice.call(arguments))

$ ->
  body = $(document.body)

  spritemap = new Image()
  spritemap.src = '/images/nhtiles.png'
  tilesize = 16 # pixels
  bgcolor = '#476c6c'


  el = $('<canvas/>').appendTo(body)
  body.add(el).css
    overflow: 'hidden'
    width: '100%'
    height: '100%'
  ctx = el[0].getContext?('2d')
  if not ctx
    body.append('Browser does not support canvas element')
    return
  ctx.fillStyle = bgcolor
  ctx.fillRect 0, 0, el.width(), el.height()


  socket = io.connect 'http://localhost'

  socket.on 'connected', (socket) ->
    log 'connected', socket

  socket.on 'tile', (data) ->
    log 'got tile', data.x, data.y

  socket.emit 'getTile', {x: 0, y: 0}

  log 'welcome'
