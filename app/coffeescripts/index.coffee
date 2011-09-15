directives =
  profiles:
    'name@href':    -> this.url
    testsets:
      'name@href':  -> this.url
      products:
       'name@href': -> this.url

$('#report_navigation').render(index_model, directives)