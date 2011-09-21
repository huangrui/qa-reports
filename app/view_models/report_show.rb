class ReportShow

  def initialize(report)
    @report = report
  end

  def run_rate
    "%0.f%%" % @report.run_rate
  end

end