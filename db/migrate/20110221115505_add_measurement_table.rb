class AddMeasurementTable < ActiveRecord::Migration
  def self.up
    create_table :measurements do |t|
      t.integer :meego_test_case_id
      t.string :name,  :null => false
      t.string :unit,  :null => false, :limit => 32
      t.float  :value, :null => false
      t.float  :target
      t.float  :failure
    end

    add_index :measurements, :meego_test_case_id
  end

  def self.down
    drop_table :measurements
  end
end
