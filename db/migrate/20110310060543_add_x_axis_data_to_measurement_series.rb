class AddXAxisDataToMeasurementSeries < ActiveRecord::Migration
  def self.up
    add_column :serial_measurements, :xaxis_json, :text, :null => false, :default => "" 
  end

  def self.down
    remove_column :serial_measurements, :xaxis_json
  end
end
