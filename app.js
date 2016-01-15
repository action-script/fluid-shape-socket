var express = require('express')
var app = express()

var config = require('./global_config')

// server
var server = app.listen(config.server.port, function() {
   var host = server.address().address
   var port = server.address().port
   console.log('App listening at http://%s:%s', host, port)
})

app.get('/', function (req, res) {
   res.sendFile(__dirname + '/public/index.html')
})

app.get('/view', function(req, res) {
   res.sendFile(__dirname + '/public/view.html')
})

app.get('/*.(js|css|png|jpg)', function(req, res) {
   res.sendFile(__dirname + "/public" + req.url)
})

app.get('/config', function(req, res) {
   res.setHeader('content-type', 'text/javascript')
   var jsFile = 'window.config = ' + JSON.stringify(config)
   res.send(jsFile)
})


// socket
var io = require('socket.io').listen(server)
var numberOfSlaves = 0
var viewSocket = null

io.on('connection', function (socket) {

   socket.emit('ping', { socketId: socket.id })

   socket.on('pong', function(data) {
      console.log('pong', data)
      if (data.clientType == 'slave') {
         console.log('slave ' + (numberOfSlaves + 1))
         if (numberOfSlaves >= config.socket.maxConnections || viewSocket == null) {
            socket.emit('blocked') 
            socket.disconnect()
         }
         else
            socket.emit('confirmConnection', { slaveId: ++numberOfSlaves })
            if (numberOfSlaves == 4) {
               console.log('4 connections. Ready to be Drawn')
               socket.broadcast.emit('readyToDraw')
            }
      }
      // Save view socket
      else {
         if (data.clientType == 'view') {
            viewSocket = socket.id
            console.log("View socket is now " + socket.id)
         }
      }
   })

   socket.on('pushSlaveConnection', function(data) {
      console.log('slave ' + data.slaveId + ' is ready.')
      io.sockets.connected[viewSocket].emit('new Slave', data)
   })

   socket.on('pushPosition', function(data) {
//      console.log('position data: ', data)
      io.sockets.connected[viewSocket].emit('newPosition', data)
   })

})
