var express = require('express')
var app = express()

// server
var server = app.listen('3000', function() {
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
/*
app.get('/config', function(req, res) {
   res.setHeader('content-type', 'text/javascript')
   var jsFile = 'window.config = ' + JSON.stringify(config)
   res.send(jsFile)
})
*/


// socket
var io = require('socket.io').listen(server)
var slaveIds = []
var viewSocket = null

io.on('connection', function (socket) {
   console.log('connection', socket.id);
   socket.emit('myping', { socketId: socket.id })

   socket.on('mypong', function(data) {
      if (data.clientType == 'slave') {
         console.log('slave ' + slaveIds.length)
         if (slaveIds.length >= 4 || viewSocket == null) {
            socket.emit('blocked') 
            socket.disconnect()
         }
         else
            slaveIds.push(socket.id)
            socket.emit('confirmConnection', { slaveId: slaveIds.length })
            if (slaveIds.length == 4) {
               console.log('4 connections. Ready to be Drawn')
               socket.broadcast.emit('readyToDraw')
            }
      }
      // Save view socket
      else {
         if (data.clientType == 'view' && viewSocket == null) {
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

   socket.on('disconnect', function() {
      console.log('disconnected', socket.id)
      slaveIds = []

      if (viewSocket == socket.id) {
         viewSocket = null
         console.log('disconnecting all slaves')
         io.sockets.sockets.forEach(function(s) {
            s.disconnect(true)
         })
      }
      else {
         socket.broadcast.emit('restart')
         io.sockets.sockets.forEach(function(s, i) {
            if (i != 0)
               slaveIds.push(s.id) 
            s.emit(
               'confirmConnection',
               { slaveId: i, restart: true }
            )
         })
      }
   })

})


