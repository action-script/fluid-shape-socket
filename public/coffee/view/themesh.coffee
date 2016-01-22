class TheMesh extends Mesh
   constructor: (@program) ->
      super @program
      @vertex = []
      @levelVertex = []
      @index = []

   setUp: (@triangleVertex) ->
      gl = @gl
      @levelVertex = @levelVertex.concat( @triangleVertex )
      @vertex = @vertex.concat ( @triangleVertex )
      @addLevel()

      bufferData =
         id: 0
         data: @vertex
         attribPointerId: @program.vertexPositionAttribute
         attribPointerSize: 3
         usage: gl.DYNAMIC_DRAW

      @initBuffer(bufferData)
      @initBufferIndex(@index)

   addLevel: ->
      @vertex = @vertex.splice(0, @vertex.length-@levelVertex.length )
      l = @vertex.length / 3
      @vertex = @vertex.concat( @levelVertex, @levelVertex )

      # calculate triangle index to draw elements
      for v in [0..2]
         i = v+l
         @index.push(
            i,
            l+(i+1)%3,
            i+3,

            i+3,
            l+(i+1)%3,
            l+(i+1)%3+3
         )

   pushVertexPos: (id, x, y) ->
      @levelVertex[3*id] = @triangleVertex[3*id] + y
      @levelVertex[3*id+1] = @triangleVertex[3*id+1] + x

   updateVertexPos: ->
      gl = @gl
      l = @vertex.length - 3*3 # 3 float per vertex, 3 vertex
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[0].vbo
      # buffer_type, array_offset, new_data
      gl.bufferSubData gl.ARRAY_BUFFER,
         l*4, # 3 poinrs x Vertex, 4 bytes x Float (float32 bits)
         new Float32Array(@levelVertex)

   repostMeshData: ->
      gl = @gl
      ###
      for i,c in meshCanvas.theMesh.index
         console.log c+' v:'+i+' ['+meshCanvas.theMesh.vertex[i+2]+', '+meshCanvas.theMesh.vertex[i+1]+', '+meshCanvas.theMesh.vertex[i+2]+']'
      ###
      @buffers[0].data = @vertex
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[0].vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(@buffers[0].data), gl.DYNAMIC_DRAW

      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @ibo
      gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@index), gl.STATIC_DRAW

   draw: () ->
      @updateVertexPos()
      super
      # super @gl.LINE_STRIP
