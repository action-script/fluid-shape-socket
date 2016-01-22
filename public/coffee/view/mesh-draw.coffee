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
      if meshCanvas.ready
         meshCanvas.theMesh.mesh.pushVertexPos(
            data.slaveId-1,
            data.pos.x/meshCanvas.acReduction,
            data.pos.y/meshCanvas.acReduction
         )
      ###
         meshCanvas.theMesh.mesh.levelVertex[3*(data.slaveId-1)] =
            meshCanvas.theMesh.mesh.triangleVertex[3*(data.slaveId-1)] +
               data.pos.y/meshCanvas.acReduction
         meshCanvas.theMesh.mesh.levelVertex[3*(data.slaveId-1)+1] =
            meshCanvas.theMesh.mesh.triangleVertex[3*(data.slaveId-1)+1] +
               data.pos.x/meshCanvas.acReduction
      ###

   draw = ->
      # clear BG as black
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

      meshCanvas.shader.use()
      meshCanvas.camera.use()

      meshCanvas.shader.setUniform( 'time', 'uniform1f', meshCanvas.time )

      # draw themesh
      meshCanvas.shader.setUniform( 'modelMatrix', 'uniformMatrix4fv', meshCanvas.theMesh.modelMatrix )
      meshCanvas.theMesh.mesh.draw()

      # draw lid
      meshCanvas.shader.setUniform( 'modelMatrix', 'uniformMatrix4fv', meshCanvas.lid.modelMatrix )
      meshCanvas.lid.mesh.draw()

      return

   updateTime = ->
      meshCanvas.time += 0.001
      # increase height of level
      for i in [0..2]
         meshCanvas.theMesh.mesh.levelVertex[i*3+2] += meshCanvas.growVelcity
         meshCanvas.lid.mesh.pushVertexPos(
            i,
            meshCanvas.theMesh.mesh.levelVertex[i*3+0],
            meshCanvas.theMesh.mesh.levelVertex[i*3+1],
            meshCanvas.theMesh.mesh.levelVertex[i*3+2]
         )

      meshCanvas.camera.rotation_x = 10 +  Math.sin(meshCanvas.time * 10.0) * 35
      #meshCanvas.camera.rotation_x = Math.min(Math.max(Math.sin(meshCanvas.time * 9.0), -0.5), 1)
      meshCanvas.camera.rotation_z = meshCanvas.time * 1000.0
      meshCanvas.camera.translation[2] -= meshCanvas.growVelcity

      requestAnimationFrame draw
      return

   loadResources = ->
      # - shader -
      meshCanvas.shader = new Shader('mesh')
      meshCanvas.shader.bindUniform( 'projectionMatrix', 'mprojection' )
      meshCanvas.shader.bindUniform( 'viewMatrix', 'mview' )
      meshCanvas.shader.bindUniform( 'modelMatrix', 'mmodel' )
      meshCanvas.shader.bindUniform( 'time', 'wtime' )

      # - themesh -
      meshCanvas.theMesh = {}
      # reference from original triangle shape
      triangleVertex = Geometric.triangle(1)

      # gl mesh
      meshCanvas.theMesh.mesh = new TheMesh( meshCanvas.shader )
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

      # - lid -
      meshCanvas.lid = {}
      # gl mesh
      meshCanvas.lid.mesh = new Mesh( meshCanvas.shader )
      meshCanvas.lid.mesh.initBuffer({
         id: 0
         data: triangleVertex
         attribPointerId: meshCanvas.shader.vertexPositionAttribute
         attribPointerSize: 3
         usage: gl.DYNAMIC_DRAW
      })

      # default position of the mesh
      meshCanvas.lid.modelMatrix = mat4.create()

      mat4.identity(meshCanvas.lid.modelMatrix) # set to identity
      translation = vec3.create()
      vec3.set(translation, 0, 0, 0)
      mat4.translate(
         meshCanvas.lid.modelMatrix,
         meshCanvas.lid.modelMatrix,
         translation)

      # - camera -
      meshCanvas.camera = new Camera(
         meshCanvas.shader,
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
