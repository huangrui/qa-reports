class RenameTargetLabelToProfile < ActiveRecord::Migration
  def self.up
    rename_table :target_labels, :profiles
  end

  def self.down
    rename_table :profiles, :target_labels
  end
end
