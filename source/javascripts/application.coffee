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
                    [Math.sin(App.DEG2RAD),  Math.cos(App.DEG2RAD)]
                  ]

  App.rotationMatrixFor = (angle) ->
    Matrix.create [
                    [Math.cos(angle * App.DEG2RAD), -Math.sin(angle * App.DEG2RAD)],
                    [Math.sin(angle * App.DEG2RAD),  Math.cos(angle * App.DEG2RAD)]
                  ]

  App.transformMatrixDataFor = (element) ->
    transformString = window.getComputedStyle(element).transform ||
                      window.getComputedStyle(element).mozTransform ||
                      window.getComputedStyle(element).webkitTransform
    # e.g.: "matrix(1.40954, 0.51303, -0.51303, 1.40954, 400, 20)"


    # have to do this in 3 steps, do NOT chain these calls - cf. http://css-tricks.com/get-value-of-css-rotation-through-javascript/
    # console.log '0:', transformString
    values = transformString.split('(')[1]
    # console.log '1: ', values
    if values?
      values = values.split(')')[0]
      # console.log '2: ', values
    if values?
      values = values.split(',')
      #console.log 'values:', values
    _.map values, (value) ->
      # console.log 'map:', value, parseInt(value)
      return parseInt(value)
      # console.log '3: ', values
      # => something like: ["1", " 0", " 0", " 1", " -100", " -100"]

  App.positionFor = (element) ->
    matrixData = App.transformMatrixDataFor(element)
    Vector.create [matrixData[4], matrixData[5]]

  App.transformMatrixFor = (element) ->
    matrixData = App.transformMatrixDataFor(element)
    Matrix.create [
                    [ matrixData[0], matrixData[1] ]
                    [ matrixData[2], matrixData[3] ]
                  ]


  # circulate = (element) ->
  #   (drawCircle = ->
  #     App.probe = App.rotationMatrix.multiply(App.probe) # we're constantly moving the element by 1 degree
  #     element.style.left = "#{Math.round(App.probe.e(1))}px"
  #     element.style.bottom = "#{Math.round(App.probe.e(2))}px"
  #     requestAnimationFrame(drawCircle)
  #   )()

  # probeElements = document.getElementsByClassName('probe')
  # if probeElements.length
  #   for probeElement in probeElements
  #     circulate(probeElement)

  circulateCSS = (actor) ->
    (circulateActor = ->
      # newPosition = App.rotationMatrixFor(angle).multiply(App.probe) # we're constantly moving the element by 1 degree
      # translateVector = Vector.create([element.style.left, element.style.top]).subtract(newPosition)
      # # console.log window.getComputedStyle(element).getPropertyCSSValue('-webkit-transform')
      # # console.log window.getComputedStyle(element).getPropertyCSSValue('-webkit-transform')
      # #.getPropertyCSSValue('-webkit-transform')

      # # element.style.left = "#{Math.round(App.probe.e(1))}px"
      # # element.style.bottom = "#{Math.round(App.probe.e(2))}px"
      # element.style.webkitTransform = "translate(#{translateVector.e(1)}px, #{translateVector.e(2)}px)"

      #currentMatrixData = App.transformMatrixDataFor(actor.element)
      # console.log currentMatrixData
      # currentTranslate =
      #   Matrix.create [
      #                   [ parseInt(currentMatrixData[0]), parseInt(currentMatrixData[1]) ]
      #                   [ parseInt(currentMatrixData[2]), parseInt(currentMatrixData[3]) ]
      #                 ]
      currentPosition = actor.position # App.transformMatrixFor(actor.element).multiply(App.positionFor(actor.element))

      newPosition = App.rotationMatrixFor(1).multiply(currentPosition)
      console.log currentPosition.inspect(), newPosition.inspect()
      string = "translate(#{newPosition.e(1)}px, #{newPosition.e(2)}px)"
      actor.position = newPosition
      # console.log string, actor.element.webkitTransform
      #actor.element.style.transform = string
      actor.element.style.webkitTransform = string
   
      requestAnimationFrame(circulateActor)
    )()

  probeCSSElements = document.getElementsByClassName('probe_css')
  if probeCSSElements.length
    for probeCSSElement in probeCSSElements
      probeCSS =
        element: probeCSSElement
        position: Vector.create([100.0, 100.0])
        circulate: ->
          circulateCSS(@)

      probeCSS.circulate()


  # probeCSS =
  #   element: document.getElementsByClassName('probe_css')
  #   angle: 0
  #   circulate: ->
  #     circulateCSS(@)


  #if probeCSSElements.length
    #for probeCSSElement in probeCSSElements
      #circulateCSS(probeCSSElement)


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
