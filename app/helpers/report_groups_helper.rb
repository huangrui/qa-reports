module ReportGroupsHelper

  def print_with_sign(num)
    num > 0 ? "+" + num.to_s : num
  end

  def build_list_path(rel, pro, bid, tes, prd)
    path = report_list_path(rel, pro, tes, prd)
    offset = path.index('/', 1)
    build_path = '/build/' + bid
    path.insert(offset, build_path)
  end

  def compare_latest_to_previous_url
    session_comparison_path(@group_report.previous.id, @group_report.latest.id)
  end
end
