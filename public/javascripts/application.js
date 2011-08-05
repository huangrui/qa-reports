/*
 * This file is part of meego-test-reports
 *
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
 *
 * Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
 * 			Jarno Keskikangas <jarno.keskikangas@leonidasoy.fi>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 *
 */

var bugzillaCache = [];

function activateSuggestionLinks(target) {
    $(target).each(function(i, node) {
        var $node = $(node);
        $node.find(".suggestions a").each(function(i, a) {
            var target = $node.find('input');
            $(a).data("target", target).click(applySuggestion);
        });
    });
}

function applySuggestion() {
    var $this = $(this);
    $this.data("target").val($this.text());
    return false;
}

function capitalize(s) {
  return s.charAt(0).toUpperCase() + s.substr(1).toLowerCase();
}

function toTitlecase(s) {
  // TODO: s may be undefined when editing report
  return s.replace(/\w\S*/g, capitalize);
}

function htmlEscape(s) {
    s = s.replace('&', '&amp;');
    s = s.replace('<', '&lt;');
    s = s.replace('>', '&gt;');
    return s;
}

renderSeriesGraphs = function(selector) {
    var $selector = $(selector);

    var renderGraph = function(index, div) {
        var $div = $(div);
        var $modal_info = $div.prev()
        var values = eval($div.text());
        if (values.length > 0) {
            if (values.length == 1) {
                values[1] = values[0];
            }
            var id = $div.attr("id");
            //var $canvas = $('<canvas id="'+id+'" width="287" height="46"/>');
            var canvas = document.createElement("canvas");
            // if it is IE
            if (typeof G_vmlCanvasManager != 'undefined') {
                canvas = G_vmlCanvasManager.initElement(canvas);
            }

            var $canvas = $(canvas);
            $canvas.attr("id", id);
            $canvas.attr("width", "287");
            $canvas.attr("height", "46");

            var bg = $div.parent().css("background-color");
            $div.replaceWith($canvas);

            g = new Bluff.Line(id, '287x46');
            g.tooltips = false;
            g.sort = false;

            g.hide_title  = true;
            g.hide_dots   = true;
            g.hide_legend = true;
            g.hide_mini_legend = true;
            g.hide_line_numbers = true;
            g.hide_line_markers = true;

            g.line_width = 1;

            g.set_theme({
                colors: ['#acacac'],
                marker_color: '#dedede',
                font_color: '#6f6f6f',
                background_colors: [bg, bg]
            });

            g.data("values", values, "#8888dd");
            g.draw();

            $canvas.click(function() {
                renderModalGraph($modal_info);
            });
        }
    }

    var renderModalGraph = function(elem) {
        var $elem = $(elem);
        var title = $elem.find(".modal_graph_title").text();
        var xunit = $elem.find(".modal_graph_x_unit").text();
        var yunit = $elem.find(".modal_graph_y_unit").text();
        var data  = eval($elem.find(".modal_graph_data").text());

        var $modal = $(".nft_drilldown_dialog");
        var $close = $modal.find(".modal_close");

        $modal.find("h1").text(title);
        $modal.jqm({modal:true, toTop:true});
        $modal.jqmAddClose($close);
        $modal.jqmShow();

        //var $graph = $modal.find(".nft_drilldown_graph");
        var graph = document.getElementById("nft_drilldown_graph");
        var updateLabels = function() {
            $(graph).find("div").each(function(idx,e) {
                var $e = $(e);
                if ($e.css.has("top")) {
                    $e.css("width", parseInt($e.css("width"))+10);
                    $e.css("left", -10);
                    $e.text($e.text() + yunit);
                } else if ($e.css("text-align") == "center") {
                    $e.css("width", parseInt($e.css("width"))+15);
                    $e.text($e.text() + xunit);
                }
            });
        };
        dyg = new Dygraph(graph, data, {
          labels:[xunit, yunit],
          drawCallback: updateLabels,
          includeZero: true
          //xValueFormatter: function(x) {return x + xunit;}
          //yValueFormatter: function(y) {return y + yunit;}
        });

    }

    $selector.each(renderGraph);
}

