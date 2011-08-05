linkEditButtons = () ->
    $('div.editable_area').each (i, node) ->
        $node = $(node);
        contentDiv = $node.children('.editcontent').first()
        rawDiv = contentDiv.next '.editmarkup'
        $node.data 'content', contentDiv
        $node.data 'raw', rawDiv
        $node.click handleEditButton

    $('div.editable_title').click handleTitleEdit
    $('.testcase').each (i, node) ->
        linkTestCaseButtons node

    $('.feature_record').each (i, node) ->
        $node = $(node)
        $comment = $node.find '.feature_record_notes'
        $grading = $node.find '.feature_record_grading'

        $comment.click handleFeatureCommentEdit
        $grading.click handleFeatureGradingEdit

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

    id = $feature.attr('id').substring(8)
    $form.find('.id_field').val id

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

$(document).ready () ->
    window.SESSION_ID = $('#session_id').text()
    $('#report_test_execution_date').val $('#fomatted_execute_date').text()

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
