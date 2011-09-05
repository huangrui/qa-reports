module MeegoTestCaseHelper

  RESULTS = {-1 => "Fail", 0 => "N/A", 1 => "Pass"}

  def result_to_txt(result)
    RESULTS[result] or "N/A"
  end

  def result_html(model)
    return "N/A" unless model
    result_to_txt(model.result)
  end

  def hide_passing(model)
    if model==nil
      return ""
    end
    if model.result == 1
      "display:none;"
    else
      ""
    end
  end


  def result_class(model, prefix = "")
    if model==nil
      return prefix + "na"
    end

    case model.result
      when 1
        prefix + "pass"
      when -1
        prefix + "fail"
      else
        prefix + "na"
    end
  end

  def comment_html(model)
    if model==nil
      return nil
    end
    model.comment ? MeegoTestReport::format_txt(model.comment).html_safe : nil
  end
end
