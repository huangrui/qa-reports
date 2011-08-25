require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @selected_release_version, @target, @testset, @product =
      params[:release_version], params[:target], params[:testset], params[:product]
    @show_rss = true

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testset, @product)

    respond_to { |format| format.html }
  end

  def report_page
    @reports_per_page = 40
    @page = [1, params[:page].to_i].max rescue 1
    @page_index = @page - 1
    @selected_release_version, @target, @testset, @product =
      params[:release_version], params[:target], params[:testset], params[:product]

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testset, @product)
    offset = @reports_per_page * @page_index
    @report_range = (offset..offset + @reports_per_page - 1)

    unless @group_report.reports_by_range(@report_range).empty?
      render :partial=>'report', :collection=>@group_report.reports_by_range(@report_range)
    else
      render :text=>''
    end
  end

end