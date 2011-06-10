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

module ApplicationHelper
  def row_class(index)
    if (index % 2) == 0
      ' even '
    else
      ' odd '
    end
  end

  def upload_full_path
    if @hardware
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version, :testtype => @testtype, :target => @target, :hardware => @hardware
    elsif @target
      url_for :controller => "/upload", :action => :upload_form,  :release_version => @selected_release_version, :testtype => @testtype, :target => @target
    elsif @testtype
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version, :testtype => @testtype
    elsif @selected_release_version
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version
    else
      url_for :controller => "/upload", :action => :upload_form
    end
  end

  def compare_for(target, testtype)
    MeegoTestSession.list_hardware_for(@selected_release_version, target, testtype)
  end

  def hardware_for(target, testtype)
    MeegoTestSession.list_hardware_for(@selected_release_version, target, testtype)
  end

 def breadcrumbs
  html = '<div id="breadcrumb"><li><a href="' + url_for(:controller=>'index', :action=>'index') + '">Home</a></li>'

  html += ('<li> &rsaquo; ' + link_to_unless_current(@target, profile_report_path(@selected_release_version, @target)) + '</li>') if @target
  html += ('<li> &rsaquo; ' + link_to_unless_current(@testtype, test_type_report_path(@selected_release_version, @target, @testtype)) + '</li>') if @testtype
  html += ('<li> &rsaquo; ' + link_to_unless_current(@hardware, hardware_report_path(@selected_release_version, @target, @testtype, @hardware)) + '</li>') if @hardware
  html += ('<li> &rsaquo; ' + @test_session.title + '</li>') if @test_session
  html += '</div>'
  html.html_safe
 end

  # FIXME: Cleanup with link_to_unless_current
  def release_version_navigation(current_version, target='', testtype='', hardware='')
    html = '<ul class="clearfix">'
    link_text = ''
    @meego_releases.each do |release|
      if release =~ /^[0-9]/
        if release == current_version
            html += '<li class="current">'
            link_text = "MeeGo v#{release}"
        else
            html += '<li>'
            link_text = "v#{release}"
        end
      elsif release =~ /^[A-Za-z][0-9]$/
        if release.downcase.eql? current_version.downcase
          html += '<li class="current">'
          link_text = "MeeGo #{release}"
        else
          html += '<li>'
          link_text = "#{release}"
        end
      else
        html += '<li>'
        if release == current_version
          html += '<li>'
          html += '<li class="current">'
        else
          html += '<li>'
        end
        link_text = release
      end

      path = release
      if target.present?
        path += '/' + target

        if testtype.present?
          path += '/' + testtype

          if hardware.present?
            path += '/' + hardware
          end
        end
      end

      html += link_to link_text, root_url + path
      html += '</li>'
    end

    html += '</ul>'
    html.html_safe
  end

  def report_url(s)
      url_for :controller=>'reports',:action=>'view', :release_version=>s.release_version, :target=>s.target, :testtype=>s.testtype, :hardware=>s.hardware, :id=>s.id
  end

  def format_date_to_human_readable(date)
    date ? date.strftime('%d %B %Y') : 'n/a'
  end

  def format_date_to_input(date)
    date ? date.strftime('%Y-%m-%d') : ''
  end

  def use_nokia_layout?
    request.host.include? "maemo" or request.host.include? "nokia"
  end

  def html_graph(passed, failed, na, max_cases)
    pw = passed*386/max_cases
    fw = failed*386/max_cases
    nw = na*386/max_cases
    "<div class=\"htmlgraph\"><div class=\"passed\" width=\"#{pw}\"/><div class=\"failed\ width=\"#{fw}\"/><div class=\"na\" width=\"#{nw}\"/></div>"
  end

  def ints2js(ints)
    ('[' + ints.map{|v| v.to_s}.join(",") + ']').html_safe
  end

  def strs2js(strings)
    ('[' + strings.map{|s| "\"#{s}\""}.join(",") + ']').html_safe
  end

  def google_analytics_tag
    # only run analytics on the official server
    if request.host.include? "qa-reports.meego.com"
      render :partial => 'shared/google_analytics'
    end
  end

  def clicktale_top_tag
    # only run clicktale on the official server
    if request.host.include? "qa-reports.meego.com"
      render :partial => 'shared/clicktale_top'
    end
  end

  def clicktale_bottom_tag
    # only run clicktale on the official server
    if request.host.include? "qa-reports.meego.com"
      render :partial => 'shared/clicktale_bottom'
    end
  end

  def form_ajax_error_msg(cls)
    "<div style=\"display:none\" class=\"error #{cls}\">&nbsp;</div>".html_safe
  end

  def cache_if(condition, name, &block)
    if condition
      cache(name, &block)
    else
      yield
    end
  end

end