prepareCategoryUpdate = function(div) {
    var $div      = $(div);
    var $form     = $div.find("form");
    var $save     = $div.find(".dialog-delete");
    var $cancel   = $div.find(".dialog-cancel");
    var $testset = $div.find(".field .testset");
    var $date     = $div.find(".field .date");
    var $product = $div.find(".field .product");
    var $catpath  = $("dd.category");
    var $datespan = $("span.date");
    var $donebtn  = $('#wizard_buttons a');

    var arrow     = $('<div/>').html(" &rsaquo; ").text();

    $testset.val($testset.val());
    $product.val($product.val());

    $save.click(function() {
      var targetval  = $('.field .target:checked').val();
      var versionval = $('.field .version:checked').val();
      var typeval    = $testset.val();
      var hwval      = $product.val();
      var dateval    = $date.val();

      // validate
      $div.find('.error').hide();
      if (targetval == '') {
        return false;
      } else if (typeval == '') {
        $('.error.testset').text("Test set cannot be empty.").show();
        return false;
      } else if (versionval == '') {
        return false;
      } else if (dateval == '') {
        $('.error.tested_at').text("Test date cannot be empty.").show();
        return false;
      } else if (hwval == '') {
        $('.error.product').text("product cannot be empty.").show();
        return false;
      }

      // send to server
      var data = $form.serialize();
      var url  = $form.attr('action');

      // update DOM
      //  - update bread crumbs
      //  - update date
      $.post(url, data, function(data) {
          console.log($catpath);
          $datespan.text(data);

          $catpath.html(htmlEscape(versionval) + arrow + htmlEscape(targetval)
                                               + arrow + htmlEscape(typeval)
                                               + arrow + htmlEscape(hwval));

          $donebtn.attr("href", "/" + encodeURI(versionval) +
                                "/" + encodeURI(targetval) +
                                "/" + encodeURI(typeval) +
                                "/" + encodeURI(hwval) +
                                "/" + SESSION_ID);
      });

      $div.jqmHide();

      return false;
    });


}

/**
 * Add content to the NFT trend graph when it's shown.
 *
 * Each callback is passed the "hash" object consisting of the
 * following properties;
 *  w: (jQuery object) The dialog element
 *  c: (object) The config object (dialog's parameters)
 *  o: (jQuery object) The overlay
 *  t: (DOM object) The triggering element
 */
var renderNftTrendGraph = function(hash) {
    var m_id = hash.t.id.match("[0-9]{1,}$");
    var $elem = $("#nft-trend-data-" + m_id);

    var data = $elem.children(".nft_trend_graph_data").text();
    // Don't break the whole thing if there's no data - now one can
    // at least close the window
    if (!data) {
	data = "Date,Value";
    }
    var title = $elem.find(".nft_trend_graph_title").text();
    var unit = $elem.find(".nft_trend_graph_unit").text();

    var graph = document.getElementById("nft_trend_graph");
    dyg = new Dygraph(graph, data);

    hash.w.find("h1").text(title);
    hash.w.show();
};

function unlinkTestCaseButtons(node) {
    var $node = $(node);
    var $comment = $node.find('.testcase_notes');
    var $result = $node.find('.testcase_result');

    $result.unbind('click');
    $comment.unbind('click');
}

function linkTestCaseButtons(node) {
    var $node = $(node);
    var $comment = $node.find('.testcase_notes');
    var $result = $node.find('.testcase_result');

    $result.click(handleResultEdit);
    $comment.click(handleCommentEdit);
}

/**
 * Handle the feature grading edit
 *
 */
