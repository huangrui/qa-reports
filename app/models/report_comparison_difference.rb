class ReportComparisonDifference < ActiveRecord::Base
  set_table_name 'meego_test_cases'

  def result_to
    if self[:latest_result].present?
      self[:latest_result].to_i
    else
      self[:verdict].to_i rescue nil
    end
  end

  def result_from
    self[:previous_result].to_i unless self[:previous_result].nil?
  end

  def count
    self[:count].to_i
  end

end