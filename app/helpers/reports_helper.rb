#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA
#

require 'report_parser'

module ReportsHelper

  def contain_history(hist)
    if hist
      hist.each do |h|
        if h
          return true 
        end
      end
    end
    return false
  end

  def edit_button
    if @editing
      '<a href="" class="edit">Edit</a>'.html_safe
    end
  end

  def back_to_top
    unless @email
      '<a href="#top">Back to top</a>'.html_safe
    end
  end

  def editable_txt(field)
    html_field = field+'_html'
    txt_field  = field+'_txt'
    html       = '<div class="editcontent" id="' +txt_field+ '">' + \
      @report.send(html_field) + '</div>'

    if @editing
      html += '<div class="editmarkup" style="display:none;">' + \
        @report.send(txt_field) + '</div>'
    end

    html.html_safe
  end

  def print_title_link(title)
    if bugzilla_title?(title)
      ('<a class="bugzilla fetch" target="_blank" href="' + BUGZILLA_CONFIG['link_uri']+title+'">' + title + '</a>').html_safe
    else
      title
    end
  end

  def print_title(title)
    if bugzilla_title?(title)
      ('<span class="bugzilla fetch">' + title + '</span>').html_safe
    else
      title
    end
  end

  def rss_path
    request.env['PATH_INFO'] + "/rss"
  end


  def history_headers(hist)
    hist.reverse.map{|s|
      if s
        date = s.tested_at.strftime("%d/%m")
        url  = report_url(s)
        "<th class=\"th_history_result\"><a href=\"#{url}\">#{date}</a></th>"
      else
        "<th class=\"th_history_result\">-</th>"
      end
    }.join("\n").html_safe
  end

  def build_id_headers(hist)
    hist.reverse.map{|s|
      if s
        session_build_id = s.build_id
        url  = report_url(s)
        "<th class=\"th_build_result\"><a href=\"#{url}\">#{session_build_id}</a></th>"
      else
        "<th class=\"th_build_result\">-</th>"
      end
    }.join("\n").html_safe
  end

  def build_pass_rate_headers(hist)
    hist.reverse.map{|s|
      if s
        session_build_id = s.build_id
        url  = report_url(s)
        "<th class=\"th_history_result\"><a href=\"#{url}\">#{session_build_id}</a></th>"
      else
        "<th class=\"th_history_result\">-</th>"
      end
    }.join("\n").html_safe
  end

private

  def bugzilla_title?(title)
    result = ReportParser::parse_features(title)
    result.length != 1 || result.first.is_a?(Fixnum)
  end

end
