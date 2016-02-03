class TheMesh extends Mesh
   constructor: (@program) ->
      super
      @vertex = []
      @levelVertex = []
      @normals = []

   setUp: (@triangleVertex) ->
      gl = @gl
      @levelVertex = @levelVertex.concat( @triangleVertex )
      @addLevel(@levelVertex)

      # vertex
      bufferData =
         id: 0
         data: @vertex
         attribPointerId: @program.vertexPositionAttribute
         attribPointerSize: 3
         usage: gl.DYNAMIC_DRAW

      @initBuffer(bufferData)

      # normals
      bufferData =
         id: 1
         data: @normals
         attribPointerId: @program.vertexNormalAttribute
         attribPointerSize: 3
         usage: gl.DYNAMIC_DRAW
      @initBuffer(bufferData)

   addLevel: (triangleVertex = null) ->
      # duplicate level
      lastLevelVertex = triangleVertex if triangleVertex?
      lastLevelVertex = @getLevelAsTriangle() unless lastLevelVertex?
      vertex = lastLevelVertex.concat(lastLevelVertex)

      for i in [0..2]
         # calculate triangle index to draw elements
         a = i*3
         b = ((i+1)%3)*3
         c = (i+3)*3
         d = c
         e = b
         f = b+9
         @vertex = @vertex.concat(
            vertex.slice(a, a+3),
            vertex.slice(b, b+3),
            vertex.slice(c, c+3),

            vertex.slice(d, d+3),
            vertex.slice(e, e+3),
            vertex.slice(f, f+3)
         )
         @normals.push(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) # add default normals

   getLevelAsTriangle: (offset = 0) ->
      offset++
      offset *= 18
      i = @vertex.length - (offset*3)
      triangleLevel = [
         # X                Y                   Z
         @vertex[i+3*3], @vertex[i+3*3+1], @vertex[i+3*3+2]
         @vertex[i+9*3], @vertex[i+9*3+1], @vertex[i+9*3+2]
         @vertex[i+15*3], @vertex[i+15*3+1], @vertex[i+15*3+2]
      ]

   getLastLevelVertex: (callback) ->
      l = @vertex.length - 18*3 # 18 vertex, 3 float points
      for i in [0..2]
         for j in [0,3,4]
            b = l+((17+6*i+j)%18)*3
            callback(i,b)

   calculateTriangleNormal: (vertexIndex)->
      l = vertexIndex
      faceNormal = @calculateSurfaceNormal( @vertex.slice(l, l+9)  )
      # replace level normals
      # TODO: if normal < defaul apply random
      @normals.splice.apply( @normals, [l,9].concat(faceNormal,faceNormal,faceNormal) )
   
   calculateSurfaceNormal: (triangle) ->
      t = []
      t[0] = triangle.slice(0,3)
      t[1] = triangle.slice(3,6)
      t[2] = triangle.slice(6,9)
      u = new vec3.create()
      v = new vec3.create()
      n = new vec3.create()
      vec3.subtract(u, t[0], t[1])
      vec3.subtract(v, t[0], t[2])

      vec3.cross(n, u, v)
      vec3.normalize(n,n)
      return Array.prototype.slice.call(n)

   pushVertexPos: (id, x, y) ->
      @levelVertex[3*id] = @triangleVertex[3*id] + y
      @levelVertex[3*id+1] = @triangleVertex[3*id+1] + x

   updateVertexPos: ->
      gl = @gl
      # update local vertex
      @getLastLevelVertex ((i, b) ->
         @vertex.splice.apply(
            @vertex, [b,3].concat( @levelVertex.slice(i*3, i*3+3) )
         )
      ).bind(this)

      # calculte last level normals
      l = @vertex.length - 18*3
      for i in [0..2]
         @calculateTriangleNormal(l+i*18)
         @calculateTriangleNormal(l+i*18+9)

      # update buffer vertex
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[0].vbo
      # buffer_type, array_offset, new_data
      gl.bufferSubData gl.ARRAY_BUFFER,
         l*4, # 4 bytes per Float (float32 bits)
         new Float32Array( @vertex.slice(l) )
      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding

      # update buffer normals
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[1].vbo
      gl.bufferSubData gl.ARRAY_BUFFER,
         l*4, # 4 bytes per Float (float32 bits)
         new Float32Array( @normals.slice(l) )
      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding

   repostMeshData: ->
      gl = @gl
      @buffers[0].data = @vertex
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[0].vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(@buffers[0].data), @buffers[0].usage
      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding
      @buffers[1].data = @normals
      gl.bindBuffer gl.ARRAY_BUFFER, @buffers[1].vbo
      gl.bufferData gl.ARRAY_BUFFER, new Float32Array(@buffers[1].data), @buffers[1].usage
      gl.bindBuffer gl.ARRAY_BUFFER, null # unbinding

   draw: () ->
      @updateVertexPos()
      super