function handleFeatureGradingEdit() {
    var $node = $(this);
    var $span = $node.find('span');
    if ($span.is(":hidden")) {
        return false;
    }
    var $feature = $node.closest('.feature_record');
    var id = $feature.attr('id').substring(8);
    var $form = $('#feature_grading_edit_form form').clone();
    $form.find('.id_field').val(id);
    var $select = $form.find('select');

    var $div = $feature.find('.feature_record_grading_content');

    var grading = $div.text();
    var code = "0";
    if (grading == 'Red') {
        code = "1";
    } else if (grading == 'Yellow') {
        code = "2";
    } else if (grading == 'Green') {
        code = "3";
    }
    $select.find('option[selected="selected"]').removeAttr("selected");
    $select.find('option[value="' + code + '"]').attr("selected", "selected");

    $node.unbind('click');
    $node.removeClass('edit');

    $form.submit(handleFeatureGradingSubmit);
    $select.change(function() {
        $select.unbind('blur');
        if ($select.val() == code) {
            $form.detach();
            $span.show();
            $node.addClass('edit');
            $node.click(handleFeatureGradingEdit);
        } else {
            $form.submit();
        }
     });
    $select.blur(function() {
        $form.detach();
        $span.show();
        $node.addClass('edit');
        $node.click(handleFeatureGradingEdit);
    });

    $span.hide();
    $form.insertAfter($div);
    $select.focus();
    return false;
}

/**
 * Submit feature's grading Ajax requirement
 */
function handleFeatureGradingSubmit() {
    var $form = $(this);
    var data = $form.serialize();
    var url = $form.attr('action');

    var $node = $form.closest('td');
    $node.addClass('edit').click(handleFeatureGradingEdit);

    var $span = $node.find('span');
    var $feature = $form.closest('.feature_record_grading');
    var $div =  $feature.find('.feature_record_grading_content');

    $span.removeClass('grading_white grading_red grading_yellow grading_green');
    var result = $form.find('select').val();
    if (result == "1") {
        $span.addClass('grading_red');
        $div.text('Red');
    } else if (result == "2") {
        $span.addClass('grading_yellow');
        $div.text('Yellow');
    } else if (result == "3"){
        $span.addClass('grading_green');
        $div.text('Green');
    } else {
        $span.addClass('grading_white');
        $div.text('N/A');
    }

    $form.detach();
    $span.show();
    $.post(url, data);
    return false;
}


function handleResultEdit() {
    var $node = $(this);
    var $span = $node.find('span');
    if ($span.is(":hidden")) {
        return false;
    }
    var $testcase = $node.closest('.testcase');
    var id = $testcase.attr('id').substring(9);
    var $form = $('#result_edit_form form').clone();
    $form.find('.id_field').val(id);
    var $select = $form.find('select');

    var result = $span.text();

    var code = "0";
    if (result == 'Pass') {
        code = "1";
    } else if (result == 'Fail') {
        code = "-1";
    }

    $select.find('option[selected="selected"]').removeAttr("selected");
    $select.find('option[value="' + code + '"]').attr("selected", "selected");

    $node.unbind('click');
    $node.removeClass('edit');

    $form.submit(handleResultSubmit);
    $select.change(function() {
        $select.unbind('blur');
        if ($select.val() == code) {
            $form.detach();
            $span.show();
            $node.addClass('edit');
            $node.click(handleResultEdit);
        } else {
            $form.submit();
        }
    });
    $select.blur(function() {
        $form.detach();
        $span.show();
        $node.addClass('edit');
        $node.click(handleResultEdit);
    });

    $span.hide();
    $form.insertAfter($span);
    $select.focus();

    return false;
}

function handleResultSubmit() {
    var $form = $(this);

    var data = $form.serialize();
    var url = $form.attr('action');

    var $node = $form.closest('td');
    $node.addClass('edit').removeClass('pass fail na').click(handleResultEdit);

    var $span = $node.find('span');
    var result = $form.find('select').val();
    if (result == "1") {
        $node.addClass('pass');
        $span.text('Pass');
    } else if (result == "-1") {
        $node.addClass('fail');
        $span.text('Fail');
    } else {
        $node.addClass('na');
        $span.text('N/A');
    }

    $form.detach();
    $span.show();
    $.post(url, data);

    return false;
}

