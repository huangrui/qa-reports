class RefactorMeasurementAggregation < ActiveRecord::Migration
  def self.up
    if column_exists? :meego_test_cases, :meego_measurements_count
      remove_column :meego_test_cases, :meego_measurements_count
    end

    add_column :meego_test_cases, :has_nft, :integer, :default => 0, :null => false
    add_column :meego_test_sets, :has_nft, :integer, :default => 0, :null => false
    add_column :meego_test_sessions, :has_nft, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :meego_test_cases, :has_nft
    remove_column :meego_test_sets, :has_nft
    remove_column :meego_test_sessions, :has_nft
  end
end
