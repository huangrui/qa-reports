class RenameVersionValueToReleaseVersion < ActiveRecord::Migration
  def self.up
    remove_column :meego_test_sessions, :release_version
    rename_column :meego_test_sessions, :version_value, :release_version
  end

  def self.down
    rename_column :meego_test_sessions, :release_version, :version_value
    add_column :meego_test_sessions, :release_version,  :integer, :null => false, :default => 1
  end
end
