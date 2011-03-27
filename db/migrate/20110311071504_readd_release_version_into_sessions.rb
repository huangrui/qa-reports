class ReaddReleaseVersionIntoSessions < ActiveRecord::Migration
  def self.up
    rename_column :meego_test_sessions, :version_label_id, :release_version
  end

  def self.down
  end
end
