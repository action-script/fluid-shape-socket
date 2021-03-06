$().ready ->
   window.config = {}
   window.config.socket = {}
   window.config.status = undefined
   cameraPos = {x: 0, y:0}
   acelerometer = {x: 0, y:0}

   # socket app
   socket = io({
      reconnection: false
   })
   socket.on 'myping', (data) ->
      console.log('ping', data)
      window.config.socket.id = data.socketId
      socket.emit('mypong', { clientType: 'slave' })

   socket.on 'confirmConnection', (data) ->
      console.log('connection confirmed', data)
      window.config.slaveId = data.slaveId
      socket.emit('pushSlaveConnection', { socketId: config.socket.id, slaveId: config.slaveId })
      config.status = 'vertex' if config.slaveId < 4
      config.status = 'camera' if config.slaveId == 4

      setInterval(calculateCameraPos, 50) if config.status == 'camera'

      $('#block').hide()
      $('#vertex').hide()
      $('#camera').hide()
      $('#' + config.status).show()

   socket.on 'blocked', (data) ->
      console.log('blocked')
      $('#vertex').hide()
      $('#camera').hide()
      $('#block').show()

   socket.on 'readyToDraw', (data) ->
      console.log('readyToDraw')

   calculateCameraPos = ->
      cameraPos.x += acelerometer.x/6.0 if acelerometer.x > 2 or acelerometer.x < -2
      cameraPos.y += acelerometer.y/6.0 if acelerometer.y > 3 or acelerometer.y < -3
      cameraPos.x = Math.min( Math.max( cameraPos.x, -22), 55)
      move3D(cameraPos)

   pushAcPosData = (ac) ->
      acelerometer.x = ac[0]
      acelerometer.y = ac[1]
      move3D(acelerometer) if config.status == 'vertex'

      if config.status?
         socket.emit 'pushPosition',
            'slaveId': window.config.slaveId,
            'pos':
               'x': acelerometer.x,
               'y': acelerometer.y

   move3D = (ac) ->
      if config.status == 'vertex'
         $('#wrapper_v')[0].style.WebkitTransform =
            'scale3d(0.5, 0.5, 0.5) ' +
            'rotateX(' + ( - ac.x - 35) + 'deg) ' +
            'rotateY(' + (ac.y + 135) + 'deg) ' +
            'rotateZ(' + 0 + 'deg)'

      if config.status == 'camera'
         $('#wrapper_c')[0].style.WebkitTransform =
            'scale3d(0.4, 0.4, 0.4) ' +
            'rotateX(' + ( - ac.x - 110) + 'deg) ' +
            'rotateY(' + 0 + 'deg) ' +
            'rotateZ(' + ( ac.y + 45) + 'deg)'

   tilt = _.throttle(pushAcPosData, 10)

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


