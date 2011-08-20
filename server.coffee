log = () -> console?.log?(Array.prototype.slice.call(arguments))

express = require 'express'
world = require './public/js/world.coffee'
socketio = require 'socket.io'

# WORLD ---------------------------------------------------------------------

w = new world.World()
w.makeTile 0, 0
w.makeTile 1, 0
w.connectTiles 0,0, 1,0

# EXPRESS -------------------------------------------------------------------

app = express.createServer()

app.configure ->
  app.use express.logger()
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    secret: 'b35$6dff0YC1694421##2a4$9)CE!bc0'
  app.use app.router
  app.use express.compiler
    src: __dirname + '/public'
    enable: ['sass', 'coffeescript']
  app.use express.static __dirname + '/public'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.set 'views', __dirname + '/views'
app.set 'view options',
  layout: false

app.get '/', (req, res) ->
  res.render 'main.jade',
    title: 'hello'
    message: 'world'

# SOCKET.IO -----------------------------------------------------------------

io = socketio.listen app
io.configure ->
  io.set 'transports', ['xhr-polling']

io.sockets.on 'connection', (socket) ->
  socket.on 'getTile', (data) ->
    socket.emit 'tile',
      x: data.x
      y: data.y
      content: w.getTile data.x, data.y

# BEGIN ---------------------------------------------------------------------

port = process.env.PORT or 3000
log "Listening on http://127.0.0.1:#{port}/"
app.listen port

