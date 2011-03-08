class AddSortIndexToMeasurements < ActiveRecord::Migration
  def self.up
    add_column :meego_measurements, :sort_index, :integer, :default => 0, :null => false

  end

  def self.down
    remove_column :meego_measurements, :sort_index
  end
end
