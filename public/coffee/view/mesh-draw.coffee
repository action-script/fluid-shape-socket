MeshCanvas = do ->
   gl = undefined
   meshCanvas =
      canvas: $ '<canvas/>', {'id':'meshCanvas'}
      drawInterval: 16
      resolutionScale: 2
      darwLoopId: undefined
      time: 0.0
      acReduction: 100.5
      acReductionCamera: 20.0
      growVelcity: 0.01
      growSize: 0.1
      ready: false
      cameraMove:
         x: 0
         y: 0

   pushVertexPos = (data) ->
      if meshCanvas.ready
         meshCanvas.theMesh.mesh.pushVertexPos(
            data.slaveId-1,
            data.pos.x/meshCanvas.acReduction,
            data.pos.y/meshCanvas.acReduction
         )

   moveCamera = (data) ->
      meshCanvas.cameraMove.y = data.pos.y/meshCanvas.acReductionCamera
      meshCanvas.cameraMove.x = data.pos.x/meshCanvas.acReductionCamera

   drawAsset = (asset) ->
      asset.program.useCamera(meshCanvas.camera)
      asset.program.setUniform( 'modelMatrix', 'uniformMatrix4fv',
         asset.modelMatrix, false )

      if asset.program.normalMatrixUniform?
         ###
         normalMatrix = mat4.invert( [],
            mat4.multiply( [],
               asset.modelMatrix,
               meshCanvas.camera.matrix.view
            )
         )
         mat4.transpose(normalMatrix,normalMatrix)
         ###
         normalMatrix = asset.modelMatrix # lights calculated in world coords
         asset.program.setUniform( 'normalMatrix', 'uniformMatrix4fv',
            normalMatrix, false )

      asset.mesh.draw()

   drawLight = (program) ->
      program.setUniform( 'lightColor', 'uniform3fv', [0.8, 0.73, 0.71] )
      program.setUniform( 'lightDirection', 'uniform3fv', [0.0,0, -1] )
      program.setUniform( 'lightAmbientIntensity', 'uniform1f', 0.17 )

   drawScene = ->
      # clear Color buffer and Depth buffer
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

      meshCanvas.mainShader.use()
      meshCanvas.mainShader.setUniform( 'time', 'uniform1f', meshCanvas.time )
      drawLight( meshCanvas.mainShader )

      drawAsset( meshCanvas.theMesh )
      drawAsset( meshCanvas.lid )

      # normals visor
      if meshCanvas.normalsVisor.show
         meshCanvas.normalsVisor.program.use()
         meshCanvas.normalsVisor.program.setUniform( 'color', 'uniform3fv', [0.0,0.0,1.0] )
         meshCanvas.normalsVisor.program.setUniform( 'billboard', 'uniform1f', 0.0 )
         drawAsset( meshCanvas.normalsVisor )

      return

   drawEffect = (effect, source) ->
      # clear Color buffer and Depth buffer
      gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

      meshCanvas.effects[effect].use()

      # use the last framebuffer rendered color image texture
      gl.bindTexture gl.TEXTURE_2D, source.id

      # draw texture on screen
      meshCanvas.effects.square.draw()

      # unbind
      gl.bindTexture gl.TEXTURE_2D, null

   drawCircles = ->
      meshCanvas.circle.program.use()
      meshCanvas.circle.program.useCamera(meshCanvas.camera)
      meshCanvas.circle.program.setUniform( 'color', 'uniform3fv', [1.0,1.0,1.0] )
      meshCanvas.circle.program.setUniform( 'billboard', 'uniform1f', 1.0 )

      translation = vec3.create()
      for i in [0..2]
         # translate circles into vertex positions
         mat4.identity(meshCanvas.circle.modelMatrix)
         vec3.set(translation,
            meshCanvas.theMesh.mesh.levelVertex[i*3],
            meshCanvas.theMesh.mesh.levelVertex[i*3+1],
            meshCanvas.theMesh.mesh.levelVertex[i*3+2]
         )
         mat4.translate(
            meshCanvas.circle.modelMatrix,
            meshCanvas.circle.modelMatrix,
            translation
         )

         meshCanvas.circle.program.setUniform(
            'modelMatrix',
            'uniformMatrix4fv',
            meshCanvas.circle.modelMatrix,
            false
         )

         meshCanvas.circle.mesh.draw(gl.LINE_LOOP)

   draw = ->
      meshCanvas.stats.begin()

      # draw normal scene
      gl.enable gl.DEPTH_TEST
      meshCanvas.fbo.use()
      gl.viewport(
         0, 0,
         meshCanvas.width * meshCanvas.resolutionScale,
         meshCanvas.height * meshCanvas.resolutionScale
      )
      drawScene()
      meshCanvas.fbo.stop()
      gl.disable gl.DEPTH_TEST

      # draw effects
      gl.viewport(0, 0, meshCanvas.width, meshCanvas.height)
      #drawEffect('colorCorrection', meshCanvas.sceneColor)
      drawEffect('normal', meshCanvas.sceneColor)

      # draw vertex circle indicators
      drawCircles()

      meshCanvas.stats.end()
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
      # accumulate camera rotation
      meshCanvas.camera.rotation_z -= meshCanvas.cameraMove.y
      meshCanvas.camera.rotation_x -= meshCanvas.cameraMove.x
      meshCanvas.camera.rotation_x =
         Math.min( Math.max( meshCanvas.camera.rotation_x, -35), 90)

      meshCanvas.camera.translation[2] += meshCanvas.growVelcity

      requestAnimationFrame draw
      return

   loadResources = ->
      # - framebuffer -
      meshCanvas.sceneColor =
         FBO.genTextureImage( meshCanvas.width, meshCanvas.height, meshCanvas.resolutionScale )
      meshCanvas.sceneDepth =
         FBO.genRenderBufferImage( meshCanvas.width, meshCanvas.height, meshCanvas.resolutionScale )

      meshCanvas.fbo = new FBO()
      meshCanvas.fbo.attachColor( meshCanvas.sceneColor )
      meshCanvas.fbo.attachDepth( meshCanvas.sceneDepth )
      meshCanvas.fbo.checkFboSatus()

      # - shader -
      meshCanvas.mainShader = new Shader('mesh')
      meshCanvas.mainShader.bindUniform( 'projectionMatrix', 'mprojection' )
      meshCanvas.mainShader.bindUniform( 'viewMatrix', 'mview' )
      meshCanvas.mainShader.bindUniform( 'modelMatrix', 'mmodel' )
      meshCanvas.mainShader.bindUniform( 'normalMatrix', 'mnormalmatrix' )
      meshCanvas.mainShader.bindUniform( 'time', 'wtime' )
      # light uniforms
      meshCanvas.mainShader.bindUniform( 'lightColor', 'sunlight.vcolor' )
      meshCanvas.mainShader.bindUniform( 'lightDirection', 'sunlight.vdirection' )
      meshCanvas.mainShader.bindUniform( 'lightAmbientIntensity', 'sunlight.fambientintensity' )

      # - themesh -
      meshCanvas.theMesh = {}
      meshCanvas.theMesh.program = meshCanvas.mainShader

      # reference from original triangle shape
      triangleVertex = Geometric.triangle(1)

      # gl mesh
      meshCanvas.theMesh.mesh = new TheMesh( meshCanvas.mainShader )
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
      meshCanvas.lid.program = meshCanvas.mainShader

      # gl mesh
      meshCanvas.lid.mesh = new Mesh()
      # vertex
      meshCanvas.lid.mesh.initBuffer({
         id: 0
         data: triangleVertex
         attribPointerId: meshCanvas.mainShader.vertexPositionAttribute
         attribPointerSize: 3
         usage: gl.DYNAMIC_DRAW
      })
      # uv
      meshCanvas.lid.mesh.initBuffer({
         id: 1
         data: [0,0,1,0,0,1,0,0,1]
         attribPointerId: meshCanvas.mainShader.vertexNormalAttribute
         attribPointerSize: 3
         usage: gl.STATIC_DRAW
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

      # - vertex circle indicator -
      meshCanvas.simpleShader = new Shader('simple')
      meshCanvas.simpleShader.bindUniform( 'projectionMatrix', 'mprojection' )
      meshCanvas.simpleShader.bindUniform( 'viewMatrix', 'mview' )
      meshCanvas.simpleShader.bindUniform( 'modelMatrix', 'mmodel' )

      meshCanvas.circle = {}
      meshCanvas.circle.program = meshCanvas.simpleShader

      # gl mesh
      meshCanvas.circle.mesh = new Mesh()
      circleVertex = Geometric.circle(0.1, 15)
      # vertex
      meshCanvas.circle.mesh.initBuffer({
         id: 0
         data: circleVertex
         attribPointerId: meshCanvas.simpleShader.vertexPositionAttribute
         attribPointerSize: 3
         usage: gl.STATIC_DRAW
      })

      # default position of the mesh
      meshCanvas.circle.modelMatrix = mat4.create()

      mat4.identity(meshCanvas.circle.modelMatrix) # set to identity
      translation = vec3.create()
      vec3.set(translation, 0, 0, 0.2)
      mat4.translate(
         meshCanvas.circle.modelMatrix,
         meshCanvas.circle.modelMatrix,
         translation)

      # - camera -
      meshCanvas.camera = new Camera(
         [0,-2,1.4],
         [0,0,0],
         meshCanvas.aspect
      )
      meshCanvas.camera.far_plane = 400

      # - post processing effects -
      effects = {}
      effects.normal = new Shader('normal', true)
      effects.normal.bindUniform( 'textureSample', 'ttexture' )
      #effects.colorCorrection = new Shader('colorCorrection', true)

      effects.square = new Mesh()
      effects.square.initBuffer({
         id: 0
         data: [-1,1, -1,-1, 1,-1, 1,1]
         attribPointerId: effects.normal.vertexPositionAttribute
         attribPointerSize: 2
         usage: gl.STATIC_DRAW
      })
      effects.square.initBuffer({
         id: 2
         data: [0,1, 0,0, 1,0, 1,1]
         attribPointerId: effects.normal.texCordAttribute
         attribPointerSize: 2
         usage: gl.STATIC_DRAW

      })
      effects.square.initBufferIndex([0,1,2,0,2,3])

      meshCanvas.effects = effects

      # normals visor
      meshCanvas.normalsVisor = {}
      meshCanvas.normalsVisor.program = meshCanvas.simpleShader
      meshCanvas.normalsVisor.program.bindUniform( 'color', 'vcolor' )
      meshCanvas.normalsVisor.program.bindUniform( 'billboard', 'drawbillboard' )

      meshCanvas.normalsVisor.mesh = new NormalsVisor(meshCanvas.simpleShader, meshCanvas.theMesh.mesh)

      meshCanvas.normalsVisor.modelMatrix = mat4.create()

      mat4.identity(meshCanvas.normalsVisor.modelMatrix) # set to identity
      translation = vec3.create()
      vec3.set(translation, 0, 0, 0)
      mat4.translate(
         meshCanvas.normalsVisor.modelMatrix,
         meshCanvas.normalsVisor.modelMatrix,
         translation)

      meshCanvas.normalsVisor.show = false

      return

   setUpRender = ->
      #gl.clearColor 0.0, 0.0, 0.0, 1.0
      gl.clearColor 0.023, 0.031, 0.027, 1.0
      # enable alpha
      # gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA

      # 3D z geometry
      gl.enable gl.DEPTH_TEST
      gl.enable gl.CULL_FACE
      gl.cullFace gl.BACK
#      gl.frontFace gl.CW

      meshCanvas.drawLoopId = setInterval(updateTime, meshCanvas.drawInterval)
      meshCanvas.effectLoopId = setInterval () ->
         meshCanvas.theMesh.mesh.addLevel()
         meshCanvas.theMesh.mesh.repostMeshData()
      , meshCanvas.drawInterval * (meshCanvas.growSize/meshCanvas.growVelcity)

      meshCanvas.ready = true

   initStats = ->
      meshCanvas.stats = new Stats()
      meshCanvas.stats.setMode( 0 )

      meshCanvas.stats.domElement.style.position = 'absolute'
      meshCanvas.stats.domElement.style.left = '0px'
      meshCanvas.stats.domElement.style.top = '0px'

      document.body.appendChild( meshCanvas.stats.domElement )

   init = ->
      $('body').prepend(meshCanvas.canvas)

      canvas = meshCanvas.canvas[0]
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight

      meshCanvas.width = canvas.width
      meshCanvas.height = canvas.height
      meshCanvas.aspect = window.innerWidth / window.innerHeight

      try
         gl = WebGL.getInstance(canvas)

         loadResources()
      catch e
         return console.log 'Error loading sources\n', e

      # if the resources are loaded and running
      initStats()
      setUpRender()

   stop = ->
      clearInterval(meshCanvas.drawLoopId)
      clearInterval(meshCanvas.effectLoopId)
      $(meshCanvas.canvas).remove()

   return {
      init
      stop
      pushVertexPos
      moveCamera
   }
