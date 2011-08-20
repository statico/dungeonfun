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

        # Destination canvas pixel coords
        dx = (vx - vl) * CELL_WIDTH
        dy = (vy - vt) * CELL_HEIGHT

        # Determine sprite coords
        switch value
          when w.CELL_WALL
            sx = 31
            sy = 20
          when w.CELL_ROOM
            sx = 8
            sy = 21
          when w.CELL_DOOR
            sx = 2
            sy = 21
          when w.CELL_HALLWAY
            sx = 9
            sy = 21
          else
            sx = 39
            sy = 29

        # Copy the sprite
        ctx.drawImage spritemap, sx * SPRITE_SIZE, sy * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE, dx, dy, CELL_WIDTH, CELL_HEIGHT

  socket = io.connect 'http://localhost'

  socket.on 'connected', (socket) ->
    log 'connected', socket

  socket.on 'tile', (data) ->
    w.loadTile data.x, data.y, data.content
    redraw()

  socket.emit 'getTile', {x: 0, y: 0}
  socket.emit 'getTile', {x: 1, y: 0}

  log 'welcome'
