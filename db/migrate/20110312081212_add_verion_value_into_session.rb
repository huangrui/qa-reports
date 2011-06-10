class AddVerionValueIntoSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :version_value, :string, :default => "", :null => false
  end

  def self.down
    remove_column :meego_test_sessions, :version_value
  end
end
