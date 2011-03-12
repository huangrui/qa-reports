class RefactorMeasurementAggregation < ActiveRecord::Migration
  def self.up
    if column_exists? :meego_test_cases, :meego_measurements_count
      remove_column :meego_test_cases, :meego_measurements_count
    end

    add_column :meego_test_cases, :has_nft, :boolean, :default => false, :null => false
    add_column :meego_test_sets, :has_nft, :boolean, :default => false, :null => false
    add_column :meego_test_sessions, :has_nft, :boolean, :default => false, :null => false
    add_column :meego_test_sets, :has_ft, :boolean, :default => true, :null => false
    add_column :meego_test_sessions, :has_ft, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :meego_test_cases, :has_nft
    remove_column :meego_test_sets, :has_nft
    remove_column :meego_test_sessions, :has_nft
    remove_column :meego_test_sets, :has_ft
    remove_column :meego_test_sessions, :has_ft
  end
end
