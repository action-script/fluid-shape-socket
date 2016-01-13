MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 1000/25
      nodes: []
      vertex: [
         0.0, 0.0, 0.0,
         1.0, 0.0, 0.0,
         1.0, 1.0, 0.0
      ]


   getWebGLContext = (canvas) ->
      names = ["webgl", "experimental-webgl", "webkit-3d", "moz-webgl"]
      for name in names.length
        try
          return canvas.getContext(name)
        catch e
          console.log()

   initMeshBuffers = ->
      meshCanvas.vbo = gl.createBuffer()
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(meshCanvas.vertex), gl.DYNAMIC_DRAW # Dynamic access to the vertex


   init = ->
      $('body').prepend(meshCanvas.canvas)

      canvas = meshCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      gl = getWebGLContext(canvas)
      console.log('webgl not working') if not gl

      ###
      initShaders()
      initPrimitives()
      initRendering()
      initHandlers()
      initTextures()
      ###
      # requestAnimationFrame(drawScene);

   draw = ->


   return {
      init
   }
