$(document).ready ->
  $navigation = $('#report_navigation')
  $editables  = $()

  directives =
    profiles:
      'name@href': -> @url
      testsets:
        'name@href': -> @url
        'compare@href': (element) -> if @comparison_url then @comparison_url else element.hide(); return ""
        'inplace-edit@data-url': -> @url
        products:
          'name@href': -> @url
          'inplace-edit@data-url': -> @url

  undo = (input) ->
    $input = $(input)
    $editables.text $input.data('undo')

  edit = (event) ->
    event.preventDefault()
    $link = $(this)
    $link.hide()
    $link.next('input.inplace-edit').show().focus().val($link.text())
                                                   .data('undo', $link.text())

    $editables = $('.products a').filter(-> $(this).text() == $link.text()).add $link
    $editables.addClass 'being_edited'

  end_edit = (input) ->
    $input = $(input)
    $input.hide()
    $input.prev('a.name').show()
    $editables.removeClass 'being_edited'
    $editables = $()

  cancel = (input) ->
    undo input
    end_edit input

  submit = (input) ->
    save input
    end_edit input

  save = (input) ->
    $input   = $(input)
    post_url = $input.attr('data-url')
    val  = $input.val()

    data =
      "authenticity_token" : auth_token
      "_method"            : "put"
      "new_value"          : val

    $.post post_url, data, (res, status) ->
      $.ajax
        "url"      : window.location.href.replace(/\/index/, '') + '/index.json'
        "success"  : (data) ->
          $navigation.render data, directives
          editMode()

  editMode = (event) ->
    event?.preventDefault()
    $('#index_page').addClass 'editing'
    $navigation.find('tbody a.name').addClass('editable_text').show()
    $navigation.find('a.compare').hide()

  viewMode = (event) ->
    event.preventDefault()
    $('#index_page').removeClass 'editing'
    $navigation.find('tbody a.name').removeClass 'editable_text'
    $navigation.find('tbody a.name').show()
    $navigation.find('a.compare').filter((index) -> $(this).attr('href').length > 0).show()

  initInplaceEdit = ->
    # View mode / Edit mode
    $('#home_edit_link').click editMode
    $('#home_edit_done_link').click viewMode

    # Edit events
    $('#index_page.editing #report_navigation tbody a.name').live 'click', edit
    $inputs = $navigation.find 'input.inplace-edit'
    $inputs.live 'blur',        -> cancel this
    $inputs.live 'keyup', (key) -> cancel this if (key.keyCode == 27) # esc
    $inputs.live 'keyup', (key) -> submit this if (key.keyCode == 13) # enter

    # Update text in links
    $('input.inplace-edit').live 'keyup', -> $editables.text $(this).val()

     # Hover hilight for products
    product_titles = '#index_page.editing .products a'
    $(product_titles).live 'mouseover', ->
      if $editables.length == 0
        product_name = $(this).text()
        $(product_titles).filter(-> $(this).text() == product_name)
          .addClass('to_be_edited')

    $(product_titles).live 'mouseout', ->
      $(product_titles).removeClass('to_be_edited')

  $('#release_filters a').click (event) ->
    event.preventDefault()
    target = $(event.target)
    link = target.attr('href') + $('#report_filters .current a').attr 'href'
    $.get link, (index_model) ->
      $('#release_filters li').removeClass 'current'
      target.parent().addClass 'current'
      $('#report_navigation').render index_model, directives
      $('#report_navigation').show()

  $('#report_filters a').click (event) ->
    target = $(event.target)
    event.preventDefault()
    link = $('#release_filters .current a').attr('href') + target.attr('href')
    $.get link, (index_model) ->
      $('#report_filters li').removeClass 'current'
      target.parent().addClass 'current'
      $('#report_navigation').render index_model, directives
      $('#report_navigation').show()

  $('#report_filters li a').first().trigger 'click'
  initInplaceEdit()
