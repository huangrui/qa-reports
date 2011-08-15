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
    if @product
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version, :testset => @testset, :target => @target, :product => @product
    elsif @target
      url_for :controller => "/upload", :action => :upload_form,  :release_version => @selected_release_version, :testset => @testset, :target => @target
    elsif @testset
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version, :testset => @testset
    elsif @selected_release_version
      url_for :controller => "/upload", :action => :upload_form, :release_version => @selected_release_version
    else
      url_for :controller => "/upload", :action => :upload_form
    end
  end

 def breadcrumbs
  html = '<div id="breadcrumb"><li><a href="' + url_for(:controller=>'index', :action=>'index') + '">Home</a></li>'

  html += ('<li> &rsaquo; ' + link_to_unless_current(@target, profile_report_path(@selected_release_version, @target)) + '</li>') if @target
  html += ('<li> &rsaquo; ' + link_to_unless_current(@testset, testset_report_path(@selected_release_version, @target, @testset)) + '</li>') if @testset
  html += ('<li> &rsaquo; ' + link_to_unless_current(@product, product_report_path(@selected_release_version, @target, @testset, @product)) + '</li>') if @product
  html += ('<li> &rsaquo; ' + @test_session.title + '</li>') if @test_session
  html += '</div>'
  html.html_safe
 end

  # FIXME: Cleanup with link_to_unless_current
  def release_version_navigation(current_version, target='', testset='', product='')
    html = '<ul class="clearfix">'
    link_text = ''
    @meego_releases.each do |release|
      if release =~ /\d+\.\d+/
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
        if release == current_version
          html += '<li class="current">'
        else
          html += '<li>'
        end
        link_text = release
      end

      path = release
      if target.present?
        path += '/' + target

        if testset.present?
          path += '/' + testset

          if product.present?
            path += '/' + product
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
      url_for :controller=>'reports',:action=>'view', :release_version=>s.release_version, :target=>s.target, :testset=>s.testset, :product=>s.product, :id=>s.id
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
