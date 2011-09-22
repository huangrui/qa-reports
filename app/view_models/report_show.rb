class ReportShow
  delegate :test_cases, :passed, :failed, :na, :measured, :to => :@report

  def initialize(report)
    @report = report
  end

  def run_rate
    "%0.f%%" % ( @report.run_rate * 100 )
  end

  def pass_rate
    "45%"
  end
end