$().ready ->
   window.config.socket.id = undefined
   slaves = []
 
   # socket app
   socket = io(config.server.ip+':'+config.server.port)
   socket.on 'ping', (data) ->
      console.log('ping', data)
      window.config.socket.id = data.socketId
      socket.emit('pong', { clientType: 'view' })
      # TODO: remove test
      #LoadingCanvas.init()
      MeshCanvas.init()
  
   socket.on 'new Slave', (data) ->
      console.log('I got a new slave', data)
      slaves.push(data)
      LoadingCanvas.activateSlave(data)

   socket.on 'readyToDraw', (data) ->
      setTimeout () ->
         LoadingCanvas.stop()
         MeshCanvas.init()
      , 2000
      console.log('ready to be drawn')

