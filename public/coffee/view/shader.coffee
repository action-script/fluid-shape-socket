class Shader
   constructor: (@name) ->
      @gl = WebGL.getInstance()
      gl = @gl
      # create shader program
      @program = gl.createProgram()
      
      # load and compile shaders
      vertexShader = @loadFromScript(@name+'VertexShader')
      fragmentShader = @loadFromScript(@name+'FragmentShader')

      # attach shaders to program
      gl.attachShader @program, vertexShader
      gl.attachShader @program, fragmentShader

      # link the program
      gl.linkProgram @program

      # check if is linked
      @checkShaderError(@program, true)

      # bind the attribute locations
      @vertexPositionAttribute = gl.getAttribLocation @program, 'vposition'
      throw ('Error: attribute not found') if @vertexPositionAttribute < 0

      # TODO: generic bind and check
      # bind uniform locations
      @projectionMatrixUniform = gl.getUniformLocation @program, 'mprojection'
      throw ('Could not bind uniform mprojection') unless @projectionMatrixUniform?

      @viewMatrixUniform = gl.getUniformLocation @program, 'mview'
      throw ('Could not bind uniform mview') unless @viewMatrixUniform?

      @modelMatrixUniform = gl.getUniformLocation @program, 'mmodel'
      throw ('Could not bind uniform mmodel') unless @modelMatrixUniform?


   loadFromScript: (id) ->
      gl = @gl
      shaderSource = document.getElementById(id)
      throw ('Error: script not found ' + id) unless shaderSource

      # detect shaderType by scriptTag
      shaderType = gl.VERTEX_SHADER if shaderSource.type == 'x-shader/x-vertex'
      shaderType = gl.FRAGMENT_SHADER if shaderSource.type == 'x-shader/x-fragment'
      throw ('Error: shader type not set') unless shaderType

      @compileShader(shaderSource.text, shaderType)

   compileShader: (shaderSource, shaderType) ->
      gl = @gl
      # create the shader object
      shader = gl.createShader shaderType

      # set the shader source code
      gl.shaderSource shader, shaderSource

      # compile the shader
      gl.compileShader shader

      # check if it compiled
      @checkShaderError(shader)
      return shader

   checkShaderError: (object, program = false) ->
      gl = @gl
      if program and gl.isProgram object
         success = gl.getProgramParameter object, gl.LINK_STATUS
         throw ('Linking program error' + gl.getProgramInfoLog object ) unless success
      else if gl.isShader object
         success = gl.getShaderParameter object, gl.COMPILE_STATUS
         throw ('could not compile shader:' + gl.getShaderInfoLog object ) unless success
      else
         throw ('Not shader or program')

   use: ->
      @gl.useProgram @program
