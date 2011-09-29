class MeegoMeasurementValueCanBeNull < ActiveRecord::Migration
  def self.up
    change_column(:meego_measurements, :value, :float, :null => true)
  end

  def self.down
    # TODO: should existing null values be handled somehow
    change_column(:meego_measurements, :value, :float, :null => false)
  end
end
