linkEditButtons = () ->
    $('.editable_area').each (i, node) ->
        initInplaceEdit node, '.editcontent', 'textarea', true

    initInplaceEdit '.editable_title', '.editcontent', '.title_field', false

    $('.testcase').each (i, node) ->
        linkTestCaseButtons node

    $('.feature_record').each (i, node) ->
        initInplaceEdit $(node).find('.feature_record_notes'), '.content', '.comment_field', true
        initGradingEdit $(node).find('.feature_record_grading')

initGradingEdit = (context) ->
    context = $(context)

    content = context.find 'span.content'
    form    = context.find 'form'
    input   = form.find 'select'
    cls     = 'edit'

    clickHandler = () ->
        form.toggle()
        if context.hasClass cls
            context.unbind 'click'
            undo = input.val()
            input.focus()
        else
            context.click clickHandler
        context.toggleClass cls
        content.toggle()

        return false

    input.change ->
        data   = form.serialize()
        action = form.attr 'action'
        $.post action, data

        result = input.val()

        grade_cls = switch result
            when "1" then 'grading_red'
            when "2" then 'grading_yellow'
            when "3" then 'grading_green'
            else 'grading_white'

        content.removeClass().addClass 'content'
        content.addClass grade_cls
        clickHandler()

    input.blur ->
        return if context.hasClass cls
        clickHandler()
        return false

    context.click clickHandler


initInplaceEdit = (context, contentSelector, inputSelector, hasMarkup) ->
    context = $(context)

    content = context.find contentSelector
    form    = context.find 'form'
    input   = form.find inputSelector
    undo    = null

    cls = if context.hasClass 'edit' then 'edit' else 'editable_text'

    clickHandler = () ->
        form.toggle()
        if context.hasClass cls
            context.unbind 'click'
            undo = input.val()
            input.focus()
        else
            context.click clickHandler
        context.toggleClass cls
        content.toggle()

        return false

    context.click clickHandler

    form.find('.cancel').click ->
        input.val undo
        clickHandler()
        return false

    form.submit ->
        data   = form.serialize()
        action = form.attr 'action'
        $.post action, data

        val = input.val()

        if hasMarkup
            content.html formatMarkup val
            fetchBugzillaInfo()
        else
            content.text val

        clickHandler()
        return false

prepareCategoryUpdate = (div) ->
    $div      = $(div)
    $form     = $div.find "form"
    $save     = $div.find ".dialog-delete"
    $cancel   = $div.find ".dialog-cancel"
    $testset  = $div.find ".field .testset"
    $date     = $div.find ".field .date"
    $product  = $div.find ".field .product"
    $catpath  = $("dd.category")
    $datespan = $("span.date")
    $donebtn  = $('#wizard_buttons a')

    arrow     = $('<div/>').html(" &rsaquo; ").text()

    $testset.val $testset.val()
    $product.val $product.val()

    $save.click () ->
      targetval  = $('.field .target:checked').val()
      versionval = $('.field .version:checked').val()
      typeval    = $testset.val()
      hwval      = $product.val()
      dateval    = $date.val()

      # validate
      $div.find('.error').hide()
      if targetval == ''
        return false
      if typeval == ''
        $('.error.testset').text("Test set cannot be empty.").show()
        return false
      if versionval == ''
        return false
      if dateval == ''
        $('.error.tested_at').text("Test date cannot be empty.").show()
        return false
      if hwval == ''
        $('.error.product').text("product cannot be empty.").show()
        return false

      # send to server
      data = $form.serialize()
      url  = $form.attr 'action'

      # update DOM
      #  - update bread crumbs
      #  - update date
      $.post url, data, (data) ->
          $datespan.text(data)

          $catpath.html(htmlEscape(versionval) + arrow + htmlEscape(targetval)
                                               + arrow + htmlEscape(typeval)
                                               + arrow + htmlEscape(hwval))

          $donebtn.attr("href", "/" + encodeURI(versionval) +
                                "/" + encodeURI(targetval) +
                                "/" + encodeURI(typeval) +
                                "/" + encodeURI(hwval) +
                                "/" + SESSION_ID)

      $div.jqmHide()
      return false

