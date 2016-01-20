WebGL = do ->
   glContext = false

   getWebGLContext = (canvas) ->
      names = ['webgl', 'experimental-webgl', 'webkit-3d', 'moz-webgl']
      for name in names
        try
          return canvas.getContext(name)
        catch e
          console.log('error canvas context')


   getInstance: (canvas = null) ->
      glContext = getWebGLContext(canvas) if not glContext and canvas?
      return glContext

