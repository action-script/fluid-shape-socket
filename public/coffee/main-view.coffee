$().ready ->
   window.config.socket.id = undefined
   slaves = []
 
   # socket app
   socket = io(config.server.ip+':'+config.server.port)
   socket.on 'ping', (data) ->
      console.log('ping', data)
      window.config.socket.id = data.socketId
      socket.emit('pong', { clientType: 'view' })
      LoadingCanvas.init()
  
   socket.on 'new Slave', (data) ->
      console.log('I got a new slave', data)
      saveSlave(data)
   
   saveSlave = (data) ->
      slaves.push(data)
      LoadingCanvas.activateSlave(data)
      socket.emit('readyToDraw') if slaves.length >= config.socket.maxConnections

