require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @selected_release_version, @target, @testset, @hardware =
      params[:release_version], params[:target], params[:testset], params[:hardware]
    @show_rss = true

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testset, @hardware)
  end

  def report_page
    @reports_per_page = 40
    @page = [1, params[:page].to_i].max rescue 1
    @page_index = @page - 1 
    @selected_release_version, @target, @testset, @hardware =
      params[:release_version], params[:target], params[:testset], params[:hardware]

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testset, @hardware)
    offset = @reports_per_page * @page_index
    @report_range = (offset..offset + @reports_per_page - 1)

    unless @group_report.reports_by_range(@report_range).empty?
      render :partial=>'report', :collection=>@group_report.reports_by_range(@report_range)
    else
      render :text=>''
    end
  end

end