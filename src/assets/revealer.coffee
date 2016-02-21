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
