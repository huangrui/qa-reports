module SessionComparisonHelper
  def comparison_title
    if @reports[0].build_id == @reports[1].build_id
      title = @reports[0].profile.name + ' / ' + @reports[0].testset  + ' / ' +
         @reports[0].product +  ' / ' + @reports[0].formatted_date + ' vs. '
    else
      title = @reports[0].profile.name + ' / ' + @reports[0].testset  + ' / ' +
         @reports[0].product +  ' / ' + @reports[0].build_id + ' vs. '
    end
    title += @reports[1].profile.name + ' / ' unless @reports[0].profile.name == @reports[1].profile.name
    title += @reports[1].testset  + ' / ' unless @reports[0].testset == @reports[1].testset
    title += @reports[1].product +  ' / ' unless @reports[0].product == @reports[1].product
    if @reports[0].build_id == @reports[1].build_id
      title += @reports[1].formatted_date
    else
      title += @reports[1].build_id
    end
  end
end
