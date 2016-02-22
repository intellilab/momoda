frameManager = new FrameManger
revealer = new Revealer

getToken = do ->
  token = {}
  (cb) ->
    if token.expire and token.expire > do Date.now
      return cb token.data
    xhr = new XMLHttpRequest
    xhr.open 'GET', '/put_token', true
    xhr.onload = ->
      token =
        data: @responseText
        expire: do Date.now + 60 * 1000
      cb token.data
    do xhr.send

fetchImage = (token, file, cb) ->
  formData = new FormData
  formData.append 'token', token
  formData.append 'file', file
  xhr = new XMLHttpRequest
  xhr.open 'POST', 'http://upload.qiniu.com/', true
  xhr.onloadend = ->
    result = JSON.parse @responseText
    if @status is 200
      # {"name":"kenny.png","size":31304,"w":200,"h":200,"hash":"Fva3FEqUN_aysKyUqUIpjKec0jV7"}
      cb result
  xhr.send formData

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
    return unless frameManager.length()
    gif = new GIF
      workers: 2
      quality: 10
      workerScript: 'lib/gif.js/gif.worker.js'
      transparent: Edger::transparent.empty
    opts =
      delay: ($ '#delay').val()
    frameManager.each (item) => gif.addFrame item.img, opts
    gif.on 'finished', (blob) ->
      reader = new FileReader
      reader.onload = ->
        img = new Image
        img.src = @result
        img.onclick = ->
          getToken (token) ->
            hint.html '正在处理，请等待...'
            fetchImage token, blob, (res) ->
              url = "http://7wy47j.com1.z0.glb.clouddn.com/#{res.path}"
              img.src = url
              hint.html '长按图片保存，然后添加到自定义表情即可'
        hint = $ '<center>点击图片确定</center>'
        revealer.show $(img).add(hint)
      reader.readAsDataURL blob
    do gif.render
