class AddResultCountIndexToMeegoTestCase < ActiveRecord::Migration
  def self.up
    add_index :meego_test_cases, [:deleted, :meego_test_session_id, :result], :name => :test_case_result_count_index
  end

  def self.down
    remove_index :meego_test_cases, :name => :test_case_result_count_index
  end
end
