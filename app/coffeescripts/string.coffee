if typeof String::trim != "function"
  String::trim = ->
    @replace /^\s+|\s+$/g, ""
