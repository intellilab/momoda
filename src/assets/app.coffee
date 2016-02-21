class FrameManger
  constructor: (options) ->
    @options = options or {}
    @options.width or= 180
    @options.height or= 180
    @images = []
    @workspace = $ '.workspace'

  normalize: (img) ->
    width = @options.width
    height = @options.height
    _width = img.width
    _height = img.height
    return img if _width <= width and _height <= height
    k = _width / width
    kh = _height / height
    if k < kh
      width = _width / kh
    else
      height = _height / k
    canvas = ($ '<canvas>')[0]
    canvas.width = width
    canvas.height = height
    ctx = canvas.getContext '2d'
    ctx.drawImage img, 0, 0, width, height
    img = new Image
    img.src = do canvas.toDataURL
    img

  clear: ->
    @images = []

  add: (img) ->
    @images.push @normalize img

  get: (i) ->
    if i < 0
      i += @images.length
    @images[i]

  each: (cb) ->
    @images.forEach cb

  show: (i) ->
    @workspace.html @get i

class Revealer
  constructor: ->
    @wrap = $ '.reveal-wrap'
    @overlay = $ '.reveal-overlay'
    @content = $ '.reveal'
    @overlay.on 'click', => do @hide

  show: (html) ->
    @wrap.addClass 'active'
    @content.html html

  hide: ->
    @wrap.removeClass 'active'
    @content.html ''

frameManager = new FrameManger
revealer = new Revealer

$ '#btn-load'
  .on 'click', (e) ->
    $ '<input type=file accept="image/*">'
      .on 'change', (e) ->
        file = @files[0]
        return unless file
        reader = new FileReader
        reader.onload = (e) ->
          img = new Image
          img.src = @result
          img.onload = ->
            frameManager.add img
            frameManager.show -1
        reader.readAsDataURL file
      .trigger 'click'

$ '#btn-dump'
  .on 'click', (e) ->
    gif = new GIF
      workers: 2
      quality: 10
      workerScript: 'lib/gif.js/gif.worker.js'
    frameManager.each (img) => gif.addFrame img
    gif.on 'finished', (blob) ->
      reader = new FileReader
      reader.onload = ->
        img = new Image
        img.src = @result
        revealer.show img
      reader.readAsDataURL blob
    do gif.render
