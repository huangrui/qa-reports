class AddIndexForSpecFea < ActiveRecord::Migration
  def self.up
    add_index :meego_test_cases, :special_feature_id

    add_index :special_features, :name
    add_index :special_features, :feature_id
    add_index :special_features, :meego_test_session_id
  end

  def self.down
    remove_index :meego_test_cases, :special_feature_id

    remove_index :special_features, :name
    remove_index :special_features, :feature_id
    remove_index :special_features, :meego_test_session_id
  end
end
