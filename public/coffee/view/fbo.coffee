class FBO
   constructor: () ->
      @gl = WebGL.getInstance()
      @fbo = @gl.createFramebuffer()

   checkFboSatus: ->
      gl = @gl
      @use()
      switch gl.checkFramebufferStatus gl.FRAMEBUFFER
         when gl.FRAMEBUFFER_COMPLETE then console.log('framebuffer complete')
         when gl.FRAMEBUFFER_UNSUPPORTED then throw 'Error: video card does NOT support framebuffer object'
         when gl.FRAMEBUFFER_INCOMPLETE_ATTACHMENT then throw 'Error: framebuffer incomplete attachment'
         when gl.FRAMEBUFFER_INCOMPLETE_DIMESIONS then throw 'Error: framebuffer incomplete dimensions'
         when gl.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT then throw 'Error: framebuffer incomplete missing attachment'
         else throw 'Error: not a valuated error'
      @stop()

   use: ->
      @gl.bindFramebuffer @gl.FRAMEBUFFER, @fbo

   stop: ->
      @gl.bindFramebuffer @gl.FRAMEBUFFER, null

   attachColor: (color) ->
      gl = @gl
      @use()
      gl.framebufferTexture2D(
         gl.FRAMEBUFFER,         # target
         gl.COLOR_ATTACHMENT0,   # attachment pointer
         color.target,           # texture target
         color.id,               # texture id
         0                       # mipmap level of the texture to be attached
      )
      @stop()

   attachDepth: (depth = null) ->
      gl = @gl
      @use()
      depth.id = null unless depth?
      gl.framebufferRenderbuffer(
         gl.FRAMEBUFFER,       # target
         gl.DEPTH_ATTACHMENT,  # attachment pointer
         gl.RENDERBUFFER,      # renderbuffer target
         depth.id              # renderbuffer id
      )
      @stop()

   # constants

   @genTextureImage: (width, height, scale = 1) ->
      gl = WebGL.getInstance()
      img =
         width: width * scale
         height:height * scale
         format: gl.RGBA
         target: gl.TEXTURE_2D

      img.id = gl.createTexture()
      gl.bindTexture img.target, img.id
      gl.texImage2D(
         img.target,       # target
         0,                # level
         img.format,       # internal format
         img.width,        # width
         img.height,       # height
         0,                # border
         img.format,       # format
         gl.UNSIGNED_BYTE, # type
         null              # data
      )

      gl.texParameteri img.target, gl.TEXTURE_MAG_FILTER, gl.LINEAR
      gl.texParameteri img.target, gl.TEXTURE_MIN_FILTER, gl.LINEAR
#      gl.texParameteri img.target, gl.TEXTURE_MAG_FILTER, gl.NEAREST
#      gl.texParameteri img.target, gl.TEXTURE_MIN_FILTER, gl.NEAREST
#      gl.texParameteri img.target, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR
      gl.texParameteri img.target, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri img.target, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
#      gl.texParameteri img.target, gl.GENERATE_MIPMAP, gl.TRUE

      gl.bindTexture img.target, null # unbind

      return img

   @genRenderBufferImage: (width, height, scale = 1)  ->
      gl = WebGL.getInstance()
      img =
         width: width * scale
         height: height * scale
         format: gl.DEPTH_COMPONENT16
         target: gl.RENDERBUFFER

      img.id = gl.createRenderbuffer()

      gl.bindRenderbuffer img.target, img.id
      gl.renderbufferStorage(
         img.target,
         img.format,
         img.width,
         img.height
      )

      gl.bindRenderbuffer img.target, null # unbind

      return img
