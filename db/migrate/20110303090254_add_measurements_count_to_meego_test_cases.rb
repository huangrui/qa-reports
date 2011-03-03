class AddMeasurementsCountToMeegoTestCases < ActiveRecord::Migration
  def self.up
    remove_column :meego_test_cases, :measurements_count
    add_column :meego_test_cases, :measurements_count, :integer, :default => 0

    MeegoTestCase.reset_column_information
    MeegoTestCase.find(:all).each do |tc|
      MeegoTestCase.update_counters tc.id, :measurements_count => tc.measurements.length
    end
  end

  def self.down
    remove_column :meego_test_cases, :measurements_count
  end
end
