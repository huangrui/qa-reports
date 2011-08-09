class AddNameIndexToMeegoTestCase < ActiveRecord::Migration
  def self.up
    add_index :meego_test_cases, [:meego_test_session_id, :name]
  end

  def self.down
    remove_index :meego_test_cases, [:meego_test_session_id, :name]
  end
end
