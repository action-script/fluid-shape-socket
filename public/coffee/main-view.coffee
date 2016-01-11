$().ready ->
   noise = new Noise(Math.random())
   window.config.socket.id = null
   slaves = []

   loadingCanvas =
      canvas: $ '<canvas/>', {'id':'loadingCanvas'}
      drawInterval: 1000/25
      elements:
         nodes: []
         node:
            r: 5
            activatedColor: '#e7edf3'
            deactivatedColor: '#b6babe'
            noiseFactor: 0.008
            noiseExponent: 0.9
         mainCircle:
            r: 0
            x: 0
            y: 0
            activatedColor: '#e7edf3'
            deactivatedColor: '#b6babe'

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
      ctx.strokeStyle = loadingCanvas.elements.mainCircle.deactivatedColor
      ctx.beginPath()
      ctx.arc(
         loadingCanvas.elements.mainCircle.x,
         loadingCanvas.elements.mainCircle.y,
         loadingCanvas.elements.mainCircle.r,
         0,2*Math.PI)
      ctx.stroke()
      ctx.closePath()

      # draw nodes
      for i in [0..2]
         ctx.lineWidth = 1
         ctx.strokeStyle = loadingCanvas.elements.nodes[i].deactivatedColor
         ctx.beginPath()
         ctx.arc(
            loadingCanvas.elements.nodes[i].x,
            loadingCanvas.elements.nodes[i].y,
            loadingCanvas.elements.nodes[i].r,
            0,2*Math.PI)
         ctx.stroke()
         ctx.closePath()
         loadingCanvas.elements.nodes[i].x += -.5 * noise.simplex2(loadingCanvas.elements.nodes[i].noise, 0) * loadingCanvas.elements.nodes[i].noiseExponent
         loadingCanvas.elements.nodes[i].y += -.5 * noise.simplex2(loadingCanvas.elements.nodes[i].noise, 300) * loadingCanvas.elements.nodes[i].noiseExponent
         loadingCanvas.elements.nodes[i].noise += loadingCanvas.elements.nodes[i].noiseFactor

   # draw lines
      oldpos =
         x: 0
         y: canvas.height/2.5
      ctx.setLineDash([5, 10])
      for i in [0..2]
         ctx.beginPath()
         ctx.moveTo(oldpos.x,oldpos.y)
         ctx.lineTo(loadingCanvas.elements.nodes[i].x,loadingCanvas.elements.nodes[i].y)
         ctx.stroke()
         ctx.closePath()
         ctx.setLineDash([])

         oldpos.x = loadingCanvas.elements.nodes[i].x
         oldpos.y = loadingCanvas.elements.nodes[i].y
      
      ctx.setLineDash([5, 10])
      ctx.beginPath()
      ctx.moveTo(oldpos.x,oldpos.y)
      ctx.lineTo(canvas.width, canvas.height/2.5)
      ctx.stroke()
      ctx.closePath()
      ctx.setLineDash([])

      # gradient mask
      grd = ctx.createRadialGradient(
         canvas.width/2,
         canvas.height/2,
         canvas.width/3,
         canvas.width/2,
         canvas.height/2,
         canvas.width/2
      )
      grd.addColorStop(0, 'transparent')
      grd.addColorStop(1, '#000000')
      ctx.fillStyle = grd
      ctx.fillRect(0, 0, canvas.width, canvas.height)

   initLoadingCanvas = ->
      $('body').empty().prepend(loadingCanvas.canvas)

      canvas = loadingCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      ctx = canvas.getContext("2d")

      loadingCanvas.elements.mainCircle.x = canvas.width/2
      loadingCanvas.elements.mainCircle.y = canvas.height/2
      loadingCanvas.elements.mainCircle.r = canvas.height/1.7

      for i in [0..2]
         loadingCanvas.elements.nodes.push $.extend(true, {}, loadingCanvas.elements.node)
         loadingCanvas.elements.nodes[i].y = Math.random() * canvas.height / 4 + canvas.height / 3
         loadingCanvas.elements.nodes[i].x = (canvas.width - canvas.width/4)/3 * i + canvas.width/4
         loadingCanvas.elements.nodes[i].noise = Math.random() * 9999

      drawIntervall = setInterval () ->
         ctx.clearRect(0,0,canvas.width,canvas.height)
         drawLoadingCanvas(canvas, ctx)
      , loadingCanvas.drawInterval


   # App
   initLoadingCanvas()
