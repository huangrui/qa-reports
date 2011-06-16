module ReportGroupsHelper

  def print_with_sign(num)
    num > 0 ? "+" + num.to_s : num
  end

  def compare_latest_to_previous_url
    session_comparison_path(@group_report.previous.id, @group_report.latest.id)
  end
end