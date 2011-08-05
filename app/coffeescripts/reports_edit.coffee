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
