class AddIntervalUnitToSerialMeasurements < ActiveRecord::Migration
  def self.up
    add_column :serial_measurements, :interval_unit, :string, :limit => 32
  end

  def self.down
    remove_column :serial_measurements, :interval_unit
  end
end
