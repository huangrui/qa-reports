require 'report_comparison'

class ReportGroupViewModel

  def initialize(release, target, testtype, hwproduct)
    @params = { 
      :version_labels => {:label => release},
      :target => target,
      :testtype => testtype,
      :hwproduct => hwproduct
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
    @comparison ||= ReportComparison.new(latest, previous) if has_comparison?
  end

  def max_cases
    @max_cases ||= find_max_cases
  end

  private

  def latest
    reports[0] if reports.count > 0
  end

  def previous
    reports[1] if reports.count > 1
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