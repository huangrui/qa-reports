
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

    uploader = new qq.FileUploaderBasic
        button: $('#upload_button')[0]
        element: $('#drag_drop_area')[0]
        action: '/upload_attachment/'
        debug: false
        params: params
        onSubmit: (id, fileName) ->
          $('#upload_button').removeClass 'draghover'
          $('#drag_drop_area').removeClass 'draghover'

          $fal = $("#file_attachment_list")
          $fal.append($('<li id="file_upload'+id+'"><a class="remove_list_item">Remove</a>'+fileName+'<img src="/images/progress.gif" /> <span id="file_upload' + id + 'ProgressBar"></span></li>'))

          $this_element = $fal.children().last()
          $this_element.click ->
              uploader._handler.cancel(id)
              $this_element.remove()

        onProgress: (id, fileName, loaded, total) ->
            $('#file_upload' + id + 'ProgressBar').text((loaded/total*100).toFixed(0) + "%")

        onComplete: (id, fileName, response) ->
            $('#file_upload' + id).remove()
            $("#file_attachment_list_ready").html(response.html_content)

    dragenter = (event) ->
      $('#upload_button').addClass('draghover')
      $('#drag_drop_area').addClass('draghover')
      return false

    dragleave = (event) ->
      $('#upload_button').removeClass('draghover')
      $('#drag_drop_area').removeClass('draghover')
      return false

    $('#drag_drop_area')
        .bind('dragenter', dragenter)
        .bind('dragover', dragenter)
        .bind('dragleave', dragleave)
        .bind 'drop', (event) ->
          event.preventDefault() if event.preventDefault
          uploader._uploadFileList event.originalEvent.dataTransfer.files
          return false
