$(document).ready ->
  url2id = (url) ->
    url = url.substr(1) if url.charAt(0) == ('/')
    url.replace(/\//g,'-').replace(/\s/g,'-').replace(/\./g,'_')

  directives =
    profiles:
      'name@href':    -> @url
      'name@id':      -> url2id(@url)
      testsets:
        'name@href':  -> @url
        'compare@href': (element) -> if @comparison_url then @comparison_url else element.hide(); return ""
        'name@id':    -> url2id(@url)
        'inplace-edit@data-url': -> @url
        'inplace-edit@id': -> "input-" + url2id(@url)
        products:
          'name@href': -> @url
          'name@id':   -> url2id(@url)
          'inplace-edit@data-url': -> @url
          'inplace-edit@id': -> "input-" + url2id(@url)

  $('#report_navigation').empty().append( $('#report_navigation_template').clone().render(index_model, directives).children() ) unless $('#report_navigation').hasClass('rendered') #if clause is for debugging

  $('#report_navigation').addClass('rendered') #debug

  $inputs    = $('#report_navigation input.inplace-edit')
  $editables = null

  resetInputValue = (input) ->
    $input = $(input)
    $link  = $input.prev('a.name')
    $input.val $link.text()
    $editables.text($link.text()) if $editables? # revert text for similar products
    return false

  writeInputValue = (input) ->
    $input = $(input)
    value  = $input.val()
    $link  = $input.prev('a.name')
    $link.text value
    if $editables?
      $editables.text value  # write text for similar products
      $editables.next('input.inplace-edit').val value
    return false

  editHandler = (link) ->
    $link = $(link)
    $link.hide()
    $link.next('input.inplace-edit').show().focus()
    # set editables for real-time update to similar products
    $editables = $('.products a').not($link).filter () ->
      return $(this).text() == $link.text()
    $editables.addClass 'being_edited'
    return false

  cancelHandler = (input) ->
    $input = $(input)
    resetInputValue($input)
    $input.hide()
    $input.prev('a.name').show()
    $editables.removeClass 'being_edited' if $editables?
    $editables = null
    return false

  submitHandler = (input) ->
    $input = $(input)
    writeInputValue($input)
    $input.hide()
    $input.prev('a.name').show()
    $editables.removeClass 'being_edited' if $editables?
    $editables = null
    postCategoryNameUpdate(input)
    return false

  postCategoryNameUpdate = (input) ->
    $input   = $(input)
    post_url = $input.attr('data-url')
    val  = $input.val()

    data =
      "authenticity_token" : auth_token
      "_method"            : "put"
      name                 : val

    console.log data
    console.log post_url
    $.post post_url, data, (res) ->
      console.log res

  initInplaceEdit = ->
    # Reset input fields
    $inputs.each () -> $(this).val $(this).prev('a.name').text()

    # Edit events
    $('#index_page.editing #report_navigation tbody a.name').live 'click', () -> editHandler this
    $inputs.blur -> cancelHandler this
    $inputs.keyup (key) -> cancelHandler this if (key.keyCode == 27) # esc
    $inputs.keyup (key) -> submitHandler this if (key.keyCode == 13) # enter

    # Real-time update to similar products
    $('.products input.inplace-edit').keyup -> $editables.text $(this).val() if $editables?

     # Hover hilight for products
    $('#index_page.editing .products a').live 'mouseover', () ->
      if not $editables?
        product_name = $(this).text()
        $('#index_page.editing .products a').filter(() ->
          return $(this).text() == product_name
        ).addClass('to_be_edited')
    $('#index_page.editing .products a').live 'mouseout', () ->
      $('#index_page.editing .products a').removeClass('to_be_edited')
    return false

  # View mode / Edit mode
  $('#home_edit_link').click () ->
    $('#index_page').addClass 'editing'
    $('#index_page.editing #report_navigation tbody a.name').addClass('editable_text').css 'display', 'block'
    $('a.compare').hide()

  $('#home_edit_done_link').click () ->
    $('#index_page').removeClass 'editing'
    $('#report_navigation tbody a.name').removeClass 'editable_text'
    $('#report_navigation tbody a.name').css 'display', 'inline'
    $('a.compare').show()

  initInplaceEdit()
