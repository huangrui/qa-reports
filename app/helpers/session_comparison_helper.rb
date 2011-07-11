module SessionComparisonHelper
  def comparison_title
    title = @reports[0].target + ' / ' + @reports[0].testset  + ' / ' +
         @reports[0].product +  ' / ' + @reports[0].formatted_date + ' vs. '
    title += @reports[1].target + ' / ' unless @reports[0].target == @reports[1].target
    title += @reports[1].testset  + ' / ' unless @reports[0].testset == @reports[1].testset
    title += @reports[1].product +  ' / ' unless @reports[0].product == @reports[1].product
    title += @reports[1].formatted_date
  end
end
