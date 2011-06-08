class ComparisonReportsController < ApplicationController
  layout "report"

  def show
    #@comparison = ReportComparison.new()
    @selected_release_version = params[:release_version]
    @target = params[:target]
    @testtype = params[:testtype]
    @comparison_testtype = params[:comparetype]
    @compare_cache_key = "compare_page_#{@selected_release_version}_#{@target}_#{@testtype}_#{@comparison_test_type}"

    @comparison_report = ComparisonReport.new(@selected_release_version, @target, @testtype, @comparison_testtype)
    @comparisons = @comparison_report.comparisons
  end

end