function handleCommentEdit() {
    var $node = $(this);
    var $div = $node.find('div.content');
    if ($div.is(":hidden")) {
        return false;
    }
    var $testcase = $node.closest('.testcase');
    var $form = $('#comment_edit_form form').clone();
    var $field = $form.find('.comment_field');

    var attachment_url = $div.find('.note_attachment').attr('href') || '';
    var attachment_filename = attachment_url.split('/').pop();

    var $current_attachment = $form.find('div.attachment:not(.add)');
    var $add_attachment = $form.find('div.attachment.add');

    if (attachment_url == '' || attachment_filename == '') {
        $current_attachment.hide();
    }
    else {
        $add_attachment.hide();

        var $attachment_link = $current_attachment.find('#attachment_link');
        $attachment_link.attr('href', attachment_url);
        $attachment_link.html(attachment_filename);

        $current_attachment.find('input').attr('value', attachment_filename);

        $current_attachment.find('.delete').click(function () {
            var $attachment_field = $(this).closest('.field');
            var $current_attachment = $attachment_field.find('div.attachment:not(.add)');
            var $add_attachment = $attachment_field.find('div.attachment.add');

            $current_attachment.hide();
            $current_attachment.find('input').attr('value', '');
            $add_attachment.show();
        });
    }

    var id = $testcase.attr('id').substring(9);
    $form.find('.id_field').val(id);

    var markup = $testcase.find('.comment_markup').text();
    $field.autogrow();
    $field.val(markup);

    $form.submit(handleCommentFormSubmit);
    $form.find('.cancel').click(function() {
        $form.detach();
        $div.show();
        $node.click(handleCommentEdit);
        $node.addClass('edit');
        return false;
    });

    $node.unbind('click');
    $node.removeClass('edit');
    $div.hide();
    $form.insertAfter($div);
    $field.change();
    $field.focus();

    return false;
}

function handleCommentFormSubmit() {
    var $form = $(this);
    var $testcase = $form.closest('.testcase');
    var $div = $testcase.find('.testcase_notes div.content');
    var markup = $form.find('.comment_field').val();

    var data = $form.serialize();
    var url = $form.attr('action');
    $testcase.find('.comment_markup').text(markup);
    var html = formatMarkup(markup);
    $div.html(html);
    $form.hide();
    $div.show();
    $testcase.find('.testcase_notes').click(handleCommentEdit).addClass('edit');

    var options = {datatype: 'xml',
        success: function (responseText, statusText, xhr, $form)  {
            // if the ajaxSubmit method was passed an Options Object with the dataType
            // property set to 'json' then the first argument to the success callback
            // is the json data object returned by the server

            $testcase.find('.testcase_notes').html(responseText);
            fetchBugzillaInfo();
        }
    }
    $form.ajaxSubmit(options);

    return false;
}

function handleTitleEdit() {
    $button = $(this);
    var $content = $button.children('h1').find('span.content');
    if ($content.is(":hidden")) {
        return false;
    }
    var title = $content.text();
    var $form = $('#title_edit_form form').clone();
    var $field = $form.find('.title_field');
    $field.val(title);
    $form.data('original', $content);
    $form.data('button', $button);

    $button.removeClass('editable_text');

    $form.submit(handleTitleEditSubmit);
    $form.find('.save').click(function() {
        $form.submit();
        return false;
    });
    $form.find('.cancel').click(function() {
        $form.detach();
        $content.show();
        $button.addClass('editable_text');
        return false;
    });

    $content.hide();
    $form.insertAfter($content);
    $field.focus();

    return false;
}

function handleTitleEditSubmit() {
    $form = $(this);
    $content = $form.data('original');
    var title = $form.find('.title_field').val();
    $content.text(title);

    var data = $form.serialize();
    var action = $form.attr('action');

    var $button = $form.data('button');
    //$button.text("Saving...");
    $.post(action, data, function() {
        //$button.text("Edit");
    });

    $button.addClass('editable_text');
    $form.detach();
    $content.show();

    return false;
}

function handleDateEdit() {
    $button = $(this);
    var $content = $button.find('span.content').first();
    var $raw = $content.next('span.editmarkup');
    if ($content.is(":hidden")) {
        return false;
    }
    var data = $raw.text();
    var $form = $('#date_edit_form form').clone();
    var $field = $form.find('.date_field');
    $field.val(data);
    $form.data('original', $content).data('raw', $raw).data('button', $button);

    $form.submit(handleDateEditSubmit);
    $form.find('.save').click(function() {
        $form.submit();
        return false;
    });
    $form.find('.cancel').click(function() {
        $form.detach();
        $content.show();
        $button.addClass('editable_text');
        return false;
    });

    $content.hide();
    $form.insertAfter($content);
    $field.focus();
    addDateSelector($field);
    $button.removeClass('editable_text');

    return false;
}

