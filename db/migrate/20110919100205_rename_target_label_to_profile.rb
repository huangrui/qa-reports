class RenameTargetLabelToProfile < ActiveRecord::Migration
  def self.up
    rename_table :target_labels, :profiles
    add_column   :meego_test_sessions, :profile_id, :integer, :null => false
    Profile.all.each { |profile| MeegoTestSession.profile(profile.label).update_all :profile_id => profile.id }
  end

  def self.down
    rename_table  :profiles, :target_labels
    remove_column :meego_test_sessions, :profile_id
  end

end
