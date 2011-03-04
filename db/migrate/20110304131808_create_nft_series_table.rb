class CreateNftSeriesTable < ActiveRecord::Migration
  def self.up
    create_table :serial_measurements do |t|
      t.integer :meego_test_case_id, :null => false
      t.string :short_json, :limit => 256
      t.text   :long_json,  :limit => 1000
      t.float :min_value
      t.float :max_value
      t.float :avg_value
      t.float :median_value
    end

    add_index :serial_measurements, :meego_test_case_id
  end

  def self.down
    drop_table :serial_measurements
    remove_index :serial_measurements, :meego_test_case_id
  end
end
