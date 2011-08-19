express = require 'express'
world = require './static/js/world.coffee'
socketio = require 'socket.io'

w = new world.World()
w.makeTile 0, 0
w.makeTile 1, 0
w.connectTiles 0,0, 1,0

t1 = w.getTile 0, 0
t2 = w.getTile 1, 0

format = (row) ->
  line = row.join('')
  line = line.replace(/0/g, '.')
  line = line.replace(/(\d)/g, "\x1b[3$1m$1\x1b[0m")
  return line

app = express.createServer ->
  app.use express.logger()
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    secret: 'b35$6dff0YC1694421##2a4$9)CE!bc0'
  app.use app.router
  app.use express.static __dirname + '/static'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.set 'views', __dirname + '/views'
app.set 'view options',
  layout: false

app.get '/', (req, res) ->
  res.render 'index.jade',
    message: 'world'

io = socketio.listen app
io.sockets.on 'connection', (socket) ->
  conosle.info 'client connected', socket

port = process.env.PORT or 3000
console.info "Listening on http://127.0.0.1:#{port}/"
app.listen port
