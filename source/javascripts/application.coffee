# requestAnimationFrame polyfill by Erik Möller with fixes from Paul Irish and Tino Zijdel
# https://gist.github.com/paulirish/1579671/raw/7f515ade253afbc860dac1f84e21998d54359d79/rAF.js
(->
  lastTime = 0
  vendors = ['ms', 'moz', 'webkit', 'o']
  x = 0

  while x < vendors.length and not window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  unless window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout(->
        callback currTime + timeToCall
      , timeToCall)
      lastTime = currTime + timeToCall
      id
  unless window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) ->
      clearTimeout id
)()

window.App = {}

thisLoop = null
lastLoop = null

App.DEG2RAD = Math.PI / 180.0 # factor required to convert radians to degrees

window.onload = (event) ->
  daAngle = 0
  App.probe = Vector.create [100.0, 100.0]
  # App.rotationMatrix =
  #   Matrix.create [
  #                   [Math.cos(daAngle * App.DEG2RAD), -Math.sin(daAngle * App.DEG2RAD)],
  #                   [Math.sin(daAngle * App.DEG2RAD), Math.cos(daAngle * App.DEG2RAD)]
  #                 ]
  # App.rotationMatrixFor = (angle) ->
  #   angle = angle * App.DEG2RAD
  #   Matrix.create [
  #                   [Math.cos(angle), -Math.sin(angle)],
  #                   [Math.sin(angle), Math.cos(angle)]
  #                 ]

  # App.result = App.rotationMatrix.multiply(App.probe)

  App.rotationMatrix =
    Matrix.create [
                    [Math.cos(App.DEG2RAD), -Math.sin(App.DEG2RAD)],
                    [Math.sin(App.DEG2RAD), Math.cos(App.DEG2RAD)]
                  ]
  console.log App.rotationMatrix

  circulate = (element) ->
    (drawCircle = ->
      App.probe = App.rotationMatrix.multiply(App.probe) # we're constantly moving the element by 1 degree
      element.style.left = "#{Math.round(App.probe.e(1))}px"
      element.style.bottom = "#{Math.round(App.probe.e(2))}px"
      daAngle = daAngle + 1
      requestAnimationFrame(drawCircle)
    )()
  probeElement = document.getElementById('probe_css')
  circulate(probeElement)


  #fpsCounter = document.getElementById('fps-counter')
  #minFPSCounter = document.getElementById('min-fps-counter')
  #currentFPSCounter = document.getElementById('current-fps-counter')
  #maxFPSCounter = document.getElementById('max-fps-counter')
  #maxFPS = 0
  #minFPS = 9999

  # circle = (element, angle, center) ->
  #   (drawCircle = ->
  #     radius = 100 + (20 * Math.sin((angle * 11) * radDegFactor))
  #     offsetX = center.x
  #     offsetY = center.y
  #     radians = angle * radDegFactor
  #     x = Math.cos(radians) * radius + offsetX
  #     y = Math.sin(radians) * radius + offsetY
  #     element.style.left = "#{x}px" # can't use plain numbers!
  #     element.style.top = "#{y}px"
  #     element.style.MozTransform = 'rotate(' + (radians + Math.PI / 2) + 'rad)'
  #     element.style.WebkitTransform = 'rotate(' + (radians + Math.PI / 2) + 'rad)'

  #     angle++

  #     #thisLoop = new Date()
  #     #fps = Math.floor(1000 / (thisLoop - lastLoop))
  #     #console.log(fps)
  #     #if fps < 250 and fps > maxFPS
  #     #  maxFPS = fps
  #     #  maxFPSCounter.textContent = "#{maxFPS}"
  #     #if fps > 0 and fps < minFPS
  #     #  minFPS = fps
  #     #  minFPSCounter.textContent = "#{minFPS}"
  #     #currentFPSCounter.textContent = "#{fps}"
  #     #lastLoop = thisLoop
  #     # so far this is working fine with drawCircle; had problems before, alternatives are: arguments.callee and
  #     # `callback = (=> drawCircle())` (cf. http://stackoverflow.com/a/11380079)
  #     requestAnimationFrame drawCircle

  #   )()
  # cssCircle = (element, angle, center) ->
  #   (drawCSSCircle = ->
  #     radius = 200 + (20 * Math.sin((angle * 11) * radDegFactor))
  #     offsetX = center.x
  #     offsetY = center.y
  #     radians = angle * radDegFactor
  #     x = Math.cos(radians) * radius + offsetX
  #     y = Math.sin(radians) * radius + offsetY
  #     element.style.right = "#{-100 + 20 * Math.sin((angle * 11) * radDegFactor)}px"
  #     angle++
  #     requestAnimationFrame drawCSSCircle
  #   )()
  # counter = 0
  # daOuterWidth = window.outerWidth

  # fadeOff = 12 # slow down AT-ST animation so it doesn't switch background @ 60fps
  # moveATST = (element) ->
  #   (drawATST = ->
  #     if counter % fadeOff is 0
  #       #atStElement.style.background = 'none';
  #       #atStElement.style.backgroundRepeat = 'no-repeat';
  #       element.style.backgroundImage = "url('images/sprites/at_st_" + ((counter / fadeOff) % 6) + ".png')"
  #       element.style.right = "#{Math.round((counter * 1.3) % daOuterWidth)}px"
  #     counter++
  #     requestAnimationFrame drawATST
  #   )()

  # moveATST2 = (element) ->
  #   (drawATST2 = ->
  #     if counter % fadeOff is 0
  #       element.src = 'images/sprites/at_st_' + ((counter / fadeOff) % 6) + '.png'
  #       element.style.right = "#{Math.round((counter * 1.3) % daOuterWidth)}px"
  #     requestAnimationFrame drawATST2
  #   )()

  # # moveATST document.getElementById('at_st')
  # # moveATST2 document.getElementById('at_st_2')
  # alpha = 0

  # bobaFettElement = document.getElementById('boba_fett')
  # if bobaFettElement?
  #   circle bobaFettElement, alpha,
  #     x: 200
  #     y: 200
  # probeElement = document.getElementById('probe')
  # if probeElement?
  #   circle probeElement, alpha,
  #     x: 200
  #     y: 200

  # bobaFettCSSElement = document.getElementById('boba_fett_css_image')
  # if bobaFettCSSElement?
  #   cssCircle bobaFettCSSElement, alpha,
  #     x: 500
  #     y: 200
  # probeCSSElement = document.getElementById('probe_css_image')
  # # if probeCSSElement?
  # #   cssCircle probeCSSElement, alpha,
  # #     x: 500
  # #     y: 200
