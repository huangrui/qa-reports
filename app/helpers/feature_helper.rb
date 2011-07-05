module FeatureHelper
  def grading_html(model)
        if model==nil
            return "N/A"
        end
        case model.grading
          when 1
            "Red"
          when 2
            "Yellow"
          when 3
            "Green"
          else
            "N/A"
        end
  end

  def grading_class(model, prefix = "")
    if model==nil
      return prefix + "grading_white"
    end

    case model.grading
      when 1
        prefix + "grading_red"
      when 2
        prefix + "grading_yellow"
      when 3
        prefix + "grading_green"
      else
        prefix + "grading_white"
    end
  end
end
