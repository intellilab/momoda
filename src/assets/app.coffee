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
      transparent: Edger::transparent.empty
    frameManager.each (img) => gif.addFrame img
    gif.on 'finished', (blob) ->
      reader = new FileReader
      reader.onload = ->
        img = new Image
        img.src = @result
        revealer.show img
      reader.readAsDataURL blob
    do gif.render
