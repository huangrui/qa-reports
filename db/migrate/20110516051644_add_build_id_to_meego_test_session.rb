class AddBuildIdToMeegoTestSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :build_id, :string, :default => ""
  end

  def self.down
    remove_column :meego_test_sessions, :build_id
  end
end
