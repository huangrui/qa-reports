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

activateSuggestionLinks("div.field");

filterResults("tr.result_pass", "passing tests");
linkEditButtons();
$('.toggle_testcase').click(function(eObj) { toggleRemoveTestCase(eObj); return false; });
fetchBugzillaInfo();
prepareCategoryUpdate("#category-dialog");
});