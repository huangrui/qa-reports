class AddDeletedToMeegoTestCase < ActiveRecord::Migration
  def self.up
    add_column :meego_test_cases, :deleted, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :meego_test_cases, :deleted
  end
end
