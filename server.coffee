log = () -> console?.log?(Array.prototype.slice.call(arguments))

http = require 'http'
express = require 'express'
world = require './public/js/world.coffee'
graph = require './public/js/graph.coffee'
socketio = require 'socket.io'

# WORLD ---------------------------------------------------------------------

w = new world.World()
for i in [-3..3]
  for j in [-3..3]
    w.makeTile i, j
for i in [-3..3]
  for j in [-3..3]
    w.connectTiles i, j, i - 1, j
    w.connectTiles i, j, i + 1, j
    w.connectTiles i, j, i, j - 1
    w.connectTiles i, j, i, j + 1

p = new graph.Graph()
players = {}
lastPlayerId = 0

# EXPRESS -------------------------------------------------------------------

app = express()

app.use express.static './public'

app.set 'views', './views'
app.set 'view engine', 'pug'
app.set 'view options',
  layout: false

app.get '/', (req, res) ->
  res.render 'main.pug',
    title: 'nodefun'
    message: 'world'

# SOCKET.IO -----------------------------------------------------------------

server = http.createServer app
io = socketio.listen server

io.on 'connection', (socket) ->
  # Find a empty coord for the new player
  x = -1
  y = -1
  while w.map.get(x, y) != w.CELL_ROOM or p.get(x, y)
    x = Math.floor(Math.random() * 30)
    y = Math.floor(Math.random() * 20)
  player =
    x: x
    y: y
    id: lastPlayerId++
  players[player.id] = player
  log 'New player:', player
  socket.broadcast.emit 'newPlayer', player
  socket.emit 'allPlayers', players
  socket.emit 'you', player

  socket.on 'disconnect', ->
    log 'Disconnected:', player
    socket.broadcast.emit 'removePlayer', player
    delete players[player.id]
    p.clear player.x, player.y

  socket.on 'movePlayer', (data) ->
    directions =
      nw: [-1, -1]
      n:  [0,  -1]
      ne: [1,  -1]
      w:  [-1, 0]
      e:  [1,  0]
      sw: [-1, 1]
      s:  [0,  1]
      se: [1,  1]
    delta = directions[data.direction]
    return if not delta

    x = player.x + delta[0]
    y = player.y + delta[1]
    value = w.map.get x, y
    if (value != w.CELL_ROOM and value != w.CELL_DOOR and value != w.CELL_HALLWAY) or p.get(x, y)
      return

    p.clear player.x, player.y
    player.x = x
    player.y = y
    p.set x, y, player

    socket.broadcast.emit 'playerUpdate', player
    socket.emit 'playerUpdate', player

  socket.on 'getTile', (data) ->
    socket.emit 'tile',
      x: data.x
      y: data.y
      content: w.getTile data.x, data.y


# BEGIN ---------------------------------------------------------------------

port = process.env.PORT or 5000
log "Listening on http://127.0.0.1:#{port}/"
server.listen port

