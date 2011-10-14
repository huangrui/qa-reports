class RenameTargetLabelToProfile < ActiveRecord::Migration
  def self.up
    rename_table  :target_labels, :profiles
    add_column    :meego_test_sessions, :profile_id, :integer, :null => false
    Profile.all.each { |profile| MeegoTestSession.where(:target => profile.normalized).update_all :profile_id => profile.id }
    remove_column :meego_test_sessions, :target
  end

  def self.down
    add_column    :meego_test_sessions, :target, :string, :default => ""
    Profile.all.each { |profile| MeegoTestSession.where(:profile_id => profile.id).update_all :target => profile.normalized }
    rename_table  :profiles, :target_labels
    remove_column :meego_test_sessions, :profile_id
  end

end
