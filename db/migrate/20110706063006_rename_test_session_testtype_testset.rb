class RenameTestSessionTesttypeTestset < ActiveRecord::Migration
  def self.up
  	rename_column :meego_test_sessions, :testtype, :testset
  end

  def self.down
  	rename_column :meego_test_sessions, :testset, :testtype
  end
end
