class ComparisonReportsController < ApplicationController
  layout "report"

  def show
    #@comparison = ReportComparison.new()
    @selected_release_version = params[:release_version]
    @target = params[:target]
    @testset = params[:testset]
    @comparison_testset = params[:comparetestset]
    @compare_cache_key = "compare_page_#{@selected_release_version}_#{@target}_#{@testset}_#{@comparison_testset}"

    @comparison_report = ComparisonReport.new(@selected_release_version, @target, @testset, @comparison_testset)
    @comparisons = @comparison_report.comparisons
  end

end