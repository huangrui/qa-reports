$ () ->

  directives =
    profiles:
      'name@href':    -> @url
      testsets:
        'name@href':  -> @url
        'compare@href': (element) -> if @comparison_url then @comparison_url else element.hide(); return ""
        products:
         'name@href': -> @url

  $('#report_filters a').click (event) ->
    link = $(this)
    event.preventDefault()
    $.get link.attr('href'), (index_model) ->
      $('#report_filters li').removeClass 'current'
      link.parent().addClass 'current'
      $('#report_navigation').render index_model, directives
      $('#report_navigation').show()

  $('#report_filters li a').first().trigger 'click'
