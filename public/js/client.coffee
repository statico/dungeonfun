log = () -> console?.log?(Array.prototype.slice.call(arguments))
str = (x) -> JSON.stringify x

BGCOLOR = 'black'

SPRITE_SIZE = 16 # pixels
SPRITE_BG = '#476c6c'
spritemap = new Image()
spritemap.src = '/images/nhtiles.png'

CELL_WIDTH = 16
CELL_HEIGHT = 16

SCROLL_PADDING = 70 # pixels

class Viewport

  constructor: (@canvas) ->
    @set 0, 0

  set: (x, y) ->
    @l = x
    @t = y
    @r = x + Math.floor(@canvas.width / CELL_WIDTH) + 1
    @b = y + Math.floor(@canvas.height / CELL_HEIGHT) + 1

  translate: (x, y) ->
    @set @l + x, @t + y

  xToCanvasX: (x) ->
    return (x - @l) * CELL_WIDTH

  yToCanvasY: (y) ->
    return (y - @t) * CELL_HEIGHT

$ ->
  body = $(document.body)

  body.css overflow: 'hidden'
  canvas = document.getElementById('canvas')
  canvas.width = document.width
  canvas.height = document.height
  ctx = canvas.getContext?('2d')
  ctx.fillStyle = BGCOLOR
  ctx.fillRect 0, 0, canvas.width, canvas.height

  v = new Viewport(canvas)
  w = new World()

  p = new Graph()
  players = {}
  mypid = null

  drawSprite = (sx, sy, dx, dy) ->
    S = SPRITE_SIZE
    ctx.drawImage spritemap, sx * S, sy * S, S, S, dx, dy, CELL_WIDTH, CELL_HEIGHT

  drawCell = (x, y, dx, dy) ->
    value = w.map.get x, y

    # Determine sprite coords
    W = w.CELL_WALL
    switch value
      when W
        sy = 20
        # Neighbors array: top, left, right, bottom.
        n = (i == W for i in w.map.neighbors(x, y, false))
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

    for x in [v.l..v.r]
      for y in [v.t..v.b]
        # Destination canvas pixel coords
        dx = (x - v.l) * CELL_WIDTH
        dy = (y - v.t) * CELL_HEIGHT
        drawCell x, y, dx, dy

    for pid, p of players
      drawPlayer(p)

  drawPlayer = (p, oldx = null, oldy = null) ->
    # Sprite is a random character based on ID.
    drawSprite 15 + (p.id % 14), 8, v.xToCanvasX(p.x), v.yToCanvasY(p.y)

    if oldx != null and oldy != null
      drawCell oldx, oldy, v.xToCanvasX(oldx), v.yToCanvasY(oldy)

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

      # If *we* have been updated, make sure we're not too far off the screen
      # and scroll the map by adjusting the Viewport and redrawing.
      if p.id == mypid
        vx = v.xToCanvasX(p.x)
        vy = v.yToCanvasY(p.y)
        P = SCROLL_PADDING
        T = Math.floor(SCROLL_PADDING / CELL_WIDTH * 2)
        tx = ty = 0
        if vx < P
          tx = -T
        if vx > v.canvas.width - P
          tx = T
        if vy < P
          ty = -T
        if vy > v.canvas.height - P
          ty = T
        if tx or ty
          # Do a nice transition. Math is silly.
          imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
          steps = 5
          time = 100 # ms
          dx = -tx * CELL_WIDTH / steps
          dy = -ty * CELL_HEIGHT / steps
          step = 0
          animate = ->
            step++
            ctx.fillStyle = BGCOLOR
            ctx.fillRect 0, 0, canvas.width, canvas.height
            ctx.putImageData imageData, dx * step, dy * step
            if step < steps
              setTimeout animate, time / steps
            else
              v.translate tx, ty
              fullRedraw()
          animate()
    else
      fullRedraw()
  socket.on 'playerUpdate', onUpdate
  socket.on 'newPlayer', onUpdate

  socket.on 'you', (p) ->
    mypid = p.id

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


