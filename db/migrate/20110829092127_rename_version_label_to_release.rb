class RenameVersionLabelToRelease < ActiveRecord::Migration
  def self.up
    rename_table :version_labels, :releases
  end

  def self.down
    rename_table :releases, :version_labels
  end
end
