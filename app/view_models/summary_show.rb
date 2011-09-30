class SummaryShow

  delegate :id, :total_cases, :total_measured, :total_passed, :total_failed, :total_na,
           :to => :@report

  def initialize(report, build_diff=[])
    @build_diff = build_diff
    @report = report
  end

  def percentage(attribute)
    format_percentage(@report.send attribute)
  end

  # def run_rate
  #   format_percentage(@report.run_rate)
  # end

  # def pass_rate
  #   format_percentage(@report.pass_rate)
  # end

  # def pass_rate_executed
  #   format_percentage(@report.pass_rate_executed)
  # end

  # def nft_index
  #   format_percentage(@report.nft_index)
  # end

  def executed_pass_rate_change_class
    return "unchanged" if @report.total_executed == 0 or @report.prev_summary.try(:total_executed) == 0
    rate_change :pass_rate_executed
  end

  def count_change(attribute)
    formatted_change attribute, "%+i"
  end

  def rate_change(attribute)
    formatted_change attribute, "%+i%%"
  end

  def nft_index_change
    formatted_change :nft_index, "%+.0f%%"
  end

  def change_class(attribute)
    case @report.metric_change_direction attribute
      when  0 then "unchanged"
      when  1 then "inc"
      when -1 then "dec"
    end
  end

  private

  def format_percentage(value)
    "%0.f%%" % ( value * 100 )
  end

  def formatted_change(attribute, format)
    change = @report.change_from_previous(attribute)

    return "" if change == 0

    format % change
  end

end
