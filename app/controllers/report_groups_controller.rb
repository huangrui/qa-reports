require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @show_rss = true

    @group_report = ReportGroupViewModel.new(release, profile, testset, product)
    @monthly_data = @group_report.report_range_by_month(0..39).to_json
    respond_to { |format| format.html }
  end

  def report_page
    @reports_per_page = 40
    @page = [1, params[:page].to_i].max rescue 1
    @page_index = @page - 1

    @group_report = ReportGroupViewModel.new(release, profile, testset, product)
    offset = @reports_per_page * @page_index
    @report_range = (offset..offset + @reports_per_page - 1)

    unless @group_report.reports_by_range(@report_range).empty?
      render :json => @group_report.report_range_by_month(@report_range)
    else
      render :text => ''
    end
  end

end