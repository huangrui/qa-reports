class CreateNftSeriesTable < ActiveRecord::Migration
  def self.up
    create_table :serial_measurements do |t|
      t.integer :meego_test_case_id, :null => false
      
      t.string :name, :null => false

      t.integer :sort_index, :null => false

      t.string :short_json, :limit => 256, :null => false
      t.text   :long_json,  :limit => 1000, :null => false
      
      t.string :unit, :limit => 32, :null => false
      
      t.float :min_value, :null => false
      t.float :max_value, :null => false
      t.float :avg_value, :null => false
      t.float :median_value, :null => false
    end

    add_index :serial_measurements, :meego_test_case_id
  end

  def self.down
    drop_table :serial_measurements
    remove_index :serial_measurements, :meego_test_case_id
  end
end
