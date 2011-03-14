class ReaddReleaseVersionIntoSessions < ActiveRecord::Migration
  def self.up
      add_column(:meego_test_sessions, :release_version, :integer, {:null=>false, :default=>0})
      sessions = MeegoTestSession.find(:all)
      sessions.each do |s|
         s.release_version = s.version_label_id
      end
      s.save()
      remove_column :meego_test_sessions, :version_label_id
  end

  def self.down
      remove_column :meego_test_sessions, :release_version
  end
end
