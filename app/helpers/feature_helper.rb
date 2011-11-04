module FeatureHelper

  GRADES = {0 => "Block", 1 => "Red", 2 => "Yellow", 3 => "Green"}

  def grading_to_str(value)
    GRADES[value]
  end

  def grading_html(model)
    if model==nil
        return "Block"
    end
    grading_to_str model.grading
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
