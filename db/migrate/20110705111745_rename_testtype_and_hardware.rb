class RenameTesttypeAndHardware < ActiveRecord::Migration
  def self.up
  	rename_column :meego_test_session, :testtype, :testset
  	rename_column :meego_test_session, :hardware, :product
  end

  def self.down
  	rename_column :meego_test_session, :testset, :testtype
  	rename_column :meego_test_session, :product, :hardware
  end
end
