directives =
  profiles:
    'name@href':    -> this.url
    testsets:
      'name@href':  -> this.url
      products:
       'name@href': -> this.url

$('#report_navigation').render index_model, directives

$('#report_navigation tbody a.name').each () ->
  $i = $('<input>').addClass('inplace-edit')
    .hide().val($(this).text())
  $i.insertAfter $(this)

$('#home_edit_link').click () ->
  $('#index_page').addClass 'editing'
  $('#index_page.editing #report_navigation tbody a.name').addClass('editable_text').css 'display', 'block'
  $('a.compare').hide()

$('#home_edit_done_link').click () ->
  $('#index_page').removeClass 'editing'
  $('#report_navigation tbody a.name').removeClass 'editable_text'
  $('#report_navigation tbody a.name').css 'display', 'inline'
  $('a.compare').show()

$editables = null

# In-place edit with real-time update to similar hardware

$('#index_page.editing #report_navigation tbody a.name').live 'click', () ->
  hw_name = $(this).text()
  $editables = $('#report_navigation ul li a').filter () ->
    return $(this).text() == hw_name
  $editables.addClass 'being_edited'
  $(this).hide()
  $(this).next('input.inplace-edit').show().focus()
  return false

$('#report_navigation ul input.inplace-edit').keyup () ->
  hw_name = $(this).val()
  $editables.each () ->
    $(this).text(hw_name)

$('#report_navigation input.inplace-edit').blur () ->
  $(this).hide()
  $(this).prev('a.name').show()
  $editables.removeClass 'being_edited'
  $editables = null
  return false


# Hover hilight for hardware

$('#index_page.editing #report_navigation ul li a').live 'mouseover', () ->
  if $editables == null
    hw_name = $(this).text()
    $('#index_page.editing #report_navigation ul li a').filter(() ->
      return $(this).text() == hw_name
    ).addClass('to_be_edited')

$('#index_page.editing #report_navigation ul li a').live 'mouseout', () ->
  $('#index_page.editing #report_navigation ul li a').removeClass('to_be_edited')

