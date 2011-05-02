class RenameHwproductToHardware < ActiveRecord::Migration
  def self.up
    change_table :meego_test_sessions do |t|
      t.rename :hwproduct, :hardware
    end
  end

  def self.down
    change_table :meego_test_sessions do |t|
      t.rename :hardware, :hwproduct
    end
  end
end
