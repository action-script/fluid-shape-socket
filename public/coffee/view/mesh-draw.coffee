MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 40
      darwLoopId: undefined
      time: 0.0
      acReduction: 30.5
      growVelcity: 0.007
      ready: false

   pushVertexPos = (data) ->
      # TODO: include it on TheMesh class
      if meshCanvas.ready
         meshCanvas.theMesh.mesh.levelVertex[3*(data.slaveId-1)] =
            meshCanvas.theMesh.mesh.triangleVertex[3*(data.slaveId-1)] +
               data.pos.y/meshCanvas.acReduction
         meshCanvas.theMesh.mesh.levelVertex[3*(data.slaveId-1)+1] =
            meshCanvas.theMesh.mesh.triangleVertex[3*(data.slaveId-1)+1] +
               data.pos.x/meshCanvas.acReduction

   draw = ->
      # clear BG as black
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

      meshCanvas.theMesh.shader.use()
      meshCanvas.theMesh.shader.setUniform( 'time', 'uniform1f', meshCanvas.time )
      # pass model to shaders
      meshCanvas.theMesh.shader.setUniform( 'modelMatrix', 'uniformMatrix4fv', meshCanvas.theMesh.modelMatrix )

      meshCanvas.camera.use()

      meshCanvas.theMesh.mesh.draw()
      return

   updateTime = ->
      meshCanvas.time += 0.001
      # increase height of level
      # TODO: Mesh function to update pos
      for i in [0..2]
         meshCanvas.theMesh.mesh.levelVertex[i*3+2] += meshCanvas.growVelcity

#      meshCanvas.camera.rotation_x = Math.sin(meshCanvas.time * 5.0)
      meshCanvas.camera.rotation_x = 30
      meshCanvas.camera.rotation_z = meshCanvas.time * 1000.0
      meshCanvas.camera.translation[2] -= meshCanvas.growVelcity

      requestAnimationFrame draw
      return

   loadResources = ->
      meshCanvas.theMesh = {}

      # shader
      meshCanvas.theMesh.shader = new Shader('mesh')
      meshCanvas.theMesh.shader.bindUniform( 'projectionMatrix', 'mprojection' )
      meshCanvas.theMesh.shader.bindUniform( 'viewMatrix', 'mview' )
      meshCanvas.theMesh.shader.bindUniform( 'modelMatrix', 'mmodel' )
      meshCanvas.theMesh.shader.bindUniform( 'time', 'wtime' )

      # reference from original triangle shape
      triangleVertex = Geometric.triangle(1)

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
         [0,-2,1.4],
         [0,0,0],
         meshCanvas.aspect
      )
      meshCanvas.camera.far_plane = 400
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
      , 800

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
