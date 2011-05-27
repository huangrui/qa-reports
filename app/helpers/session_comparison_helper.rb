module SessionComparisonHelper
  def compare_latest_to_previous_url
    session_comparison_path(@selected_release_version, @target, @testtype, @hardware,
        @group_report.previous, @group_report.latest)
  end
end
