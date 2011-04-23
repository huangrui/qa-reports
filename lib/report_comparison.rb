class ReportComparison

  def initialize(latest, previous)
    @latest, @previous = latest, previous
  end

  def changed_to_pass
    @changed_to_pass ||= find_changed_count(MeegoTestCase::PASS)
  end

  def changed_to_fail
    @changed_to_fail ||= find_changed_count(MeegoTestCase::FAIL)
  end

  def changed_to_na
    @changed_to_na ||= find_changed_count(MeegoTestCase::NA)
  end

  def new_passed
    @new_passed ||= find_new_count(MeegoTestCase::PASS)
  end

  def new_failed
    @new_failed ||= find_new_count(MeegoTestCase::FAIL)
  end

  def new_na
    @new_na ||= find_new_count(MeegoTestCase::NA)
  end
  
  private

  def new_test_cases
    @new_test_cases ||= find_new_test_cases
  end

  def changed_test_cases
    @changed_test_cases ||= find_changed_test_cases
  end

  def find_changed_count(verdict)
    row = changed_test_cases.find{|row| row.verdict == verdict }
    row ? row.count : 0
  end

  def find_new_count(verdict)
    row = new_test_cases.find{|row| row.verdict == verdict }
    row ? row.count : 0
  end

  def find_changed_test_cases
    find_changed_test_cases_query = <<-END
      SELECT tc.result as verdict, COUNT(tc.result) as count
      FROM meego_test_cases as tc
      JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )

      -- Test case is in both reports
      WHERE tc.meego_test_session_id = #{@latest.id} AND (LOWER(feature), LOWER(name)) IN (
        SELECT LOWER(ts.feature) as feature, LOWER(tc.name) as name
        FROM meego_test_cases as tc
        JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
        WHERE tc.meego_test_session_id = #{@previous.id})

      -- The latest result is different than in the previous report
      AND (LOWER(feature), LOWER(name), tc.result) NOT IN (
        SELECT LOWER(ts.feature) as feature, LOWER(tc.name) as name, tc.result as verdict
        FROM meego_test_cases as tc
        JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
        WHERE tc.meego_test_session_id = #{@previous.id})
      GROUP BY result
      ORDER BY verdict DESC;
    END

    MeegoTestCase.find_by_sql(find_changed_test_cases_query)
  end

  def find_new_test_cases
    find_new_test_cases_query = <<-END
      SELECT tc.result as verdict, COUNT(tc.result) as count
      FROM meego_test_cases as tc
      JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
      WHERE tc.meego_test_session_id = #{@latest.id} 

      -- Test cases is not in the previous report
      AND (LOWER(feature), LOWER(name)) NOT IN (
        SELECT LOWER(ts.feature) as feature, LOWER(tc.name) as name
        FROM meego_test_cases as tc
        JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
        WHERE tc.meego_test_session_id = #{@previous.id})
      GROUP BY result
      ORDER BY verdict DESC;
    END

    MeegoTestCase.find_by_sql(find_new_test_cases_query)
  end
end

#class ComparisonResult
#  include MeegoTestCaseHelper
#
#  attr_reader :left, :right, :changed
#
#  def initialize(left, right, changed)
#    @left    = left
#    @right   = right
#    @changed = changed
#  end
#
#  def name
#    if @left != nil
#      @left.name
#    else
#      @right.name
#    end
#  end
#end
#
#class ComparisonRow
#  def initialize(name)
#    @name   = name
#    @values = {}
#  end
#
#  def value(column)
#    @values[column.downcase] || ComparisonResult.new(nil, nil, false)
#  end
#
#  def add_value(column, value)
#    @values[column.downcase] = value
#  end
#
#  def name
#    @name
#  end
#
#  def changed
#    @values.select { |key, value| value.changed }.length > 0
#  end
#end
#
#class ComparisonGroup
#  def initialize(name)
#    @name = name
#    @rows = {}
#  end
#
#  def name
#    @name
#  end
#
#  def names
#    rows.map { |row| row.name }
#  end
#
#  def rows
#    @rows.values
#  end
#
#  def row(name)
#    rows                 = @rows[name.downcase] || ComparisonRow.new(name)
#    @rows[name.downcase] = rows
#  end
#
#  def changed
#    @rows.select { |key, value| value.changed }.length > 0
#  end
#end
#
#class ReportComparison
#
#  def initialize()
#    @new_failing     = 0
#    @new_passing     = 0
#    @new_na          = 0
#    @changed_to_pass = 0
#    @changed_to_fail = 0
#    @changed_to_na   = 0
#    @groups          = []
#    @columns         = []
#  end
#
#  def columns
#    @columns
#  end
#
#  def add_pair(column, left_report, right_report)
#    return unless right_report and left_report
#    add_column(column)
#    reference = {}
#    if right_report != nil
#      reference = Hash[*right_report.meego_test_cases.collect { |test_case| [test_case.unique_id, test_case] }.flatten]
#    end
#
#    if left_report!=nil
#      @changed_cases = left_report.meego_test_cases.select { |left|
#        right     = reference.delete(left.unique_id)
#        changed = update_summary(left, right)
#        update_group(column, left, right, changed)
#        changed
#      }
#    end
#
#    @changed_cases.push(*reference.values.select { |right|
#      update_summary(nil, right)
#      update_group(column, nil, right, true)
#      true
#    })
#  end
#
#  def changed_to_fail
#    format_result(-@changed_to_fail)
#  end
#
#  def changed_to_pass
#    format_result(@changed_to_pass)
#  end
#
#  def changed_to_na
#    format_result(@changed_to_na)
#  end
#
#  def new_na
#    @new_na.to_s
#  end
#
#  def new_passing
#    @new_passing.to_s
#  end
#
#  def new_failing
#    @new_failing.to_s
#  end
#
#  def changed_test_cases
#    @changed_cases
#  end
#
#  def groups
#    @groups
#  end
#
#  private
#
#  def add_column(column)
#    if !@columns.include?(column)
#      @columns<<column
#    end
#  end
#
#  def format_result(result)
#    if result>0
#      "+" + result.to_s
#    else
#      result.to_s
#    end
#  end
#
#  def update_group(column, left, right, changed)
#    name   = if right!=nil
#               right.meego_test_set.name
#             elsif left!=nil
#               left.meego_test_set.name
#             else
#               "N/A"
#             end
#    group  = @groups.select { |group| group.name.casecmp(name) == 0 }.first || @groups.push(ComparisonGroup.new(name)).last
#    result = ComparisonResult.new(left, right, changed)
#    group.row(result.name).add_value(column, result)
#  end
#
#  def update_summary(left, right)
#    if left == nil
#      case right.result
#        when -1 then
#          @new_failing += 1
#        when 0 then
#          @new_na += 1
#        when 1 then
#          @new_passing += 1
#        else
#          throw :invalid_value
#      end
#    elsif right == nil
#      # test disappeared
#      if left.result == 0
#        return false
#      end
#      @changed_to_na += 1
#    elsif right.result!=left.result
#      case right.result
#        when 1 then
#          @changed_to_pass += 1
#        when 0 then
#          @changed_to_na += 1
#        when -1 then
#          @changed_to_fail += 1
#        else
#          throw :invalid_value
#      end
#    else
#      return false
#    end
#    true
#  end
#end
