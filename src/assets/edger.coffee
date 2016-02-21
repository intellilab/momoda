class Edger
  transparent:
    empty: 0xfbfbfb
    alter: 0xffffff

  prepare: (canvas, margin) ->
    isBgPixel = (index) =>
      value = data.pixelData[index]
      unless value
        offset = index * 4
        colorArr = Array::slice.call imageData.data, offset, offset + 4
        value = if colorArr[3] then 1 else 2
        data.pixelData[index] = value
      value is 2

    checkSurroundings = (index) =>
      return if data.renderData[index]
      col = index % data.width
      row = ~~ (index / data.width)
      r = margin
      x0 = Math.max 0, col - r + 1
      x1 = Math.min col + r, data.width
      y0 = Math.max 0, row - r + 1
      y1 = Math.min row + r, data.height
      for x in [x0 ... x1]
        for y in [y0 ... y1]
          dx = x - col
          dy = y - row
          if dx * dx + dy * dy < r * r
            if not isBgPixel x + y * data.width
              data.renderData[index] = 1
              return
      data.renderData[index] = 2
      queue.push index

    checkRow = (index, excludeMid) =>
      if index % data.width
        checkSurroundings index - 1
      unless excludeMid
        checkSurroundings index
      if (index + 1) % data.width
        checkSurroundings index + 1

    margin or= 0
    ctx = canvas.getContext '2d'
    data =
      width: canvas.width
      height: canvas.height
    data.total = data.width * data.height
    imageData = ctx.getImageData 0, 0, data.width, data.height
    for i in [0 ... data.total]
      offset = i * 4
      alpha = imageData.data[offset + 3]
      if alpha
        for j in [0 .. 2]
          imageData.data[offset + j] = imageData.data[offset + j] * alpha / 255 + 255 - alpha
        imageData.data[offset + 3] = 255
        color = imageData.data[offset] << 16 + imageData.data[offset + 1] << 8 + imageData.data[offset + 2]
        color = ~~ (color * alpha / 255)
        if color == @transparent.empty
          color = @transparent.alter
          imageData.data[offset] = color >> 16
          imageData.data[offset + 1] = color >> 8 & 0xff
          imageData.data[offset + 2] = color & 0xff
    ctx.putImageData imageData, 0, 0

    # Whether the pixel itself is a background color.
    # 0 - not checked
    # 1 - visible
    # 2 - transparent
    data.pixelData = new Uint8Array data.total

    # Whether the pixel should be background taking margin into account.
    # 0 - not checked
    # 1 - visible
    # 2 - transparent
    data.renderData = new Uint8Array data.total

    queue = []
    for i in [0 ... data.width]
      checkSurroundings i
      checkSurroundings data.total - i - 1
    for i in [0 ... data.height]
      checkSurroundings i * data.width
      checkSurroundings (i + 1) * data.width - 1
    head = 0
    while head < queue.length
      index = queue[head]
      if index > data.width
        checkRow index - data.width
      checkRow index, true
      if index + data.width < data.total
        checkRow index + data.width
      head += 1

    data

  getShadowCanvas: (data) ->
    canvas = ($ '<canvas>')[0]
    canvas.width = data.width
    canvas.height = data.height
    ctx = canvas.getContext '2d'
    imageData = ctx.getImageData 0, 0, data.width, data.height
    colorEmpty = [
      @transparent.empty >> 16
      @transparent.empty >> 8 & 0xff
      @transparent.empty & 0xff
      255
    ]
    colorAlter = [
      @transparent.alter >> 16
      @transparent.alter >> 8 & 0xff
      @transparent.alter & 0xff
      255
    ]
    for i in [0 ... data.total]
      color = if data.renderData[i] < 2 then colorAlter else colorEmpty
      for j in [0 .. 3]
        imageData.data[i * 4 + j] = color[j]
    ctx.putImageData imageData, 0, 0
    canvas

  getMarginedCanvas: (canvas, margin) ->
    data = @prepare canvas, margin
    marginCanvas = @getShadowCanvas data
    ctx = marginCanvas.getContext '2d'
    ctx.drawImage canvas, 0, 0
    marginCanvas
