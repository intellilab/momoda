class FrameManger
  constructor: (options) ->
    @options = options or {}
    @options.width or= 180
    @options.height or= 180
    @options.margin or= 1
    @images = []
    @workspace = $ '.workspace'
    @gallery =
      wrap: $ '.gallery'
      items: $ '.gallery-items'
      remove: $ '.gallery-remove'
    @gallery.items
      .on 'click', '.gallery-item', (e) =>
        i = @indexOfWrap e.currentTarget
        @show i if ~i
      .on 'click', '.gallery-item-remove', (e) =>
        do e.stopPropagation
        i = @indexOfWrap e.currentTarget.parentNode
        @remove i if ~i
    @gallery.remove.on 'click', (e) =>
      @gallery.items.toggleClass 'gallery-items-remove'
    @edger = new Edger

  toColor: (num) ->
    s = num.toString(16)
    while s.length < 6
      s = '0' + s
    '#' + s

  indexOfWrap: (wrap) ->
    for i in [0 ... @images.length]
      item = @images[i]
      if item.wrap[0] is wrap
        return i
    return -1

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

  length: -> @images.length

  clear: ->
    @images = []

  update: ->
    if @images.length
      @gallery.wrap.addClass 'has-items'
    else
      @gallery.wrap.removeClass 'has-items'

  add: (img) ->
    img = @normalize img
    wrap = $ '<div class="gallery-item"><div class="gallery-item-remove"><i class="fa fa-remove">'
      .append $(img).clone()
      .appendTo @gallery.items
    @images.push
      img: img
      wrap: wrap
    do @update

  remove: (i) ->
    item = (@images.splice i, 1)[0]
    do item.wrap.remove
    if @active is item
      @active = null
      i -= 1 if i >= @images.length
      @show i
    do @update

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