###
 *  Handle the comments of category edit
 *  @return
###
handleFeatureCommentEdit = () ->
    $node = $(this)
    $div = $node.find 'div.content'
    return false if $div.is ":hidden"

    $feature = $node.closest '.feature_record'
    $form = $('#feature_comment_edit_form form').clone()

    $field = $form.find '.comment_field'

    id = $feature.attr('id').replace 'feature-', ''
    $form.attr 'action', "/features/#{id}"

    markup = $feature.find('.comment_markup').text()
    $field.autogrow()
    $field.val markup

    $form.submit handleFeatureCommentFormSubmit
    $form.find('.cancel').click () ->
        $form.detach()
        $div.show()
        $node.click handleFeatureCommentEdit
        $node.addClass 'edit'
        return false

    $node.unbind 'click'
    $node.removeClass 'edit'
    $div.hide()
    $form.insertAfter $div

    $field.change()
    $field.focus()
    return false

###
 * Submit feature's comments Ajax requirement
 * @return
###
handleFeatureCommentFormSubmit = () ->
    $form = $(this)
    $feature = $form.closest '.feature_record'
    $div = $feature.find '.feature_record_notes div.content'
    markup = $form.find('.comment_field').val()

    data = $form.serialize()
    url = $form.attr('action')
    $feature.find('.comment_markup').text markup
    html = formatMarkup markup
    $div.html html
    $form.detach()
    $div.show()
    $feature.find('.feature_record_notes')
        .click(handleFeatureCommentEdit)
        .addClass('edit')

    $.post url, data
    fetchBugzillaInfo()
    return false

handleResultEdit = () ->
    $node = $(this)
    $span = $node.find 'span'
    return false if $span.is ":hidden"

    $testcase = $node.closest '.testcase'
    id = $testcase.attr('id').replace 'testcase-', ''
    $form = $('#result_edit_form form').clone()
    $form.attr('action', "/test_cases/#{id}")
    $select = $form.find 'select'

    result = $span.text()

    code = switch result
        when 'Pass' then '1'
        when 'Fail' then '-1'
        else '0'

    $select.find('option[selected="selected"]').removeAttr "selected"
    $select.find('option[value="' + code + '"]').attr "selected", "selected"

    $node.unbind 'click'
    $node.removeClass 'edit'

    $form.submit handleResultSubmit
    $select.change () ->
        $select.unbind 'blur'
        if $select.val() == code
            $form.detach()
            $span.show()
            $node.addClass 'edit'
            $node.click handleResultEdit
        else
            $form.submit()

    $select.blur () ->
        $form.detach()
        $span.show()
        $node.addClass 'edit'
        $node.click handleResultEdit

    $span.hide()
    $form.insertAfter $span
    $select.focus()

    return false

handleResultSubmit = () ->
    $form = $(this)

    data = $form.serialize()
    url = $form.attr 'action'

    $node = $form.closest 'td'
    $node.addClass('edit').removeClass('pass fail na').click handleResultEdit

    $span = $node.find 'span'
    result = $form.find('select').val()

    [cls,txt] = switch result
        when '1'  then ['pass', 'Pass']
        when '-1' then ['fail', 'Fail']
        else ['na', 'N/A']
    $node.addClass cls
    $span.text txt

    $form.detach()
    $span.show()
    $.post url, data

    return false

handleDateEdit = () ->
    $button = $(this)
    $content = $button.find('span.content').first()
    $raw = $content.next 'span.editmarkup'
    return false if $content.is ":hidden"

    data = $raw.text()
    $form = $('#date_edit_form form').clone()
    $field = $form.find '.date_field'
    $field.val data
    $form.data('original', $content).data('raw', $raw).data 'button', $button

    $form.submit handleDateEditSubmit

    $form.find('.save').click () ->
        $form.submit()
        return false

    $form.find('.cancel').click () ->
        $form.detach()
        $content.show()
        $button.addClass 'editable_text'
        return false

    $content.hide()
    $form.insertAfter $content
    $field.focus()
    addDateSelector $field
    $button.removeClass 'editable_text'

    return false

