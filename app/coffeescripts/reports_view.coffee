$(document).ready () ->
    filterResults "tr.result_pass", "passing tests"
    fetchBugzillaInfo()
    $('#delete-dialog').jqm(modal:true).jqmAddTrigger('#delete-button')
