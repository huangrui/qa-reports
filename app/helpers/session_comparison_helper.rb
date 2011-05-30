module SessionComparisonHelper
  def comparison_title
    title = @reports[0].target + ' / ' + @reports[0].testtype  + ' / ' +
         @reports[0].hardware +  ' / ' + @reports[0].formatted_date + ' vs. '
    title += @reports[1].target + ' / ' unless @reports[0].target == @reports[1].target
    title += @reports[1].testtype  + ' / ' unless @reports[0].testtype == @reports[1].testtype
    title += @reports[1].hardware +  ' / ' unless @reports[0].hardware == @reports[1].hardware
    title += @reports[1].formatted_date
  end
end
