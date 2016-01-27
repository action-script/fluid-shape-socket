$().ready ->
   window.config.socket.id = undefined
   window.config.drawing = false
   slaves = []
 
   # socket app
   socket = io(config.server.ip+':'+config.server.port)
   socket.on 'ping', (data) ->
      console.log('ping', data)
      config.socket.id = data.socketId
      socket.emit('pong', { clientType: 'view' })
      LoadingCanvas.init()
      #MeshCanvas.init()
  
   socket.on 'new Slave', (data) ->
      console.log('I got a new slave', data)
      slaves.push(data)
      LoadingCanvas.activateSlave(data)

   socket.on 'readyToDraw', (data) ->
      setTimeout () ->
         LoadingCanvas.stop()
         MeshCanvas.init()
         config.drawing = true
      , 2000
      console.log('ready to be drawn')

   socket.on 'newPosition', (data) ->
      console.log('new position')
      MeshCanvas.pushVertexPos(data) if config.drawing && data.slaveId < 4
      MeshCanvas.moveCamera(data) if config.drawing && data.slaveId == 4
