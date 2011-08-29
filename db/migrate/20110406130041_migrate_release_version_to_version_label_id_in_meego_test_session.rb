class MigrateReleaseVersionToVersionLabelIdInMeegoTestSession < ActiveRecord::Migration
  class MeegoTestSession < ActiveRecord::Base
  end

  def self.up
    add_column :meego_test_sessions, :version_label_id, :integer, :null => false, :default => 1

    sessions = MeegoTestSession.find(:all)
    targets = Release.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.release_version == t.label
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
    targets = Release.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.version_label_id == t.id
          s.release_version = t.label
        end
      end
      s.save()
    end

    remove_index :meego_test_sessions, :name => 'index_meego_test_sessions_key'
    remove_column :meego_test_sessions, :version_label_id
    add_index :meego_test_sessions, [:release_version, :target, :testtype, :hwproduct], :name => 'index_meego_test_sessions_key'
  end
end
