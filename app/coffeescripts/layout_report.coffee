on_ready_steps = ->
    renderSeriesGraphs ".serial_canvas"

    updateTemplateImage = (params) ->
        attachment_url = params.t.text
        attachment_filename = attachment_url.split('/').pop()

        $('h1#attachment_dialog_header').text attachment_filename
        $('img#attachment_dialog_image').attr 'src', attachment_url
        params.w.show()

    $('#attachment_template').jqm({
      modal:true
      onShow:updateTemplateImage
    }).jqmAddTrigger('.image_attachment').jqmAddClose('.modal_close')

    $('#nft_trend_dialog').jqm({
      modal:true
      onShow:renderNftTrendGraph
    }).jqmAddTrigger('.nft_trend_button').jqmAddClose($('a.modal_close'))


# IE hack
if typeof G_vmlCanvasManager != 'undefined'
    $(window).load on_ready_steps
else
    $(document).ready on_ready_steps
