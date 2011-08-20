log = () -> console?.log?(Array.prototype.slice.call(arguments))
str = (x) -> JSON.stringify x

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

  p = new Graph()
  players = {}

  drawSprite = (sx, sy, dx, dy) ->
    S = SPRITE_SIZE
    ctx.drawImage spritemap, sx * S, sy * S, S, S, dx, dy, CELL_WIDTH, CELL_HEIGHT

  drawCell = (vx, vy, dx, dy) ->
    value = w.map.get vx, vy

    # Determine sprite coords
    W = w.CELL_WALL
    switch value
      when W
        sy = 20
        # Neighbors array: top, left, right, bottom.
        n = (x == W for x in w.map.neighbors(vx, vy, false))
        if n[0] and n[1] and n[2] and n[3] # surrounded
          sx = 34
        else if n[0] and n[3] # vertical wall
          sx = 30
        else if n[1] and n[2] # horizontal wall
          sx = 31
        else if n[3] # top of vertical wall
          sx = 32
        else # eh?
          sx = 34
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
    drawSprite sx, sy, dx, dy

  fullRedraw = ->

    # Viewport map offsets (todo later)
    vl = 0
    vt = 0
    vr = canvasW / CELL_WIDTH + 1
    vb = canvasH / CELL_HEIGHT + 1

    for vx in [vl..vr]
      for vy in [vt..vb]
        # Destination canvas pixel coords
        dx = (vx - vl) * CELL_WIDTH
        dy = (vy - vt) * CELL_HEIGHT
        drawCell vx, vy, dx, dy

    for pid, p of players
      drawPlayer(p)

  drawPlayer = (p, oldx = null, oldy = null) ->
    dx = p.x * CELL_WIDTH
    dy = p.y * CELL_HEIGHT
    # Sprite is a random character based on ID.
    drawSprite 15 + (p.id % 14), 8, dx, dy

    if oldx != null and oldy != null
      dx = oldx * CELL_WIDTH
      dy = oldy * CELL_HEIGHT
      drawCell(oldx, oldy, dx, dy)

  socket = io.connect '/'

  socket.on 'connected', (socket) ->
    log 'connected', socket

  socket.on 'tile', (data) ->
    log 'received tile', data.x, data.y
    w.loadTile data.x, data.y, data.content
    fullRedraw()

  socket.on 'allPlayers', (data) ->
    for pid, p of data
      players[p.id] = p
    fullRedraw()

  onUpdate = (p) ->
    oldp = players[p.id]
    players[p.id] = p
    if oldp
      drawPlayer p, oldp.x, oldp.y
    else
      fullRedraw()
  socket.on 'playerUpdate', onUpdate
  socket.on 'newPlayer', onUpdate

  socket.on 'removePlayer', (p) ->
    delete players[p.id]
    fullRedraw()

  $(document).bind 'keydown', (e) ->
    switch String.fromCharCode(e.which)
      when 'H' then socket.emit 'movePlayer', direction: 'w'
      when 'L' then socket.emit 'movePlayer', direction: 'e'
      when 'J' then socket.emit 'movePlayer', direction: 's'
      when 'K' then socket.emit 'movePlayer', direction: 'n'
      when 'Y' then socket.emit 'movePlayer', direction: 'nw'
      when 'U' then socket.emit 'movePlayer', direction: 'ne'
      when 'B' then socket.emit 'movePlayer', direction: 'sw'
      when 'N' then socket.emit 'movePlayer', direction: 'se'
    if not e.altKey and not e.ctrlKey and not e.metaKey
      return false

  log 'welcome'
  socket.emit 'getTile', {x: 0, y: 0}
  socket.emit 'getTile', {x: 1, y: 0}


