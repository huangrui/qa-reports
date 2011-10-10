$(document).ready ->
  $navigation = $('#report_navigation')

  directives =
    profiles:
      'name@href':    -> @url
      testsets:
        'name@href':  -> @url
        'compare@href': (element) -> if @comparison_url then @comparison_url else element.hide(); return ""
        'inplace-edit@data-url': -> @url
        products:
          'name@href': -> @url
          'inplace-edit@data-url': -> @url

  render_navigation = (model) ->
    $navigation.render model, directives

  render_navigation(index_model)
  $editables = $()

  resetInputValue = (input) ->
    $input = $(input)
    $link  = $input.prev('a.name')
    $input.val $link.text()
    $editables.text($link.text()) # revert text for similar products
    return false

  writeInputValue = (input) ->
    $input = $(input)
    value  = $input.val()
    $link  = $input.prev('a.name')
    $link.text value
    $editables.text value  # write text for similar products
    $editables.next('input.inplace-edit').val value
    return false

  editHandler = (link) ->
    $link = $(link)
    $link.hide()
    $link.next('input.inplace-edit').show().focus()
    # set editables for real-time update to similar products
    $editables = $('.products a').not($link).filter () ->
      $(this).text() == $link.text()
    $editables.addClass 'being_edited'
    return false

  cancelHandler = (input) ->
    $input = $(input)
    resetInputValue($input)
    $input.hide()
    $input.prev('a.name').show()
    $editables.removeClass 'being_edited'
    $editables = $()
    return false

  #TODO: combine common parts cancel submit
  submitHandler = (input) ->
    $input = $(input)
    writeInputValue($input)
    $input.hide()
    $input.prev('a.name').show()
    $editables.removeClass 'being_edited'
    $editables = $()
    postCategoryNameUpdate(input)
    return false

  postCategoryNameUpdate = (input) ->
    $input   = $(input)
    post_url = $input.attr('data-url')
    val  = $input.val()

    data =
      "authenticity_token" : auth_token
      "_method"            : "put"
      "new_value"          : val

    $.post post_url, data, (res, status) ->
      $.ajax
        "url"      : "/"
        "dataType" : "json"
        "success"  : (data) ->
          render_navigation(data)
          editMode()

  #TODO try toggleclass
  editMode = ->
    $('#index_page').addClass 'editing'
    $navigation.find('tbody a.name').addClass('editable_text').css 'display', 'block'
    $navigation.find('a.compare').hide()

  viewMode = ->
    $('#index_page').removeClass 'editing'
    $navigation.find('tbody a.name').removeClass 'editable_text'
    $navigation.find('tbody a.name').css 'display', 'inline'
    $navigation.find('a.compare').filter((index) -> $(this).attr('href').length > 0).show()

  initInplaceEdit = ->
    # View mode / Edit mode
    $('#home_edit_link').click editMode
    $('#home_edit_done_link').click viewMode

    # Reset input fields
    $inputs = $navigation.find 'input.inplace-edit'
    $inputs.live 'focus', () -> $(this).val $(this).prev('a.name').text()

    # Edit events
    $('#index_page.editing #report_navigation tbody a.name').live 'click', () -> editHandler this
    $inputs.live 'blur', -> cancelHandler this
    $inputs.live 'keyup', (key) -> cancelHandler this if (key.keyCode == 27) # esc
    $inputs.live 'keyup', (key) -> submitHandler this if (key.keyCode == 13) # enter

    # Real-time update to similar products
    $('.products input.inplace-edit').live 'keyup', -> $editables.text $(this).val()

     # Hover hilight for products
    $('#index_page.editing .products a').live 'mouseover', () ->
      if $editables.length == 0
        product_name = $(this).text()
        $('#index_page.editing .products a').filter(() ->
          return $(this).text() == product_name
        ).addClass('to_be_edited')
    $('#index_page.editing .products a').live 'mouseout', () ->
      $('#index_page.editing .products a').removeClass('to_be_edited')
    return false

  initInplaceEdit()
