module MeegoTestCaseHelper

  RESULTS = {MeegoTestCase::FAIL      => "Fail",
             MeegoTestCase::NA        => "Block",
             MeegoTestCase::PASS      => "Pass",
             MeegoTestCase::MEASURED  => "Measured"}

  def result_to_txt(result)
    RESULTS[result] or "Block"
  end

  def result_html(model)
    return "Block" unless model
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
    return prefix + MeegoTestSession.result_as_string(MeegoTestCase::NA) if model.nil?

    prefix + MeegoTestSession.result_as_string(model.result)
  end

  def comment_html(model)
    (model.present? && model.comment) ? MeegoTestReport::format_txt(model.comment).html_safe : nil
  end
end
