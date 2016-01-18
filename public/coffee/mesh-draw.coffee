MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 40
      darwLoopId: undefined
      time: 0.0
      acReduction: 25.5
      ready: false
      theMesh:
         triangleVertex: [ # reference of original triangle shape
            -1.0, -.5, 0.0,
            1.0, -.5, 0.0,
            0.0, 1.0, 0.0
         ]
         levelVertex: [] # modification of current level
         vertex:[] # accumulation of vertex
         index:[] # index elements

   radians = (degrees) ->
      degrees * Math.PI / 180

   getWebGLContext = (canvas) ->
      names = ['webgl', 'experimental-webgl', 'webkit-3d', 'moz-webgl']
      for name in names
        try
          return canvas.getContext(name)
        catch e
          console.log('error canvas context')

   # TODO: Init color buffer, vertex, normal, etc....
   initMeshBuffer = (mesh) ->
      # generate and bind the buffer object
      mesh.vbo = gl.createBuffer()
      gl.bindBuffer gl.ARRAY_BUFFER, mesh.vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(mesh.vertex), gl.DYNAMIC_DRAW # Dynamic access to the vertex

      # set up attrib pointer
      gl.enableVertexAttribArray meshCanvas.program.vertexPositionAttribute # Attrib location id pointer
      gl.vertexAttribPointer(
         meshCanvas.program.vertexPositionAttribute,
         3, gl.FLOAT, false, 0, 0)

      if mesh.index? && mesh.index.length > 0
         mesh.ibo = gl.createBuffer()
         gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, mesh.ibo
         gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(mesh.index), gl.STATIC_DRAW

   addLevel = ->
      l = (meshCanvas.theMesh.vertex.length - 3*3) / 3 # 3 float per vertex, 3 vertex
      # a = a.splice(0, a.length - b.length).concat(b);
      meshCanvas.theMesh.vertex = meshCanvas.theMesh.vertex.splice(0, meshCanvas.theMesh.vertex.length-meshCanvas.theMesh.levelVertex.length ).concat( meshCanvas.theMesh.levelVertex, meshCanvas.theMesh.levelVertex )
      # calculate triangle index to draw elements
      for v in [0..2]
         i = v+l
         meshCanvas.theMesh.index.push(
            i,
            l+(i+1)%3,
            i+3,

            i+3,
            l+(i+1)%3,
            l+(i+1)%3+3
         )

   initGeometry = ->
      # theMesh
      meshCanvas.theMesh.levelVertex = meshCanvas.theMesh.levelVertex.concat(meshCanvas.theMesh.triangleVertex)
      meshCanvas.theMesh.vertex = meshCanvas.theMesh.vertex.concat(meshCanvas.theMesh.triangleVertex)
      addLevel()
      initMeshBuffer(meshCanvas.theMesh)

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

   updateVertexPos = ->
      l = meshCanvas.theMesh.vertex.length - 3*3 # 3 float per vertex, 3 vertex
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.theMesh.vbo
      # buffer_type, array_offset, new_data
      gl.bufferSubData gl.ARRAY_BUFFER,
         l*4, # 3 poinrs x Vertex, 4 bytes x Float (float32 bits)
         new Float32Array(meshCanvas.theMesh.levelVertex)

   repostMeshData = ->
      ###
      for i,c in meshCanvas.theMesh.index
         console.log c+' v:'+i+' ['+meshCanvas.theMesh.vertex[i+2]+', '+meshCanvas.theMesh.vertex[i+1]+', '+meshCanvas.theMesh.vertex[i+2]+']'
      ###
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.theMesh.vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(meshCanvas.theMesh.vertex), gl.DYNAMIC_DRAW

      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, meshCanvas.theMesh.ibo
      gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(meshCanvas.theMesh.index), gl.STATIC_DRAW

   pushVertexPos = (data) ->
      if meshCanvas.ready
         meshCanvas.theMesh.levelVertex[3*(data.slaveId-1)] =
            meshCanvas.theMesh.triangleVertex[3*(data.slaveId-1)] +
               data.pos.y/meshCanvas.acReduction
         meshCanvas.theMesh.levelVertex[3*(data.slaveId-1)+1] =
            meshCanvas.theMesh.triangleVertex[3*(data.slaveId-1)+1] +
               data.pos.x/meshCanvas.acReduction

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
         [0, 0, 2],
         [0, 0, 1],
         [0, 1, 0])

      # world projection (fov, aspect, near, far)
      mat4.perspective(
         meshCanvas.camera.projectionMatrix,
         radians(70),
         meshCanvas.aspect,
         0.1, 100)

   calculateCamera = ->
      # camera view (eye, center, up)
      mat4.lookAt(
         meshCanvas.camera.viewMatrix,
         [Math.sin(meshCanvas.time)*5.5, Math.cos(meshCanvas.time)*5.5, 1.2+meshCanvas.time/2.0],
         [0, 0, meshCanvas.time/2.0],
         [0, 1, 0])

   setShaderCamera = ->
      calculateCamera()
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
      updateVertexPos()
      gl.bindBuffer gl.ARRAY_BUFFER, meshCanvas.vbo
#      gl.drawArrays(gl.TRIANGLES, 0, meshCanvas.vertex.length/3)
      gl.drawElements gl.LINE_STRIP, meshCanvas.theMesh.index.length, gl.UNSIGNED_SHORT, 0
      return

   updateTime = ->
      meshCanvas.time += 0.01
      # increase height of level
      for i in [0..2]
         meshCanvas.theMesh.levelVertex[i*3+2] = meshCanvas.time/3.0
      requestAnimationFrame draw
      return

   loadResources = ->
      createShaderProgram()
      initGeometry()
      createCamera()
      # TODO: remove hack
      setInterval () ->
         addLevel()
         repostMeshData()
      , 300
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

      meshCanvas.ready = true
      # if the resources are loaded and running
      setUpRender()

   return {
      init,
      pushVertexPos
   }
