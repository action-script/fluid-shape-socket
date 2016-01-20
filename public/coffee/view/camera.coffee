Function::property = (prop, desc) ->
   Object.defineProperty @prototype, prop, desc

class Camera
   constructor: (@program, @_position, @_center, @_aspect_ratio) ->
      @gl = WebGL.getInstance()
      @matrix =
         view: mat4.create()
         projection: mat4.create()

      @_fov = 60
      @_n_plane = 0.1
      @_f_plane = 150
      @_up = [0,0,1]

   @property 'position',
      get: -> @_position
      set: (@_position) ->

   @property 'center',
      get: -> @_center
      set: (@_center) ->

   @property 'aspec_ratio',
      get: -> @_aspect_ratio
      set: (@_aspect_ratio) ->

   @property 'fov',
      get: -> @_fov
      set: (@_fov) ->

   @property 'offset_position',
      set: (offset) ->
         vec3.add(@_position, @_position, offset)

   @property 'offset_center',
      set: (offset) ->
         vec3.add(@_center, @_center, offset)

   calculateProjection: ->
      # world projection (fov, aspect, near, far)
      mat4.perspective(
         @matrix.projection,
         Math.radians(@_fov),
         @_aspect_ratio,
         @_n_plane,
         @_f_plane
      )
      return @matrix.projection

   calculateView: ->
      # camera view (eye, center, up)
      mat4.lookAt(
         @matrix.view,
         @_position,
         @_center,
         @_up
      )
      return @matrix.view

   use: ->
      @calculateProjection()
      @calculateView()
      @program.use()
      @gl.uniformMatrix4fv(
         @program.projectionMatrixUniform,
         false,
         @matrix.projection)

      @gl.uniformMatrix4fv(
         @program.viewMatrixUniform,
         false,
         @matrix.view)
      ###
      @gl.uniformMatrix4fv(
         meshCanvas.theMesh.shader.modelMatrixUniform,
         false,
         meshCanvas.camera.modelMatrix)
      ###
