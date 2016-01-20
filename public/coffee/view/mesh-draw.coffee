MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 40
      darwLoopId: undefined
      time: 0.0
      acReduction: 30.5
      ready: false

   pushVertexPos = (data) ->
      if meshCanvas.ready
         meshCanvas.theMesh.levelVertex[3*(data.slaveId-1)] =
            meshCanvas.theMesh.triangleVertex[3*(data.slaveId-1)] +
               data.pos.y/meshCanvas.acReduction
         meshCanvas.theMesh.levelVertex[3*(data.slaveId-1)+1] =
            meshCanvas.theMesh.triangleVertex[3*(data.slaveId-1)+1] +
               data.pos.x/meshCanvas.acReduction

   draw = ->
      # clear BG as black
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
      # meshCanvas.theMesh.shader.use()
      meshCanvas.camera.use()

      # pass model to shaders
      gl.uniformMatrix4fv(
         meshCanvas.theMesh.shader.modelMatrixUniform,
         false,
         meshCanvas.theMesh.modelMatrix)

      meshCanvas.theMesh.mesh.draw()
      return

   updateTime = ->
      meshCanvas.time += 0.01
      # increase height of level
      # TODO: Mesh function to update pos
      for i in [0..2]
         meshCanvas.theMesh.mesh.levelVertex[i*3+2] = meshCanvas.time/3.0

      meshCanvas.camera.offset_position = [0, 0, 0.01/3.0]
      meshCanvas.camera.offset_center =   [0, 0, 0.01/3.0]

      requestAnimationFrame draw
      return

   loadResources = ->
      meshCanvas.theMesh = {}

      # shader
      meshCanvas.theMesh.shader = new Shader('mesh')

      # reference of original triangle shape
      triangleVertex = [
         -1.0, -.5, 0.0,
         1.0, -.5, 0.0,
         0.0, 1.0, 0.0
      ]
      # gl mesh
      meshCanvas.theMesh.mesh = new TheMesh( meshCanvas.theMesh.shader )
      meshCanvas.theMesh.mesh.setUp( triangleVertex )

      # default position of the mesh
      meshCanvas.theMesh.modelMatrix = mat4.create()

      mat4.identity(meshCanvas.theMesh.modelMatrix) # set to identity
      translation = vec3.create()
      vec3.set(translation, 0, 0, 0)
      mat4.translate(
         meshCanvas.theMesh.modelMatrix,
         meshCanvas.theMesh.modelMatrix,
         translation)

      # camera
      meshCanvas.camera = new Camera(
         meshCanvas.theMesh.shader,
         [0,2,1.5],
         [0,0,-0.2],
         meshCanvas.aspect
      )
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
      setInterval () ->
         meshCanvas.theMesh.mesh.addLevel()
         meshCanvas.theMesh.mesh.repostMeshData()
      , 2000

      meshCanvas.ready = true

   init = ->
      $('body').prepend(meshCanvas.canvas)

      canvas = meshCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      meshCanvas.aspect = window.innerWidth / window.innerHeight

      try
         gl = WebGL.getInstance(canvas)

         loadResources()
      catch e
         return console.log 'Error loading sources\n', e

      # if the resources are loaded and running
      setUpRender()

   return {
      init,
      pushVertexPos
   }
