require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @show_rss = true

    @group_report = ReportGroupViewModel.new(release.name, profile.name, testset, product, build_id)
    @monthly_data = @group_report.report_range_by_build(0..39).to_json
    respond_to { |format| format.html }
  end

  def build_show
    @show_rss = true

    @group_report = ReportGroupViewModel.new(release.name, profile.name, testset, product, build_id)
    @monthly_data = @group_report.report_range_by_build(0..39).to_json
    respond_to { |format| format.html }
  end

  def report_page
    @reports_per_page = 40
    @page = [1, params[:page].to_i].max rescue 1
    @page_index = @page - 1

    @group_report = ReportGroupViewModel.new(release.name, profile.name, testset, product, build_id)
    offset = @reports_per_page * @page_index
    @report_range = (offset..offset + @reports_per_page - 1)

    # If order by build id, please set the second argument as 1
    unless @group_report.reports_by_range(@report_range, 1).empty?
      render :json => @group_report.report_range_by_build(@report_range)
    else
      render :text => ''
    end
  end

end
