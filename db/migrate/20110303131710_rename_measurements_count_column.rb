class RenameMeasurementsCountColumn < ActiveRecord::Migration
  def self.up
    rename_column :meego_test_cases, :measurements_count, :meego_measurements_count
  end

  def self.down
    rename_column :meego_test_cases, :meego_measurements_count, :measurements_count
  end
end
