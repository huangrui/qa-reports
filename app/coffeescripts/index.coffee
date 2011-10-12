$ () ->

  directives =
    profiles:
      'name@href':    -> @url
      testsets:
        'name@href':  -> @url
        'compare@href': (element) -> if @comparison_url then @comparison_url else element.hide(); return ""
        products:
         'name@href': -> @url

  $.get '/reports.json', (index_model) ->
    $('#report_navigation').render index_model, directives
    $('#report_navigation').show()
