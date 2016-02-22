class FrameManger
  constructor: (options) ->
    @options = options or {}
    @options.width or= 180
    @options.height or= 180
    @options.margin or= 1
    @images = []
    @workspace = $ '.workspace'
    @gallery = $ '.gallery'
      .on 'click', '.gallery-item', (e) =>
        for i in [0 ... @images.length]
          item = @images[i]
          if item.wrap[0] is e.currentTarget
            @show i
            break
    @edger = new Edger

  toColor: (num) ->
    s = num.toString(16)
    while s.length < 6
      s = '0' + s
    '#' + s

  normalize: (img) ->
    width = @options.width
    height = @options.height
    margin = @options.margin
    _width = img.width
    _height = img.height
    return img if _width <= width and _height <= height
    k = _width / width
    kh = _height / height
    if k < kh
      width = ~~ (_width / kh)
    else
      height = ~~ (_height / k)
    canvas = ($ '<canvas>')[0]
    canvas.width = width + 2 * margin
    canvas.height = height + 2 * margin
    ctx = canvas.getContext '2d'
    ctx.drawImage img, margin, margin, width, height
    canvas = @edger.getMarginedCanvas canvas, margin
    img = new Image
    img.src = do canvas.toDataURL
    img

  clear: ->
    @images = []

  add: (img) ->
    img = @normalize img
    wrap = $ '<div class="gallery-item">'
      .html img
      .appendTo @gallery
    @images.push
      img: img
      wrap: wrap

  remove: (i) ->
    item = (@images.splice i, 1)[0]
    do item.wrap.remove
    if @active is item
      @active = null
      @show i

  get: (i) ->
    if i < 0
      i += @images.length
    @images[i]

  each: (cb) ->
    @images.forEach cb

  show: (i) ->
    @active?.wrap.removeClass 'active'
    @active = @get i
    @active?.wrap.addClass 'active'
    @workspace.html if @active then $(@active.img).clone() else ''
