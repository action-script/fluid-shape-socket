class Mesh
   constructor: (@program) ->
      @gl = WebGL.getInstance()
      @isIndexArrayMesh = false
      @buffers = []

   initBuffer: (bufferData) ->
      gl = @gl
      buffer = @buffers[bufferData.id] = bufferData

      # generate and bind the buffer object
      buffer.vbo = gl.createBuffer()
      gl.bindBuffer gl.ARRAY_BUFFER, buffer.vbo
      gl.bufferData gl.ARRAY_BUFFER,      # target
         new Float32Array(buffer.data),   # data
         buffer.usage                     # usage. dynamic access to the vertex

      # set up attrib pointer
      gl.enableVertexAttribArray buffer.attribPointerId # Attrib location id pointer
      gl.vertexAttribPointer(
         buffer.attribPointerId     # shader attrib pointer
         buffer.attribPointerSize,  # size, number of elements
         gl.FLOAT,                  # type of each element
         false,                     # normalized
         0,                         # stride, data between each position
         0                          # pointer, offset of first element
      )

      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding

   initBufferIndex: (@index) ->
      gl = @gl
      @isIndexArrayMesh = true

      # index buffer object
      @ibo = gl.createBuffer()
      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @ibo
      gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@index), gl.STATIC_DRAW

      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null # unbinding

   draw: (type = @gl.TRIANGLES) ->
      gl = @gl
      @program.use()
      # bind all the vbo streams
      for buffer in @buffers
         gl.bindBuffer gl.ARRAY_BUFFER, buffer.vbo

      if @isIndexArrayMesh
         gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @ibo
         gl.drawElements type, @index.length, gl.UNSIGNED_SHORT, 0
         gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null # unbinding
      else
         gl.drawArrays type, 0, @buffers[0].data/@buffers[0].attribPointerSize

      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding
      