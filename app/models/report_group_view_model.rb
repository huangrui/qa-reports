require 'report_comparison'
require 'graph'

class ReportGroupViewModel
  include Graph

  def initialize(release, target, testtype, hardware)
    @params = {
      :version_labels => {:label => release},
      :target => target,
      :testtype => testtype,
      :hardware => hardware
    }.delete_if { |key, value| value.nil? }
  end

  def all_reports
    @all_reports ||= find_all_reports
  end

  def reports_by_range(range)
    @report_ranges ||= {}
    @report_ranges[range] ||= find_report_range(range)
  end

  def reports_by_month
    @reports_by_month ||= all_reports.group_by(&:month)
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

  def latest
    reports_by_range((0..1))[0] rescue nil
  end

  def previous
    reports_by_range((0..1))[1] rescue nil
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
      includes(:version_label, :meego_test_cases).
      joins(:version_label).
      where(@params).order("tested_at DESC, created_at DESC")
  end

  def find_max_cases
    MeegoTestSession.published.
      joins(:version_label, :meego_test_cases).where(@params).
      count(:group=>:meego_test_session_id, :order => 'count_all DESC', :limit => 1).
      values.first
  end

  def find_report_range(range)
    MeegoTestSession.published.includes(:version_label, :meego_test_cases).
      joins(:version_label).where(@params).
      limit(range.count).offset(range.begin).
      order("tested_at DESC, created_at DESC")
  end
end