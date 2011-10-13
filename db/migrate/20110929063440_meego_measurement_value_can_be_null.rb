class MeegoMeasurementValueCanBeNull < ActiveRecord::Migration
  def self.up
    change_column(:meego_measurements, :value, :float, :null => true)
  end

  def self.down
    # Null values are autoconverted to zeroes. But zeroes are not autoconverted to null in self.up
    # So running db:rollback and then db:migrate will change current null :values to zeroes.
    change_column(:meego_measurements, :value, :float, :null => false)
  end
end
