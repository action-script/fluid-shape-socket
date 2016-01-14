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
      names = ['webgl', 'experimental-webgl', 'webkit-3d', 'moz-webgl']
      for name in names
        try
          return canvas.getContext(name)
        catch e
          console.log()

   # TODO: Init color buffer, vertex, normal, etc....
   initMeshBuffers = ->
      # generate and bind the buffer object
      meshCanvas.vbo = gl.createBuffer()
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(meshCanvas.vertex), gl.DYNAMIC_DRAW # Dynamic access to the vertex

      # set up attrib pointer
      gl.enableVertexAttribArray meshCanvas.program.vertexPositionAttribute # Attrib location id pointer
      gl.vertexAttribPointer meshCanvas.program.vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0

   checkShaderError = (object, program = false) ->
      if program and gl.isProgram object
            success = gl.getProgramParameter object, gl.LINK_STATUS
            throw 'Linking program error' + gl.getProgramInfoLog object unless success
      else if gl.isShader object
         success = gl.getShaderParameter object, gl.COMPILE_STATUS
         throw 'could not compile shader:' + gl.getShaderInfoLog object unless success
      else
         throw 'Not shader or program'

   compileShader = (shaderSource, shaderType) ->
      # create the shader object
      shader = gl.createShader shaderType
 
      # set the shader source code
      gl.shaderSource shader, shaderSource
 
      # compile the shader
      gl.compileShader shader
 
      # check if it compiled
      checkShaderError(shader)
      return shader
   
   createShaderFromScript = (scriptId) ->
      shaderSource = document.getElementById scriptId
      throw ('Error: scipt not found' + scriptid) unless shaderSource

      # detect shaderType by scriptTag
      shaderType = gl.VERTEX_SHADER if shaderSource.type == 'x-shader/x-vertex'
      shaderType = gl.FRAGMENT_SHADER if shaderSource.type == 'x-shader/x-fragment'
      throw('Error: shader type not set') unless shaderType

      compileShader(shaderSource.text, shaderType)

   createShaderProgram = ->
      # create shader program
      meshCanvas.program =
         shaderProgram: gl.createProgram()
         vertexPositionAttribute: undefined
         colorPositionAttribute: undefined
         normalPositionAttribute: undefined

      # load and compile shaders
      vertexShader = createShaderFromScript('meshVertexShader')
      fragmentShader = createShaderFromScript('meshFragmentShader')

      # attach shaders to program
      gl.attachShader meshCanvas.program.shaderProgram, vertexShader
      gl.attachShader meshCanvas.program.shaderProgram, fragmentShader

      # link the program
      gl.linkProgram meshCanvas.program.shaderProgram

      # check if it linked
      checkShaderError(meshCanvas.program.shaderProgram, true)

      # bind the attribute locations
      meshCanvas.program.vertexPositionAttribute = gl.getAttribLocation meshCanvas.program.shaderProgram, 'vposition'
      throw ('Error: attribute not found') if meshCanvas.program.vertexPositionAttribute < 0

   draw = ->
      gl.useProgram meshCanvas.program.shaderProgram
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
      gl.drawArrays(gl.TRIANGLES, 0, meshCanvas.vertex.length/3)
      return

   loadResources = ->
      createShaderProgram()
      initMeshBuffers()

      ###
      initShaders()
      initPrimitives()
      initRendering()
      initHandlers()
      initTextures()
      ###
      # requestAnimationFrame(drawScene);
      return

   init = ->
      $('body').prepend(meshCanvas.canvas)

      canvas = meshCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      gl = getWebGLContext(canvas)
      console.log('webgl not working') unless gl

      try
         loadResources()
      catch e
         return console.log 'Error loading sources\n', e
         

      draw()
   
   return {
      init
   }
