/* DO NOT MODIFY. This file was compiled Wed, 03 Aug 2011 08:28:28 GMT from
 * /Users/pyykkis/work/qa-reports/app/coffeescripts/uploadForm.coffee
 */

$(document).ready(function() {
  var dragDrop, dragenter, dragleave, myDate, prettyDate, productSuggestions, product_url, testSetSuggestions, testtype_url, updateProductSuggestions, updateTestSetSuggestions, uploader;
  testSetSuggestions = [];
  productSuggestions = [];
  updateProductSuggestions = function(data) {
    productSuggestions = data;
    $("#report_test_product").autocomplete({
      source: productSuggestions
    });
    return activateSuggestionLinks("div.field");
  };
  updateTestSetSuggestions = function(data) {
    testSetSuggestions = data;
    $("#report_test_type").autocomplete({
      source: testSetSuggestions
    });
    return activateSuggestionLinks("div.field");
  };
  product_url = window.location.pathname.replace("upload", "product");
  testtype_url = window.location.pathname.replace("upload", "testset");
  $.get(product_url, updateProductSuggestions);
  $.get(testtype_url, updateTestSetSuggestions);
  $(".date").datepicker({
    showOn: "both",
    buttonImage: "/images/calendar_icon.png",
    buttonImageOnly: true,
    firstDay: 1,
    selectOtherMonths: true,
    dateFormat: "yy-mm-dd"
  });
  myDate = new Date();
  prettyDate = myDate.getUTCFullYear() + '-' + (myDate.getUTCMonth() + 1) + '-' + myDate.getUTCDate();
  $(".date").val(prettyDate);
  uploader = new qq.FileUploaderBasic({
    button: $('#upload_button')[0],
    element: $('#drag_drop_area')[0],
    action: '/upload_report/',
    debug: false,
    onSubmit: function(id, fileName) {
      var $fal, $this_element;
      $('#upload_button').removeClass('draghover');
      $('.field.last').removeClass('draghover');
      $('form input[type=submit]').attr('disabled', 'true');
      $fal = $("#file_attachment_list");
      $fal.append($('<li id="file_upload' + id + '"><a class="remove_list_item">Remove</a>' + fileName + '<img src="/images/progress.gif" /> <span id="file_upload' + id + 'ProgressBar"></span></li>'));
      $this_element = $fal.children().last();
      return $this_element.click(function() {
        uploader._handler.cancel(id);
        return $this_element.remove();
      });
    },
    onProgress: function(id, fileName, loaded, total) {
      return $('#file_upload' + id + 'ProgressBar').text((loaded / total * 100).toFixed(0) + "%");
    },
    onComplete: function(id, fileName, response) {
      $('#file_upload' + id).remove();
      $("#uploaded_list").append('<li><input type="checkbox" name="drag_n_drop_attachments[]" value="' + response.url + '" checked="true">' + fileName + '</li>');
      if (uploader._handler.getQueue().length === 1) {
        return $('form input[type=submit]').removeAttr('disabled');
      }
    }
  });
  dragenter = function(event) {
    $('#upload_button').addClass('draghover');
    $('.field.last').addClass('draghover');
    return false;
  };
  dragleave = function(event) {
    $('#upload_button').removeClass('draghover');
    $('.field.last').removeClass('draghover');
    return false;
  };
  dragDrop = function(event) {
    if (event.preventDefault) {
      event.preventDefault();
    }
    console.log(event.originalEvent.dataTransfer.files);
    uploader._uploadFileList(event.originalEvent.dataTransfer.files);
    return false;
  };
  return $('.field.last').bind('dragenter', dragenter).bind('dragover', dragenter).bind('dragleave', dragleave).bind('drop', dragDrop);
});