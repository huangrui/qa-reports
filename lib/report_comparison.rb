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
