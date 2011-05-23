class ComparisonReportsController < ApplicationController
  layout "report"

  def show
    #@comparison = ReportComparison.new()
    @release_version = params[:release_version]
    @target = params[:target]
    @testtype = params[:testtype]
    @comparison_testtype = params[:comparetype]
    @compare_cache_key = "compare_page_#{@release_version}_#{@target}_#{@testtype}_#{@comparison_test_type}"

#    MeegoTestSession.published_hwversion_by_release_version_target_test_type(@release_version, @target, @testtype).each{|hardware|
#        left = MeegoTestSession.by_release_version_target_test_type_product(@release_version, @target, @testtype, hardware.hwproduct).first
#        right = MeegoTestSession.by_release_version_target_test_type_product(@release_version, @target, @comparison_testtype, hardware.hwproduct).first
#        @comparison.add_pair(hardware.hwproduct, left, right)
#    }
#    @groups = @comparison.groups

    @comparison_report = ComparisonReport.new(@release_version, @target, @testtype, @comparison_testtype)
    @comparisons = @comparison_report.comparisons
  end

end