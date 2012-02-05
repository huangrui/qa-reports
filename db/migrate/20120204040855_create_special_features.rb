class CreateSpecialFeatures < ActiveRecord::Migration
  def self.up
    create_table :special_features do |t|
      t.string :name, :default => ""
      t.integer :feature_id, :null => false
      t.integer :meego_test_session_id, :null => false
    end
  end

  def self.down
    drop_table :special_features
  end
end
