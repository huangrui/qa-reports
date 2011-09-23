class ComparisonReportsController < ApplicationController
  layout "report"

  def show
    @comparison_testset = params[:comparetestset]
    @compare_cache_key  = "compare_page_#{release.name}_#{profile.label}_#{testset}_#{@comparison_testset}"
    @comparison_report  = ComparisonReport.new(release.name, profile.label, testset, @comparison_testset)
    @comparisons        = @comparison_report.comparisons
  end

end
