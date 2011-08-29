class RenameVersionLabelToRelease < ActiveRecord::Migration
  def self.up
    rename_table :version_labels, :releases
    rename_column :meego_test_sessions, :version_label_id, :release_id
  end

  def self.down
    rename_table :releases, :version_labels
    rename_column :meego_test_sessions, :release_id, :version_label_id
  end
end
