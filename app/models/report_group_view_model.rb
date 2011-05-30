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

  def reports
    @reports ||= find_reports
  end

  def reports_by_month
    @reports_by_month ||= reports.group_by(&:month)
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
    reports[0] if reports.count > 0
  end

  def previous
    reports[1] if reports.count > 1
  end

  private

  def calculate_trend_graph_data (relative)
    chosen, days = find_trend_sessions(reports, 20)

    if chosen.length > 0
      generate_trend_graph_data(chosen, days, relative, 20)
    end
  end

  def find_reports
    MeegoTestSession.published.
      includes(:version_label, :meego_test_cases).
      joins(:version_label).
      where(@params).order("tested_at DESC")
  end

  def find_max_cases
    max_cases_query = <<-END
      SELECT COUNT(id) as count
      FROM meego_test_cases
      WHERE meego_test_session_id IN (#{reports.map{|report| report.id}.join(",")})
      GROUP BY meego_test_session_id
      ORDER BY count DESC
      LIMIT 1;
    END

    MeegoTestCase.find_by_sql(max_cases_query).first.count
  end
end