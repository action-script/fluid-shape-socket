$().ready ->
   window.config.socket.id = null
   slaves = []

   # socket app
   socket = io(config.server.ip+':'+config.server.port)
   socket.on 'ping', (data) ->
      console.log('ping', data)
      window.config.socket.id = data.socketId
      socket.emit('pong', { clientType: 'view' })
  
   socket.on 'new Slave', (data) ->
      console.log('I got a new slave', data)
      saveSlave(data)
   
   saveSlave = (data) ->
      slaves.push(data)
      socket.emit('readyToDraw') if slaves.length >= config.socket.maxConnections


   # Loading Canvas
   drawLoadingCanvas = (canvas, ctx) ->
      # BG gradient
      grd = ctx.createRadialGradient(
         canvas.width/2,
         canvas.height/2,
         10,
         canvas.width/2,
         canvas.height/2,
         canvas.width/1.5
      )
      grd.addColorStop(0, '#1c2426')
      grd.addColorStop(1, '#000000')

      # Fill BG
      ctx.fillStyle = grd
      ctx.fillRect(0, 0, canvas.width, canvas.height)

      # draw main circre
      ctx.lineWidth = 1
      ctx.strokeStyle = "#e7edf3"
      ctx.beginPath()
      ctx.arc(canvas.width/2, canvas.height/2, canvas.height/1.7,0,2*Math.PI)
      ctx.stroke()

   initLoadingCanvas = ->
      loadingCanvas = $ '<canvas/>', {'id':'loadingCanvas'}
      $('body').empty().prepend(loadingCanvas)

      canvas = $('#loadingCanvas')[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      ctx = canvas.getContext("2d")

      drawIntervall = setInterval () ->
         ctx.clearRect(0,0,canvas.width,canvas.height)
         drawLoadingCanvas(canvas, ctx)
      , 1000/30

      ###
      ctx.setLineDash([5, 10])

      ctx.beginPath()
      ctx.moveTo(0,50)
      ctx.lineTo(400, 100)
      ctx.stroke()
      ###

   initLoadingCanvas()
