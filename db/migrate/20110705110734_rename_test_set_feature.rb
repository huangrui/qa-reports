class RenameTestSetFeature < ActiveRecord::Migration
  def self.up
  	rename_table :meego_test_sets, :features
  	rename_column :meego_test_cases, :meego_test_set_id, :feature_id

  end

  def self.down
  	rename_table :features, :meego_test_sets
  	rename_column :meego_test_cases, :feature_id, :meego_test_set_id
  end
end
