$(document).ready ->
    filterResults("tr.result_pass", "passing tests");
    $(".see_all_button").click();
    fetchBugzillaInfo();
    $('#th_test_case span.sort').hide()
