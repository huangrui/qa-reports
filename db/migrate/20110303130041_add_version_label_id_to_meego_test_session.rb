class AddVersionLabelIdToMeegoTestSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :version_label_id, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :meego_test_sessions, :version_label_id
  end
end
