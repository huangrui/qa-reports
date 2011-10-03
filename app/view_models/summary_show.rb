class SummaryShow

  delegate :id, :total_cases, :total_measured, :total_passed, :total_failed, :total_na,
           :to => :@report

  def initialize(report, build_diff=[])
    @build_diff = build_diff
    @report = report
  end

  def percentage(attribute)
    "%i%%" % ( @report.send(attribute) * 100 ).round
  end

  def count_change(attribute)
    format_change @report.change_from_previous(attribute)
  end

  def percentage_change(attribute)
    format_change( (@report.change_from_previous(attribute) * 100).round, "%" )
  end

  def change_class(attribute)
    case @report.metric_change_direction attribute
      when  0 then "unchanged"
      when  1 then "inc"
      when -1 then "dec"
    end
  end

  def executed_pass_rate_change_class
    return "unchanged" if @report.total_executed == 0 or @report.prev_summary.try(:total_executed) == 0
    change_class :pass_rate_executed
  end

  private

  def format_change(value, postfix="")
    return "" if value == 0
    ("%+i" % value) + postfix
  end

end
