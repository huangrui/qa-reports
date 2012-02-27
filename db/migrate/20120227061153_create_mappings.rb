class CreateMappings < ActiveRecord::Migration
  def self.up
    create_table :mappings do |t|
      t.string :feature, :null => false
      t.string :special_feature, :null => false
      t.string :test_case, :null => false
      t.integer :profile_id, :null => false
    end

    add_index :mappings, :feature
    add_index :mappings, :special_feature
    add_index :mappings, :test_case
    add_index :mappings, :profile_id
  end

  def self.down
    drop_table :mappings
  end
end
