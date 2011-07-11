class RenameTestSessionHardwareToProduct < ActiveRecord::Migration
  def self.up
  	rename_column :meego_test_sessions, :hardware, :product
  end

  def self.down
  	rename_column :meego_test_sessions, :product, :hardware
  end
end
