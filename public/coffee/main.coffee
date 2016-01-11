$().ready ->
   window.config.socket.id = null
   
   $('.container').hide()

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
      $('#vertex').show()
      $('#vertex').append('<h2>Number: ' + config.slaveId + '</h2>')

   socket.on 'blocked', (data) ->
      console.log('blocked')
      $('#block').show()

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

   move3D = (ac) ->
      $('#wrapper')[0].style.WebkitTransform =
         'scale3d(0.5, 0.5, 0.5) ' +
         'rotateX(' + ac[0] + 'deg) ' +
         'rotateY(' + 0 + 'deg) ' +
         'rotateZ(' + ac[1] + 'deg) '


   tilt = _.throttle(move3D, 1)

   # acelerometer sensor
   if window.DeviceOrientationEvent
      window.addEventListener "deviceorientation", ->
         tilt([event.beta, event.gamma])
      , true
   else
      if  window.DeviceMotionEvent
         window.addEventListener 'devicemotion',  ->
            tilt([event.acceleration.x * 2, event.acceleration.y * 2])
         , true
      else
         window.addEventListener "MozOrientation", ->
            tilt([orientation.x * 50, orientation.y * 50])
         , true


