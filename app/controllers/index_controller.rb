#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#          Jarno Keskikangas <jarno.keskikangas@leonidasoy.fi>
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
require 'graph'
class IndexController < ApplicationController
  include Graph
  
  #caches_page :index, :filtered_list
  caches_action :filtered_list, :layout => false, :expires_in => 1.hour

  def index
    @types = {}
    MeegoTestSession::targets.each{|target|
      @types[target] = MeegoTestSession.list_types_for @selected_release_version, target
    }
    @hardware = MeegoTestSession.list_hardware @selected_release_version
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]
    @show_rss = true
  end

  def filtered_list
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]
    @show_rss = true

    unless MeegoTestSession.filters_exist?(@target, @testtype, @hwproduct)
      return render_404
    end

    if @hwproduct
      sessions = MeegoTestSession.by_release_version_target_test_type_product(@selected_release_version, @target, @testtype, @hwproduct)
    elsif @testtype
      sessions = MeegoTestSession.published_by_release_version_target_test_type(@selected_release_version, @target, @testtype)
    else
      sessions = MeegoTestSession.published_by_release_version_target(@selected_release_version, @target)
    end

    current_page = if params[:page].to_i <= 0 then 1 else params[:page].to_i end
    per_page = 50
    
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Prev'
    WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next'    
    
    @paginated_sessions = WillPaginate::Collection.create(current_page, per_page, sessions.count()) do |pager|
      pager.replace(sessions.all(:offset => ((current_page-1) * per_page), :limit => per_page))
    end

    sessions = @paginated_sessions

    @headers = []
    @sessions = {}

    chosen, days = find_trend_sessions(sessions, 20)

    if chosen.length > 0
      #@trend_graph_url_abs = generate_trend_graph_lines(chosen, days, false)
      #@trend_graph_url_rel = generate_trend_graph_lines(chosen, days, true)
      #@trend_graph_url_abs = generate_trend_graph_stacked_bars(chosen, days, false)
      #@trend_graph_url_rel = generate_trend_graph_stacked_bars(chosen, days, true)
      #@trend_graph_url_abs = generate_trend_graph_grouped_bars(chosen, days, false)
      #@trend_graph_url_rel = generate_trend_graph_grouped_bars(chosen, days, true)
      #@trend_graph_url_abs = generate_trend_graph_area(chosen, days, false)
      #@trend_graph_url_rel = generate_trend_graph_area(chosen, days, true)

      @trend_graph_data_abs = generate_trend_graph_data(chosen, days, false, 20)
      @trend_graph_data_rel = generate_trend_graph_data(chosen, days, true, 20)

    end

    @changed_to_pass = "%+d" % (sessions[0].total_passed - sessions[1].total_passed)
    @changed_to_fail = "%+d" % (sessions[0].total_failed - sessions[1].total_failed)
    @changed_to_na = "%+d" % (sessions[0].total_na - sessions[1].total_na)
    @total_passed = sessions.first.total_passed
    @total_failed = sessions.first.total_failed
    @total_na = sessions.first.total_na

    @max_cases = 0

    sessions.each do |s|
      @max_cases = s.total_cases if s.total_cases > @max_cases
      header = s.tested_at.strftime("%B %Y")
      unless @sessions.has_key? header
        @headers << header
        (@sessions[header] = []) << s
      else
        @sessions[header] << s
      end
    end

  end
end
