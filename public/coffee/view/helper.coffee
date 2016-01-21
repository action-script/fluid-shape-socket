do ->
   Math.radians = (degrees) ->
         degrees * Math.PI / 180

   unless window.requestAnimationFrame
      window.requestAnimationFrame = window.webkitRequestAnimationFrame if window.webkitRequestAnimationFrame
      window.requestAnimationFrame = window.mozRequestAnimationFrame if window.mozRequestAnimationFrame
      window.requestAnimationFrame = window.oRequestAnimationFrame if window.oRequestAnimationFrame
      unless window.requestAnimationFrame
         window.requestAnimationFrame = (fun) ->
            setTimeout(fun, 1000 / 30)

Geometric = do ->
   triangle = (size) ->
      # define a equilateral triangle
      vertex = [
       # X     Y     Z
         0,    0,    0,
         1,    0,    0,
         0.5, Math.sin(Math.radians(60)), 0
      ]

      for i in [0..2]
         # scale vertex
         vertex[i*3]    *= size
         vertex[i*3+1]  *= size
         # centre vertex
         vertex[i*3] -= size/2
         vertex[i*3+1] -= vertex[7]/3

      return vertex

   circle = (radio, resolution) ->
      vertex = []
      steps = 360 / resolution

      for i in [0..steps]
         vertex.push(
            Math.cos(Math.radians(i*resolution))*radio,  # X
            Math.sin(Math.radians(i*resolution))*radio,  # Y
            0                                            # Z 
         )

      return vertex

   return {
      triangle
      circle
   }
