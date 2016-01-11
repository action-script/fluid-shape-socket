$().ready ->
   window.config.socket.id = null


   # socket app
   socket = io(config.server.ip+':'+config.server.port)
   socket.on 'ping', (data) ->
      console.log('ping', data)
      window.config.socket.id = data.socketId
      socket.emit('pong', { clientType: 'slave' })

   socket.on 'confirmConnection', (data) ->
      console.log('connection confirmed', data)
      window.config.slaveId = data.slaveId
      socket.emit('pushSlaveConnection', { socketId: config.socket.id, slaveId: config.slaveId })

   socket.on 'blocked', (data) ->
      console.log('blocked')

   socket.on 'readyToDraw', (data) ->
      console.log('readyToDraw')

   pushAcData = (ac) ->
      return unless ac? or ac[0]? or ac[1]?
      console.log("Aceletometer imput: \n x - %s \n y - %s", ac[0], ac[1])
      myPos =
            x: ac[0]
            y: ac[1]

      socket.emit("pushAcData", {"ac":myPos.ac, "user_id": user_id})
   #      appDraw.drawSphere(myPos)

