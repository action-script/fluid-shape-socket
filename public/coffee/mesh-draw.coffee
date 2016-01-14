MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 40
      darwLoopId: undefined
      time: 0.0
      nodes: []
      vertex: [
         -1.0, .5, 0.0,
         0.0, -1.0, 0.0,
         1.0, .5, 0.0
      ]

   radians = (degrees) ->
      degrees * Math.PI / 180

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
      gl.vertexAttribPointer(
         meshCanvas.program.vertexPositionAttribute,
         3, gl.FLOAT, false, 0, 0)

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
      meshCanvas.program.vertexPositionAttribute = gl.getAttribLocation(
         meshCanvas.program.shaderProgram,
         'vposition')
      throw ('Error: attribute not found') if meshCanvas.program.vertexPositionAttribute < 0

      # TODO: generic bind and check
      # bind uniform locations
      meshCanvas.program.projectionMatrixUniform = gl.getUniformLocation(
         meshCanvas.program.shaderProgram,
         'mprojection')
      throw ('Could not bind uniform mprojection') unless meshCanvas.program.projectionMatrixUniform?

      meshCanvas.program.viewMatrixUniform = gl.getUniformLocation(
         meshCanvas.program.shaderProgram,
         'mview')
      throw ('Could not bind uniform mview') unless meshCanvas.program.viewMatrixUniform?

      meshCanvas.program.modelMatrixUniform = gl.getUniformLocation(
         meshCanvas.program.shaderProgram,
         'mmodel')
      throw ('Could not bind uniform mmodel') unless meshCanvas.program.modelMatrixUniform?

   updateVertexPos = (data) ->
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
      vertices = [data.pos.x, data.pos.y, 0]
      # buffer_type, array_offset, new_data
      gl.bufferSubData gl.ARRAY_BUFFER, data.slaveId*8, new Float32Array(vertices)

   createCamera = ->
      # compute camera matrix using look at
      meshCanvas.camera =
         modelMatrix: mat4.create()
         viewMatrix: mat4.create()
         projectionMatrix: mat4.create()

      # default position of the mesh
      mat4.identity(meshCanvas.camera.modelMatrix) # set to identity
      translation = vec3.create()
      vec3.set(translation, 0, 0, 0)
      mat4.translate(
         meshCanvas.camera.modelMatrix,
         meshCanvas.camera.modelMatrix,
         translation)

      # camera view (eye, center, up)
      mat4.lookAt(
         meshCanvas.camera.viewMatrix,
         [0, 0, -2],
         [0, 0, 0],
         [0, 1, 0])

      # world projection (fov, aspect, near, far)
      mat4.perspective(
         meshCanvas.camera.projectionMatrix,
         radians(70),
         meshCanvas.aspect,
         0.1, 100)

   setShaderCamera = ->
      gl.uniformMatrix4fv(
         meshCanvas.program.projectionMatrixUniform,
         false,
         meshCanvas.camera.projectionMatrix)

      gl.uniformMatrix4fv(
         meshCanvas.program.viewMatrixUniform,
         false,
         meshCanvas.camera.viewMatrix)

      gl.uniformMatrix4fv(
         meshCanvas.program.modelMatrixUniform,
         false,
         meshCanvas.camera.modelMatrix)

   draw = ->
      # clear BG as black
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
      gl.useProgram meshCanvas.program.shaderProgram
      setShaderCamera()
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
      gl.drawArrays(gl.TRIANGLES, 0, meshCanvas.vertex.length/3)
      return

   updateTime = ->
      meshCanvas.time += 0.01
      requestAnimationFrame draw
      return

   loadResources = ->
      createShaderProgram()
      initMeshBuffers()
      createCamera()
      return

   setUpRender = ->
      gl.clearColor 0.0, 0.0, 0.0, 1.0
      # enable alpha
      gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA
      # near things obscure far things
      gl.depthFunc gl.LEQUAL

      # 3D z geometry
      gl.enable gl.DEPTH_TEST
      # setShaderLight();

      meshCanvas.drawLoopId = setInterval(updateTime, meshCanvas.drawInterval)

   init = ->
      $('body').prepend(meshCanvas.canvas)

      canvas = meshCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      meshCanvas.aspect = window.innerWidth / window.innerHeight

      gl = getWebGLContext(canvas)
      console.log('webgl not working') unless gl

      try
         loadResources()
      catch e
         return console.log 'Error loading sources\n', e

      # if the resources are loaded and running
      setUpRender()

   return {
      init,
      updateVertexPos
   }
