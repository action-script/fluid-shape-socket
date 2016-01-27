class NormalsVisor extends Mesh
   constructor: (@program, @mesh) ->
      super @program

      bufferData =
         id: 0
         data: []
         attribPointerId: @program.vertexPositionAttribute
         attribPointerSize: 3
         usage: @gl.STATIC_DRAW

      @initBuffer(bufferData)

   calculate: ->
      data = []
      vertex = @mesh.buffers[0].data
      normals = @mesh.buffers[1].data
      for i in [0..vertex.length/3-3]
         data = data.concat(
            vertex.slice(i*3, i*3+3),
            vec3.add( [],
               vertex.slice(i*3, i*3+3),
               vec3.scale([], normals.slice(i*3, i*3+3), 0.3)
            )
         )

      @repostData(data)

   repostData: (data) ->
      gl = @gl
      @buffers[0].data = data
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[0].vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(@buffers[0].data), @buffers[0].usage
      gl.bindBuffer gl.ARRAY_BUFFER, null

   draw: ->
      @calculate()
      super @gl.LINES
