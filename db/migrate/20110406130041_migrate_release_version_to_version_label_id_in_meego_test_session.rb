class MigrateReleaseVersionToVersionLabelIdInMeegoTestSession < ActiveRecord::Migration
  class MeegoTestSession < ActiveRecord::Base
  end

  class VersionLabel < ActiveRecord::Base
  end

  def self.up
    add_column :meego_test_sessions, :version_label_id, :integer, :null => false, :default => 1

    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.release.normalized == t.label.downcase
          s.version_label_id = t.id
        end
      end
      s.save()
    end
    remove_index :meego_test_sessions, :name => 'index_meego_test_sessions_key'
    remove_column :meego_test_sessions, :release_version
    add_index :meego_test_sessions, [:version_label_id, :target, :testtype, :hwproduct], :name => 'index_meego_test_sessions_key'
  end

  def self.down
    add_column :meego_test_sessions, :release_version, :string, :default => "", :null => false

    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.version_label_id == t.id
          s.release = Release.find_by_normalized(t.label.downcase)
        end
      end
      s.save()
    end

    remove_index :meego_test_sessions, :name => 'index_meego_test_sessions_key'
    remove_column :meego_test_sessions, :version_label_id
    add_index :meego_test_sessions, [:release_version, :target, :testtype, :hwproduct], :name => 'index_meego_test_sessions_key'
  end
end
