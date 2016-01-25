Function::property = (prop, desc) ->
   Object.defineProperty @prototype, prop, desc

class Camera
   constructor: (@program, @_position, @_center, @_aspect_ratio) ->
      @gl = WebGL.getInstance()
      @matrix =
         view: mat4.create()
         projection: mat4.create()

      @axis =
         x: vec3.create()
         y: vec3.create()
         z: vec3.create()

      vec3.set(@axis.x, 1, 0, 0)
      vec3.set(@axis.y, 0, 1, 0)
      vec3.set(@axis.z, 0, 0, 1)

      @_fov = 60
      @_n_plane = 0.1
      @_f_plane = 150
      @_up = [0,0,1]
      @_translation = [0,0,0]
      @_x_rotation = 0
      @_y_rotation = 0
      @_z_rotation = 0

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

   @property 'far_plane',
      get: -> @_f_plane
      set: (@_f_plane) ->

   @property 'rotation_z',
      get: -> @_z_rotation
      set: (@_z_rotation) ->

   @property 'rotation_x',
      get: -> @_x_rotation
      set: (@_x_rotation) ->

   @property 'translation',
      get: -> @_translation
      set: (@_translation) ->

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

      # calculate rotation
      mat4.rotate(
         @matrix.view,
         @matrix.view,
         Math.radians(@_x_rotation),
         @axis.x
      )
      mat4.rotate(
         @matrix.view,
         @matrix.view,
         Math.radians(@_z_rotation),
         @axis.z
      )

      # calculate translation
      mat4.translate(
         @matrix.view,
         @matrix.view,
         @_translation)

      @program.setUniform( 'viewMatrix', 'uniformMatrix4fv', @matrix.view, false )

      @program.setUniform( 'projectionMatrix', 'uniformMatrix4fv', @matrix.projection, false )
