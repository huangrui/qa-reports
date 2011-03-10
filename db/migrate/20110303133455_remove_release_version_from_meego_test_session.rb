class RemoveReleaseVersionFromMeegoTestSession < ActiveRecord::Migration
  def self.up
    remove_column :meego_test_sessions, :release_version
  end

  def self.down
    add_column :meego_test_sessions, :string
  end
end
