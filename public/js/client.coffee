log = () -> console?.log?(Array.prototype.slice.call(arguments))

$ ->
  body = $(document.body)

  SPRITE_SIZE = 16 # pixels
  SPRITE_BG = '#476c6c'
  spritemap = new Image()
  spritemap.src = '/images/nhtiles.png'

  CELL_WIDTH = 16
  CELL_HEIGHT = 16

  body.css overflow: 'hidden'
  canvas = document.getElementById('canvas')
  canvas.width = document.width
  canvas.height = document.height
  canvasW = canvas.width
  canvasH = canvas.height
  ctx = canvas.getContext?('2d')
  ctx.fillStyle = 'black'
  ctx.fillRect 0, 0, canvasW, canvasH

  w = new World()

  redraw = ->

    # Viewport map offsets (todo later)
    vl = 0
    vt = 0
    vr = canvasW / CELL_WIDTH + 1
    vb = canvasH / CELL_HEIGHT + 1

    for vx in [vl..vr]
      for vy in [vt..vb]
        value = w.map.get vx, vy

        dx = (vx - vl) * CELL_WIDTH
        dy = (vy - vt) * CELL_HEIGHT

        if value
          ctx.fillStyle = 'white'
        else
          ctx.fillStyle = 'black'
        ctx.strokeStyle = 'red'
        ctx.fillRect dx, dy, CELL_WIDTH, CELL_HEIGHT

  socket = io.connect 'http://localhost'

  socket.on 'connected', (socket) ->
    log 'connected', socket

  socket.on 'tile', (data) ->
    w.loadTile data.x, data.y, data.content
    redraw()

  socket.emit 'getTile', {x: 0, y: 0}

  log 'welcome'
