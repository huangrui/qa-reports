class ReportComparison

  def initialize(previous, latest)
    @latest, @previous = latest, previous
  end

  def changed_to_pass
    @changed_to_pass ||= find_changed_count(MeegoTestCase::PASS)
  end

  def changed_from_pass
    regression_to_fail + regression_to_na
  end

  def changed_to_fail
    @changed_to_fail ||= find_changed_count(MeegoTestCase::FAIL)
  end

  def changed_to_na
    @changed_to_na ||= find_changed_count(MeegoTestCase::NA)
  end

  def fixed_from_fail
    @fixed_from_fail ||= find_change_count(MeegoTestCase::FAIL, MeegoTestCase::PASS)
  end

  def fixed_from_na
    @fixed_from_na ||= find_change_count(MeegoTestCase::NA, MeegoTestCase::PASS)
  end

  def regression_to_fail
    @regression_to_fail ||= find_change_count(MeegoTestCase::PASS, MeegoTestCase::FAIL)
  end

  def regression_to_na
    @regression_to_na ||= find_change_count(MeegoTestCase::PASS,MeegoTestCase::NA)
  end

  def new_passing
    @new_passed ||= find_new_count(MeegoTestCase::PASS)
  end

  def new_failing
    @new_failed ||= find_new_count(MeegoTestCase::FAIL)
  end

  def new_na
    @new_na ||= find_new_count(MeegoTestCase::NA)
  end

  def test_case_pair(feature, test_case)
    @test_case_pairs ||= make_test_case_pairs

    if @test_case_pairs[feature].nil? || @test_case_pairs[feature][test_case].nil?
      [nil, nil]
    else
      @test_case_pairs[feature][test_case]
    end
  end

  def test_case_changed?(feature, test_case)
    pair = test_case_pair(feature, test_case)
    pair.present? && pair[0].present? && pair[1].present? && pair[0].result != pair[1].result
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

  def find_change_count(from, to)
    rows = test_result_comparisons.find_all do |row|
      row.previous_result == from && row.latest_result == to
    end

    rows.count
  end

  def test_result_comparisons
    @test_result_comparisons ||= find_test_result_comparisons
  end

  def find_new_count(verdict)
    row = new_test_cases.find{|row| row.verdict == verdict }
    row ? row.count : 0
  end

  def find_test_result_comparisons
    find_test_result_comparisons_query = <<-END
      SELECT previous.result AS previous_result, latest.result AS latest_result

      FROM meego_test_cases AS latest
      JOIN meego_test_sets AS l_ts ON ( latest.meego_test_set_id = l_ts.id )

      JOIN (meego_test_cases AS previous
      JOIN meego_test_sets AS p_ts ON ( previous.meego_test_set_id = p_ts.id ))

      ON (LOWER(latest.name), LOWER(l_ts.feature)) = (LOWER(previous.name), LOWER(p_ts.feature))
      WHERE latest.meego_test_session_id = #{@latest.id} AND previous.meego_test_session_id = #{@previous.id};
    END

    MeegoTestCase.find_by_sql(find_test_result_comparisons_query)
  end

  def find_regression_test_cases
    find_regression_test_cases_query = <<-END
      SELECT tc.result as verdict, COUNT(tc.result) as count
      FROM meego_test_cases as tc
      JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )

      -- Test case is in both reports and it passed in the previous one
      WHERE tc.meego_test_session_id = #{@latest.id} AND (LOWER(feature), LOWER(name)) IN (
        SELECT LOWER(ts.feature) as feature, LOWER(tc.name) as name
        FROM meego_test_cases as tc
        JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
        WHERE tc.meego_test_session_id = #{@previous.id} AND tc.result = 1)

      -- The latest result is different than in the previous report
      AND (LOWER(feature), LOWER(name), tc.result) NOT IN (
        SELECT LOWER(ts.feature) as feature, LOWER(tc.name) as name, tc.result as verdict
        FROM meego_test_cases as tc
        JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )
        WHERE tc.meego_test_session_id = #{@previous.id})
      GROUP BY result
      ORDER BY verdict DESC;
    END

    MeegoTestCase.find_by_sql(find_regression_test_cases_query)
  end

  def find_fixed_test_cases
    find_fixed_test_cases_query = <<-END
      SELECT tc.result as verdict, COUNT(tc.result) as count
      FROM meego_test_cases as tc
      JOIN meego_test_sets as ts ON ( tc.meego_test_set_id = ts.id )

      -- Test case passes in the latest report is in both reports
      WHERE tc.meego_test_session_id = #{@latest.id} AND tc.result = 1 AND
          (LOWER(feature), LOWER(name)) IN (
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

    MeegoTestCase.find_by_sql(find_fixed_test_cases_query)
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

  def make_test_case_pairs
    result_pairs = {}

    #group by feature
    previous_cases = @previous.meego_test_cases.group_by { |tc| tc.meego_test_set.feature }
    latest_cases = @latest.meego_test_cases.group_by { |tc| tc.meego_test_set.feature }

    # pair every test case into result
    allfeatures = previous_cases.keys | latest_cases.keys
    allfeatures.each do |feature|
      result_pairs[feature] = {}
      previous_cases[feature] = (previous_cases[feature] || {}).group_by(&:name)
      latest_cases[feature] = (latest_cases[feature] || {}).group_by(&:name)

      all_cases = previous_cases[feature].keys | latest_cases[feature].keys
      all_cases.each do |case_name|
        result_pairs[feature][case_name] =
          [(previous_cases[feature][case_name] || [])[0],
          (latest_cases[feature][case_name] || [])[0]]
      end
    end

    result_pairs
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
