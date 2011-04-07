class MigrateReleaseVersionToVersionLabelIdInMeegoTestSession < ActiveRecord::Migration
  def self.up
    #add_column :meego_test_sessions, :version_label_id, :integer, :null => false, :default => 1
    
    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.release_version == t.label
          s.version_label_id = t.id
        end
      end
      s.save()
    end

    remove_column :meego_test_sessions, :release_version
  end

  def self.down
    remove_column :meego_test_sessions, :version_label_id
  end
end