function handleDateEditSubmit() {
    $form = $(this);
    $content = $form.data('original');
    $raw = $form.data('raw');
    var data = $form.find('.date_field').val();
    $raw.text(data);

    var data = $form.serialize();
    var action = $form.attr('action');

    var $button = $form.data('button');
    //$button.text("Saving...");
    $.post(action, data, function(data) {
        $content.text(data);
    });

    $button.addClass('editable_text');
    $form.detach();
    $content.show();

    return false;
}

function removeAttachment(attachment, callback) {
    $.post("/ajax_remove_attachment", {
        id: attachment,
    }, function(data, status){
        if(data.ok==1 && callback!=null) {
            callback.call(this);
        }
    });
};

function toggleRemoveTestCase(eventObject) {
  var $testCaseRow = $(eventObject.target).closest('.testcase');
  var id = $testCaseRow.attr('id').split('-').pop();
  if ($testCaseRow.hasClass('removed')) {
    restoreTestCase(id, function(){});
    linkTestCaseButtons($testCaseRow);
  }
  else {
    removeTestCase(id, function(){});
    unlinkTestCaseButtons($testCaseRow);
  }

  $nftRows = $('.testcase-nft-' + id.toString());
  if ($nftRows.length == 0) {
    $testCaseRow.toggleClass('removed');
  } else {
    $nftRows.toggleClass('removed');
  }

  $testCaseRow.find('.testcase_name').toggleClass('removed');
  $testCaseRow.find('.testcase_name a').toggleClass('remove_list_item');
  $testCaseRow.find('.testcase_name a').toggleClass('undo_remove_list_item');
  $testCaseRow.find('.testcase_notes').toggleClass('edit');
  $testCaseRow.find('.testcase_result').toggleClass('edit');
}

function removeTestCase(id, callback) {
    $.post("/ajax_remove_testcase", {
        id: id
    }, function(data, status) {
        if (data.ok == 1 && callback != null) {
    	     callback.call(this);
    	}
    });
}

function restoreTestCase(id, callback) {
    $.post("/ajax_restore_testcase", {
      id:         id,
    }, function(data, status) {
      if (data.ok == 1 && callback != null) {
        callback.call(this);
      }
    });
}


(function($) {

    /*
     * Auto-growing textareas; technique ripped from Facebook
     */
    $.fn.autogrow = function(options) {

        this.filter('textarea').each(function() {

            var $this = $(this),
                    minHeight = $this.height(),
                    lineHeight = $this.css('lineHeight');

            var shadow = $('<div></div>').css({
                position:   'absolute',
                top:        -10000,
                left:       -10000,
                width:      $(this).width() - parseInt($this.css('paddingLeft')) - parseInt($this.css('paddingRight')),
                fontSize:   $this.css('fontSize'),
                fontFamily: $this.css('fontFamily'),
                lineHeight: $this.css('lineHeight'),
                resize:     'none'
            }).appendTo(document.body);

            var update = function() {

                var times = function(string, number) {
                    var _res = '';
                    for (var i = 0; i < number; i ++) {
                        _res = _res + string;
                    }
                    return _res;
                };

                var val = this.value.replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/&/g, '&amp;')
                        .replace(/\n$/, '<br/>&nbsp;')
                        .replace(/\n/g, '<br/>')
                        .replace(/ {2,}/g, function(space) {
                    return times('&nbsp;', space.length - 1) + ' '
                });

                shadow.html(val);
                $(this).css('height', Math.max(shadow.height() + 20, minHeight));

            }

            $(this).change(update).keyup(update).keydown(update);

            update.apply(this);

        });

        return this;

    }

})(jQuery);

