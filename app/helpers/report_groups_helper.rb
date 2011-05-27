module ReportGroupsHelper
  
  def print_with_sign(num)
    num > 0 ? "+" + num.to_s : num
  end
end