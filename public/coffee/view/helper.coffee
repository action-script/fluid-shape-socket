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
