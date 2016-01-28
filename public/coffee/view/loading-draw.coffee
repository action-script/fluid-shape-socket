LoadingCanvas = do ->
   noise = new Noise(Math.random())
   drawLoopLoadingCanvas = undefined
   loadingCanvas =
      canvas: $ '<canvas/>', {'id':'loadingCanvas'}
      drawInterval: 1000/25
      elements:
         nodes: []
         node:
            r: 5
            activatedColor: '#ebf0f5'
            deactivatedColor: '#8e9194'
            noiseFactor: 0.008
            noiseExponent: 0.9
         mainCircle:
            r: 0
            x: 0
            y: 0
            color: '#b6babe'
            activatedColor: '#e7edf3'
            deactivatedColor: '#b6babe'

   displayIndicator = ->
      $('.slaveIndicator').show()

   activateIndicator = (number) ->
      $('.slaveIndicator').children('.slave:nth-child(' +number+')').addClass('activated')

   removeIndicator = ->
      $('.slaveIndicator').hide()

   crazyAnim = (data, time) ->
      start = new Date
      data.noiseExponent = 30.5
      data.noiseFactor = 0.2

      id = setInterval () =>
         timePassed = new Date - start
         progress = timePassed / time
         progress = 1 if progress > 1

         if progress == 1
            data.noiseExponent = loadingCanvas.elements.node.noiseExponent
            data.noiseFactor = loadingCanvas.elements.node.noiseFactor
         else
            data.noiseExponent -= 0.95
            data.noiseFactor -= 0.001
         clearInterval(id) if (progress == 1)
      , loadingCanvas.drawInterval

   drawbackGround = (canvas, ctx) ->
      # BG gradient
      grd = ctx.createRadialGradient(
         canvas.width/2,
         canvas.height/2,
         10,
         canvas.width/2,
         canvas.height/2,
         canvas.width/1.5
      )
      if loadingCanvas.elements.mainCircle.connected
         grd.addColorStop(0, '#3c484b')
      else
         grd.addColorStop(0, '#1c2426')
      grd.addColorStop(1, '#000000')

      # Fill BG
      ctx.fillStyle = grd
      ctx.fillRect(0, 0, canvas.width, canvas.height)

   drawMainCircle = (canvas, ctx) ->
      # draw main circre    
      ctx.lineWidth = 1
      ctx.strokeStyle = loadingCanvas.elements.mainCircle.color
      ctx.beginPath()
      ctx.arc(
         loadingCanvas.elements.mainCircle.x,
         loadingCanvas.elements.mainCircle.y,
         loadingCanvas.elements.mainCircle.r,
         0,2*Math.PI)
      ctx.stroke()
      ctx.closePath()
  
   drawNodes = (canvas, ctx) ->
      # draw nodes
      for i in [0..2]
         if loadingCanvas.elements.nodes[i].connected
            ctx.strokeStyle = loadingCanvas.elements.nodes[i].color
            ctx.beginPath()
            ctx.arc(
               loadingCanvas.elements.nodes[i].x,
               loadingCanvas.elements.nodes[i].y,
               loadingCanvas.elements.nodes[i].r*5,
               0,2*Math.PI)
            ctx.stroke()
            ctx.closePath()

         ctx.strokeStyle = loadingCanvas.elements.nodes[i].color
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

   drawLines = (canvas, ctx) ->
      # draw lines
      ctx.lineWidth = 1
      ctx.strokeStyle = loadingCanvas.elements.node.deactivatedColor
      oldpos =
         x: 0
         y: canvas.height/2.5
      ctx.setLineDash([5, 10])
      for i in [0..2]
         console.log()
         ctx.beginPath()
         ctx.moveTo(oldpos.x,oldpos.y)
         ctx.lineTo(
            loadingCanvas.elements.nodes[i].x,
            loadingCanvas.elements.nodes[i].y
         )
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

   drawMask = (canvas, ctx) ->
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
 
   draw = (canvas, ctx) ->
      drawbackGround(canvas, ctx)

      drawMainCircle(canvas, ctx)

      drawNodes(canvas, ctx)

      drawLines(canvas, ctx)

      drawMask(canvas, ctx)

   initGeometries = (canvas) ->
      loadingCanvas.elements.mainCircle.x = canvas.width/2
      loadingCanvas.elements.mainCircle.y = canvas.height/2
      loadingCanvas.elements.mainCircle.r = canvas.height/1.7

      for i in [0..2]
         loadingCanvas.elements.nodes.push $.extend(true, {}, loadingCanvas.elements.node)
         loadingCanvas.elements.nodes[i].y = Math.random() * canvas.height / 4 + canvas.height / 3
         loadingCanvas.elements.nodes[i].x = (canvas.width - canvas.width/4)/3 * i + canvas.width/4
         loadingCanvas.elements.nodes[i].noise = Math.random() * 9999
         loadingCanvas.elements.nodes[i].connected = false
         loadingCanvas.elements.nodes[i].color = loadingCanvas.elements.node.deactivatedColor

   init = ->
      $('body').prepend(loadingCanvas.canvas)

      canvas = loadingCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      ctx = canvas.getContext("2d")

      initGeometries(canvas)
      displayIndicator()

      drawLoopLoadingCanvas = setInterval () ->
         ctx.clearRect(0,0,canvas.width,canvas.height)
         draw(canvas, ctx)
      , loadingCanvas.drawInterval

   stop = ->
      clearInterval(drawLoopLoadingCanvas)
      $(loadingCanvas.canvas).remove()
      removeIndicator()

   activateSlave = (data) ->
      activateIndicator(data.slaveId)
      if data.slaveId < 4
         loadingCanvas.elements.nodes[data.slaveId-1].connected = true
         loadingCanvas.elements.nodes[data.slaveId-1].color = loadingCanvas.elements.node.activatedColor
         crazyAnim(loadingCanvas.elements.nodes[data.slaveId-1], 600)
      else
         if data.slaveId == 4
            loadingCanvas.elements.mainCircle.connected = true
            loadingCanvas.elements.mainCircle.color = loadingCanvas.elements.mainCircle.activatedColor


   return {
      init
      activateSlave
      stop
   }
