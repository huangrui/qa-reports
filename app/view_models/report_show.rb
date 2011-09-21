class ReportShow

  def initialize(meego_test_session)
    @meego_test_session = meego_test_session
  end

  def run_rate
    run_rate = 0.81828282*100
    "%0.f%%" % run_rate
  end

end