handleDateEditSubmit = () ->
    $form = $(this)
    $content = $form.data('original')
    $raw = $form.data('raw')
    data = $form.find('.date_field').val()
    $raw.text(data);

    data = $form.serialize()
    action = $form.attr('action')

    $button = $form.data('button')

    $.post action, data, (data) ->
        $content.text data

    $button.addClass 'editable_text'
    $form.detach()
    $content.show()

    return false


handleCommentEdit = () ->
    $node = $(this)
    $div = $node.find 'div.content'
    return false if $div.is ":hidden"

    $testcase = $node.closest '.testcase'
    $form = $('#comment_edit_form form').clone()
    $field = $form.find '.comment_field'

    attachment_id = $div.find('.note_attachment').attr('id')
    attachment_url = $div.find('.note_attachment').attr('href') || ''
    attachment_filename = attachment_url.split('/').pop()

    $current_attachment = $form.find 'div.attachment.current'
    $add_attachment = $form.find 'div.attachment.new'

    if attachment_url == '' || attachment_filename == ''
        $current_attachment.hide()
    else
        $add_attachment.hide()

        $attachment_link = $current_attachment.find '.attachment_link'
        $attachment_link.attr 'href', attachment_url
        $attachment_link.html attachment_filename

        $current_attachment.find('input').attr 'value', attachment_filename

        $current_attachment.find('.delete').click () ->
            $attachment_field = $(this).closest('.field')
            $current_attachment = $attachment_field.find('div.attachment:not(.add)')
            $.post "/attachments/#{attachment_id}", {"_method": "delete"}

            $add_attachment = $attachment_field.find('div.attachment.new')

            $current_attachment.hide()
            $current_attachment.find('input').attr('value', '')
            $add_attachment.show()
            return false

    id = $testcase.attr('id').replace 'testcase-', ''
    $form.attr('action', "/test_cases/#{id}")

    markup = $testcase.find('.comment_markup').text()
    $field.autogrow()
    $field.val(markup)

    $form.submit handleCommentFormSubmit
    $form.find('.cancel').click () ->
        $form.detach()
        $div.show()
        $node.click handleCommentEdit
        $node.addClass 'edit'
        return false

    $node.unbind 'click'
    $node.removeClass 'edit'
    $div.hide()
    $form.insertAfter $div
    $field.change()
    $field.focus()

    return false

handleCommentFormSubmit = () ->
    $form = $(this)
    $testcase = $form.closest '.testcase'
    $div = $testcase.find '.testcase_notes div.content'
    markup = $form.find('.comment_field').val()

    data = $form.serialize()
    url = $form.attr 'action'
    $testcase.find('.comment_markup').text(markup)

    html = formatMarkup markup
    $div.html html
    $form.hide()
    $div.show()
    $testcase.find('.testcase_notes').click(handleCommentEdit).addClass 'edit'

    $form.ajaxSubmit
        datatype: 'xml'
        success: (responseText, statusText, xhr, $form) ->
            # if the ajaxSubmit method was passed an Options Object with the dataType
            # property set to 'json' then the first argument to the success callback
            # is the json data object returned by the server

            $testcase.find('.testcase_notes').html responseText
            fetchBugzillaInfo()

    return false

