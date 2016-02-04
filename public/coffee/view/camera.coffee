Function::property = (prop, desc) ->
   Object.defineProperty @prototype, prop, desc

class Camera
   constructor: (@_position, @_center, @_aspect_ratio) ->
      @matrix =
         view: mat4.create()
         projection: mat4.create()

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

   @property 'rotation_y',
      get: -> @_y_rotation
      set: (@_y_rotation) ->

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
      calculated_position = []
      calculated_position[1] =
         @_position[1]*Math.cos(Math.radians @_x_rotation ) - @_position[2]*Math.sin(Math.radians @_x_rotation )
      calculated_position[2] =
         @_position[1]*Math.sin(Math.radians @_x_rotation) + @_position[2]*Math.cos(Math.radians @_x_rotation)
         
      calculated_position[0] =
         @_position[0]*Math.cos(Math.radians @_z_rotation) - calculated_position[1]*Math.sin(Math.radians @_z_rotation)
      calculated_position[1] =
         @_position[0]*Math.sin(Math.radians @_z_rotation) + calculated_position[1]*Math.cos(Math.radians @_z_rotation)

      calculated_position = vec3.add(
         calculated_position,
         calculated_position,
         @_translation
      )
      # camera view (eye, center, up)
      mat4.lookAt(
         @matrix.view,
         calculated_position
         vec3.add([],@_center,@_translation),
         @_up
      )
      return @matrix.view


