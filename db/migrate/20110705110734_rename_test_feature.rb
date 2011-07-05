class RenameTestSetFeature < ActiveRecord::Migration
  def self.up
  	rename_table :meego_test_set, :feature

  end

  def self.down
  	rename_table :feature, :meego_test_set

  end
end
