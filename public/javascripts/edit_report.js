var SESSION_ID = "#{@test_session.id}";
$(document).ready(function(){
    $('#category-dialog').jqm({
    modal:true
}).jqmAddTrigger('#test_category');

$("#report_test_execution_date").datepicker({
    showOn: "both",
    buttonImage: "/images/calendar_icon.png",
    buttonImageOnly: true,
    firstDay: 1,
    selectOtherMonths: true,
    dateFormat: "yy-mm-dd"
});

$('#report_test_execution_date').val("#{@test_session.formatted_date}");

activateSuggestionLinks("div.field");

filterResults("tr.result_pass", "passing tests");
linkEditButtons();
$('.toggle_testcase').click(function(eObj) { toggleRemoveTestCase(eObj); return false; });
fetchBugzillaInfo();
prepareCategoryUpdate("#category-dialog");
});