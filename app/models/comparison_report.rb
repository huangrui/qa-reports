require 'report_comparison'
require 'lib/array_nested_hashing'

class ComparisonReport
  attr_reader :test_cases, :products

  def features
    @test_cases.keys
  end

  def comparisons
    @comparisons
  end

  def result_changed?(feature, test_case)
    @comparisons.each_value do |comparison|
      return true if comparison.result_changed?(feature, test_case)
    end

    return false
  end

  def changed_to_pass
    @comparisons.map{|k, v| v.changed_to_pass}.reduce(:+)
  end

  def changed_from_pass
    @comparisons.map{|k, v| v.changed_from_pass}.reduce(:+)
  end

  def changed_to_fail
    @comparisons.map{|k, v| v.changed_to_fail}.reduce(:+)
  end

  def changed_to_na
    @comparisons.map{|k, v| v.changed_to_na}.reduce(:+)
  end

  def fixed_from_fail
    @comparisons.map{|k, v| v.fixed_from_fail}.reduce(:+)
  end

  def fixed_from_na
    @comparisons.map{|k, v| v.fixed_from_na}.reduce(:+)
  end

  def regression_to_fail
    @comparisons.map{|k, v| v.regression_to_fail}.reduce(:+)
  end

  def regression_to_na
    @comparisons.map{|k, v| v.regression_to_na}.reduce(:+)
  end

  def new_passing
    @comparisons.map{|k, v| v.new_passing}.reduce(:+)
  end

  def new_failing
    @comparisons.map{|k, v| v.new_failing}.reduce(:+)
  end

  def new_na
    @comparisons.map{|k, v| v.new_na}.reduce(:+)
  end

  def initialize(release, profile, test_set, comparison_test_set)
    comparison_scope = MeegoTestSession.release(release).profile(profile)
    hw_scope = comparison_scope.select("DISTINCT(product) as product")

    @products = (
      hw_scope.testset(test_set).merge(hw_scope.testset(comparison_test_set))
      ).map{ |row| row.product }

    @reports = []
    @test_cases = []
    @comparisons = {}

    @products.each do |product|
      r1 = comparison_scope.includes(:features, :meego_test_cases).
        testset(test_set).product_is(product).latest

      r2 = comparison_scope.includes(:features, :meego_test_cases => :feature).
        testset(comparison_test_set).product_is(product).latest

      @reports << r1 << r2
      @test_cases += r1.meego_test_cases.sort_by(&:id) + r2.meego_test_cases.sort_by(&:id)
      @comparisons[product] = ReportComparison.new(r1, r2)
    end

    @test_cases = @test_cases.to_nested_hash [:feature_key, :name, :product_key], :unique => false
  end

end
