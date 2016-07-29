$().ready ->
   window.config = {}
   window.config.socket = {}
   window.config.drawing = false
   slaves = []

   # socket app
   socket = io()
   socket.on 'myping', (data) ->
      console.log('ping', data)
      config.socket.id = data.socketId
      socket.emit('mypong', { clientType: 'view' })
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

   socket.on 'restart', (data) ->
      MeshCanvas.stop()
      LoadingCanvas.restart()

   socket.on 'newPosition', (data) ->
      console.log('new position')
      MeshCanvas.pushVertexPos(data) if config.drawing && data.slaveId < 4
      MeshCanvas.moveCamera(data) if config.drawing && data.slaveId == 4