function handleTextEditSubmit() {
    var $form = $(this);
    var $original = $form.data('original');
    var $markup = $form.data('markup');
    var $area = $form.find('textarea');

    var text = $area.val();
    var $button = $form.data("button");
    $button.addClass('editable_text');

    if ($markup.text() == text) {
        // No changes were made.
        $form.detach();
        $original.show();
        return false;
    }

    $markup.text(text);

    var data = $form.serialize();
    var action = $form.attr("action");
    $.post(action, data, function() {});

    $original.html(formatMarkup(text));
    $form.detach();
    $original.show();

    fetchBugzillaInfo();
    return false;
}

function applyBugzillaInfo(node, info) {
    var $node = $(node);
    if (info == undefined) {
        $node.addClass("invalid");
    } else {
        var status = info.status;
        if (status == 'RESOLVED' || status == 'VERIFIED') {
            $node.addClass("resolved");
            status = info.resolution;
        } else {
            $node.addClass("unresolved");
        }

        var text = info.summary;
        if ($node.closest('td.testcase_notes').length != 0) {
            text = text + " (" + status + ")";
            $node.attr("title", text);
        } else if($node.hasClass("bugzilla_append")) {
            text = text + " (" + status + ")";
            $node.after("<span> - "  + text +"</span>");
        } else {
            $node.text(text);
            $node.attr("title", status);
        }
    }
    $node.removeClass("fetch");
}

function fetchBugzillaInfo() {
    var bugIds = [];
    var searchUrl = "/fetch_bugzilla_data";

    var links = $('.bugzilla.fetch');
    links.each(function(i, node) {
        var id = $.trim($(node).text());
        if (id in bugzillaCache) {
            applyBugzillaInfo(node, bugzillaCache[id]);
        } else {
            if ($.inArray(id, bugIds) == -1) bugIds.push(id);
        }
    });

    if (bugIds.length == 0) return;
    $.getJSON(searchUrl, "bugids[]=" + bugIds.toString(), function(data) {
        var hash = [];
        for (var i = 1; i < data.length; i++) {
            var row = data[i];
            var id = row[0];
            var summary = row[1];
            var status = row[2];
            var resolution = row[3];
            hash[id.toString()] = {summary: row[1], status:row[2], resolution:row[3]};
        }

        $('.bugzilla.fetch').each(function(i, node) {
            var info;
            var id = $.trim($(node).text());
            if (id in bugzillaCache) {
                info = bugzillaCache[id];
            } else {
                info = hash[id];
                if (info != undefined) {
                    bugzillaCache[id] = info;
                }
            }
            applyBugzillaInfo(node, info);
        });
    });
}

function formatMarkup(s) {
    s = htmlEscape(s);

    lines = s.split('\n');
    var html = "";
    var ul = false;
    for (var i = 0; i < lines.length; ++i) {
        var line = $.trim(lines[i]);
        if (ul && !/^\*/.test(line)) {
            html += '</ul>';
            ul = false;
        } else if (line == '') {
            html += "<br/>";
        }
        if (line == '') {
            continue;
        }
        line = line.replace(/'''''(.+?)'''''/g, "<b><i>$1</i></b>");
        line = line.replace(/'''(.+?)'''/g, "<b>$1</b>");
        line = line.replace(/''(.+?)''/g, "<i>$1</i>");
        line = line.replace(/http\:\/\/([^\/]+)\/show_bug\.cgi\?id=(\d+)/g, "<a class=\"bugzilla fetch bugzilla_append\" href=\"http://$1/show_bug.cgi?id=$2\">$2</a>");
        line = line.replace(/\[\[(http[s]?:\/\/.+?) (.+?)\]\]/g, "<a href=\"$1\">$2</a>");
        line = line.replace(/\[\[(\d+)\]\]/g, "<a class=\"bugzilla fetch bugzilla_append\" href=\"" + BUGZILLA_URI + "$1\">$1</a>");

        var match;
        line = line.replace(/^====\s*(.+)\s*====$/, "<h5>$1</h5>");
        line = line.replace(/^===\s*(.+)\s*===$/, "<h4>$1</h4>");
        line = line.replace(/^==\s*(.+)\s*==$/, "<h3>$1</h3>");
        match = /^\*(.+)$/.exec(line);
        if (match) {
            if (!ul) {
                html += "<ul>";
                ul = true;
            }
            html += "<li>" + match[1] + "</li>";
        } else if (!/^<h/.test(line)) {
            html += line + "<br/>";
        } else {
            html += line;
        }
    }
    return html;
}

