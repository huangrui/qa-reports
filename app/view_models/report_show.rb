class ReportShow
  delegate :test_cases, :passed, :failed, :na, :measured, :to => :@report

  def initialize(report)
    @report = report
  end

  def run_rate
    format_percentage(@report.run_rate)
  end

  def pass_rate
    format_percentage(@report.pass_rate)
  end

  def pass_rate_executed
    format_percentage(@report.pass_rate_executed)
  end

  def nft_index
    format_percentage(@report.nft_index)
  end

  private

  def format_percentage(value)
    "%0.f%%" % ( value * 100 )
  end

end