formatMarkup = (s) ->
    BUGZILLA_URI = $('#bugzilla_uri').text()
    s = htmlEscape s

    lines = s.split '\n'
    html = ""
    ul = false
    for line in lines
        line = $.trim line

        if ul && not /^\*/.test(line)
            html += '</ul>'
            ul = false
        else if line == ''
            html += "<br/>"
        if line == ''
            continue

        line = line.replace /'''''(.+?)'''''/g, "<b><i>$1</i></b>"
        line = line.replace /'''(.+?)'''/g, "<b>$1</b>"
        line = line.replace /''(.+?)''/g, "<i>$1</i>"
        line = line.replace /http\:\/\/([^\/]+)\/show_bug\.cgi\?id=(\d+)/g, "<a class=\"bugzilla fetch bugzilla_append\" href=\"http://$1/show_bug.cgi?id=$2\">$2</a>"
        line = line.replace /\[\[(http[s]?:\/\/.+?) (.+?)\]\]/g, "<a href=\"$1\">$2</a>"
        line = line.replace /\[\[(\d+)\]\]/g, "<a class=\"bugzilla fetch bugzilla_append\" href=\"" + BUGZILLA_URI + "$1\">$1</a>"

        line = line.replace /^====\s*(.+)\s*====$/, "<h5>$1</h5>"
        line = line.replace /^===\s*(.+)\s*===$/, "<h4>$1</h4>"
        line = line.replace /^==\s*(.+)\s*==$/, "<h3>$1</h3>"
        match = /^\*(.+)$/.exec line
        if match
            if not ul
                html += "<ul>"
                ul = true
            html += "<li>" + match[1] + "</li>"
        else if not /^<h/.test(line)
            html += line + "<br/>"
        else
            html += line

    return html

toggleRemoveTestCase = (eventObject) ->
    $testCaseRow = $(eventObject.target).closest '.testcase'
    id = $testCaseRow.attr('id').split('-').pop()
    if $testCaseRow.hasClass 'removed'
        restoreTestCase id
        linkTestCaseButtons $testCaseRow
    else
        removeTestCase id
        unlinkTestCaseButtons $testCaseRow

    $nftRows = $('.testcase-nft-' + id.toString())
    if $nftRows.length == 0
        $testCaseRow.toggleClass 'removed'
    else
        $nftRows.toggleClass 'removed'

    $testCaseRow.find('.testcase_name').toggleClass 'removed'
    $testCaseRow.find('.testcase_name a').toggleClass 'remove_list_item'
    $testCaseRow.find('.testcase_name a').toggleClass 'undo_remove_list_item'
    $testCaseRow.find('.testcase_notes').toggleClass 'edit'
    $testCaseRow.find('.testcase_result').toggleClass 'edit'

removeTestCase = (id, callback) ->
    $.post "/test_cases/#{id}", {"_method": "put", "test_case": {"deleted": "true"}}, () ->
        callback? this

restoreTestCase = (id, callback) ->
    $.post "/test_cases/#{id}", {"_method": "put", "test_case": {"deleted": "false"}}, () ->
        callback? this

removeAttachment = (id, callback) ->
    $.post "/attachments/#{id}", {"_method": "delete", "type": "report_attachment" }, () ->
        callback? this

unlinkTestCaseButtons = (node) ->
    $node = $(node)
    $comment = $node.find '.testcase_notes'
    $result = $node.find '.testcase_result'

    $result.unbind 'click'
    $comment.unbind 'click'

linkTestCaseButtons = (node) ->
    $node = $(node)
    $comment = $node.find '.testcase_notes'
    $result = $node.find '.testcase_result'

    $result.click handleResultEdit
    $comment.click handleCommentEdit

$(document).ready () ->
    window.SESSION_ID   = $('#session_id').text()

    $('#report_test_execution_date').val $('#formatted_execute_date').text()

    $('#category-dialog').jqm(modal:true).jqmAddTrigger('#test_category')

    $("#report_test_execution_date").datepicker
        showOn: "both"
        buttonImage: "/images/calendar_icon.png"
        buttonImageOnly: true
        firstDay: 1
        selectOtherMonths: true
        dateFormat: "yy-mm-dd"

    activateSuggestionLinks "div.field"
    filterResults "tr.result_pass", "passing tests"
    linkEditButtons()

    $('.toggle_testcase').click (eObj) ->
        toggleRemoveTestCase eObj
        return false

    fetchBugzillaInfo()
    prepareCategoryUpdate "#category-dialog"
