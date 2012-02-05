class AddSpecialFeatureIdToMeegoTestCase < ActiveRecord::Migration
  def self.up
    add_column :meego_test_cases, :special_feature_id, :integer, :null => false
  end

  def self.down
    remove_column :meego_test_cases, :special_feature_id
  end
end
