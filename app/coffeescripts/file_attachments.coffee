
$(document).ready ->
    csrf_token  = encodeURIComponent(
        encodeURIComponent($('meta[name=csrf-token]').attr('content'))
        )

    csrf_param  = $('meta[name=csrf-param]').attr('content')

    session_key = $('#session_key').text()
    cookie      = $('#session_cookie').text()

    params = id: $('#session_id').text()
    params[csrf_token] = csrf_param
    params[session_key] = encodeURIComponent(encodeURIComponent cookie)

    dragenter = (event) ->
      $(this).find('.upload_button').addClass('draghover')
      $(this).find('.drag_drop_area').addClass('draghover')
      return false

    dragleave = (event) ->
      $(this).find('.upload_button').removeClass('draghover')
      $(this).find('.drag_drop_area').removeClass('draghover')
      return false

    prepareFileUpload = (upload_area, template, upload_url) ->
      $upload_area = $(upload_area)
      $list_item_template = $(template)

      $upload_area
          .bind('dragenter', dragenter)
          .bind('dragover', dragenter)
          .bind('dragleave', dragleave)
          .bind 'drop', (event) ->
            event.preventDefault() if event.preventDefault
            uploader._uploadFileList event.originalEvent.dataTransfer.files
            return false

      uploader = new qq.FileUploaderBasic
          button:   $upload_area.find('.upload_button')[0]
          element:  $upload_area[0]
          action:   upload_url
          debug:    false
          params:   params
          onSubmit: (id, fileName) ->
            $upload_area.find('.upload_button').removeClass 'draghover'
            $upload_area.removeClass 'draghover'

            $fal = $upload_area.find('.file_list')
            $fal.append $('#attachment_list_item_template').clone().show()

            $this_element = $fal.children().last()
            $this_element.attr('id', "file_upload#{id}")
            $this_element.find('.filename').text(fileName)

            $this_element.click ->
                uploader._handler.cancel(id)
                $this_element.remove()

          onProgress: (id, fileName, loaded, total) ->
              $("#file_upload#{id} .progress_bar").text((loaded/total*100).toFixed(0) + "%")

          onComplete: (id, fileName, response) ->
              $(@element).find("#file_upload#{id}").remove()
              $(@element).find(".file_list_ready").html(response.html_content)

    prepareFileUpload('#attachment_drag_drop_area', '#attachment_list_item_template',
        '/upload_attachment/')

    prepareFileUpload('#result_file_drag_drop_area', '#attachment_list_item_template',
        '/upload_attachment/')

