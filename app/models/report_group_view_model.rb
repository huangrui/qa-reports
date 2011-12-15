require 'report_comparison'
require 'graph'

class ReportGroupViewModel
  include Graph

  def initialize(release_name, profile_name, testset, product)
    @params = {
      :release_id => Release.find_by_name(release_name),
      :profile_id => Profile.find_by_name(profile_name),
      :testset => testset,
      :product => product
    }.delete_if { |key, value| value.nil? }

    raise ActiveRecord::RecordNotFound if MeegoTestSession.published.where(@params).count == 0
  end

  def all_reports
    @all_reports ||= find_all_reports
  end

  def reports_by_range(range, by_build=nil)
    @report_ranges ||= {}
    @report_ranges[range] ||= find_report_range(range, by_build)
  end

  def report_object(report)
    { :date => report.format_date,
      :name => report.title,
      :htmlgraph => {
        :passes => report.total_passed,
        :fails  => report.total_failed,
        :nas    => report.total_na },
      :year => report.format_year,
      :release => report.release.name,
      :target => report.profile.name,
      :testset => report.testset,
      :product => report.product,
      :build_id => report.build_id,
      :id => report.id }
  end

#  def report_range_by_month(range)
#    reports_by_range(range).group_by(&:month).map do |month, reports|
#      { :name => month,
#        :reports => reports.map { |report| report_object(report) } }
#    end
#  end

  def report_range_by_build(range)
    reports_by_range(range, 1).group_by(&:build_id).map do |build_id, reports|
      { :name => build_id,
        :reports => reports.map { |report| report_object(report) } }
    end
  end

  def has_comparison?
    !latest.nil? && !previous.nil?
  end

  def comparison
    @comparison ||= ReportComparison.new(previous, latest) if has_comparison?
  end

  def max_cases
    @max_cases ||= find_max_cases
  end

  def trend_graph_data_abs
    @trend_graph_data_abs ||= calculate_trend_graph_data(false)
  end

  def trend_graph_data_rel
    @trend_graph_data_rel ||= calculate_trend_graph_data(true)
  end

  # If order by build id ,please set second argument as 1 for comparision the latest reports
  def latest
    reports_by_range((0..1), 1)[0] rescue nil
  end

  def previous
    reports_by_range((0..1), 1)[1] rescue nil
  end

  private

  def calculate_trend_graph_data (relative)
    trend_length = 20

    chosen, days = find_trend_sessions(reports_by_range((0..trend_length - 1)), trend_length)

    if chosen.length > 0
      generate_trend_graph_data(chosen, days, relative, trend_length)
    end
  end

  def find_all_reports
    MeegoTestSession.published.
      includes(:release).
      where(@params).order("tested_at DESC, created_at DESC")
  end

  def find_max_cases
    MeegoTestSession.published.
      joins(:meego_test_cases).where(@params).
      count(:group=>:meego_test_session_id, :order => 'count_all DESC', :limit => 1).
      values.first
  end

  def find_report_range(range,by_build)
    if by_build.nil?
      reports = MeegoTestSession.published.includes(:release).
        where(@params).
        limit(range.count).offset(range.begin).
        order("tested_at DESC, created_at DESC")
    else
      reports = MeegoTestSession.published.includes(:release).
        where(@params).
        limit(range.count).offset(range.begin).
        order("build_id DESC, tested_at DESC, created_at DESC")
    end

    # TODO: Could reports just be wrapped in ReportShows that have the count methods?
    #       Or use directly the association count calls e.g. passed.count.
    MeegoTestSession.load_case_counts_for_reports! reports
  end
end