function setTableLoaderSize(tableID, loaderID) {
		t = $(tableID);
//		w = t.width();
		h = t.height();
		$(loaderID).height(h);
	}

function filterResults(rowsToHide, typeText) {
    var updateToggle = function($tbody, $this) {
        var count = $tbody.find("tr:hidden").length;
        if(count > 0) {
            $this.text("+ see " + count + " " + typeText);
        } else {
            $this.text("- hide " + typeText);
        }
        if($tbody.find(rowsToHide).length == 0) {
            $this.hide();
        }
    }

    var updateToggles = function() {
        $("a.see_all_toggle").each(function() {
          $tbody = $(this).parents("tbody").next("tbody");
          updateToggle($tbody, $(this));
        });
    }



    $(".see_feature_build_button").click(function(){
      $("a#detailed_feature.sort_btn").removeClass("active");
      $("#test_results_by_feature").hide();
      $feature_build.show();
      $(this).addClass("active");
      return false;
    });

    $(".see_feature_comment_button").click(function(){
      $("a#detailed_feature.sort_btn").removeClass("active");
      $("#test_feature_build_results").hide();
      $feature_details.show();
      $(this).addClass("active");
      return false;
    });

    $(".see_the_same_build_button").click(function(){
      $("a#detailed_case.sort_btn").removeClass("active");
      $("#detailed_functional_test_results").hide();
      $build.show();
      $build.find(".see_the_same_build_button").addClass("active");
      return false;
    });

    $(".see_history_button").click(function(){
    	//setTableLoaderSize('#detailed_functional_test_results', '#history_loader');
    	//$('#history_loader').show();
    	//history loader should be visible during AJAX loading
      $("a#detailed_case.sort_btn").removeClass("active");
      $("#detailed_functional_test_results").hide();
      $history.show();
      $history.find(".see_history_button").addClass("active");
      return false;
    });

    $(".see_all_button").click(function(){
        $("a#detailed_case.sort_btn").removeClass("active");
        $(this).addClass("active");
        $(rowsToHide).show();
        updateToggles();
        return false;
    });

    $(".see_only_failed_button").click(function(){
        $("a#detailed_case.sort_btn").removeClass("active");
        $(this).addClass("active");
        $(rowsToHide).hide();
        updateToggles();
        return false;
    });

    updateToggles();
    $("a.see_all_toggle").each(function() {
        $(this).click(function(index, item) {
            var $this = $(this);
            $tbody = $this.parents("tbody").next("tbody");
            $tbody.find(rowsToHide).toggle();
            updateToggle($tbody, $this);
            return false;
        });
    });

    var $detail  = $("table.detailed_results").first();
    var $history = $("table.detailed_results.history");
    var $build = $("table.detailed_results.build");
    var $feature_details = $("table.feature_detailed_results").first();
    var $feature_build = $("table.feature_detailed_results_with_build_id")
    $history.find(".see_all_button").click(function(){
        $history.hide();
        $detail.show();
        $detail.find(".see_all_button").click();
    });
    $history.find(".see_only_failed_button").click(function(){
        $history.hide();
        $detail.show();
        $detail.find(".see_only_failed_button").click();
    });
    $history.find(".see_the_same_build_button").click(function(){
        $history.hide();
        $build.show();
        $detail.find(".see_the_same_build_button").click();
    });
    $build.find(".see_all_button").click(function(){
        $build.hide();
        $detail.show();
        $detail.find(".see_all_button").click();
    });
    $build.find(".see_only_failed_button").click(function(){
        $build.hide();
        $detail.show();
        $detail.find(".see_only_failed_button").click();
    });
    $build.find(".see_history_button").click(function(){
        $build.hide();
        $history.show();
        $detail.find(".see_the_history_button").click();
    });
    $feature_build.find(".see_feature_comment_button").click(function(){
        $feature_build.hide();
        $feature_details.show();
        $feature_details.find(".see_feature_comment_button").click();
    });
}
