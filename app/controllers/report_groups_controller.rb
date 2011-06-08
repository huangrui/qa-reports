require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @selected_release_version, @target, @testtype, @hardware =
      params[:release_version], params[:target], params[:testtype], params[:hardware]
    @show_rss = true

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testtype, @hardware)
    @report_range = (0..19)
  end

  def report_range
    @selected_release_version, @target, @testtype, @hardware =
      params[:release_version], params[:target], params[:testtype], params[:hardware]

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testtype, @hardware)
    offset = 20 * (params[:page].to_i - 1) rescue 0
    @report_range = (offset..offset + 19)
    unless @group_report.reports_by_range(@report_range).empty?
      render :partial=>'report', :collection=>@group_report.reports_by_range(@report_range)
    else
      render :text=>''
    end
  end

end