class RemoveDefaultValuesOfForeignKeys < ActiveRecord::Migration

  def self.up
    change_column_default(:meego_test_cases,    :meego_test_session_id, nil)
    change_column_default(:features,            :meego_test_session_id, nil)
    change_column_default(:meego_test_sessions, :author_id,             nil)
    change_column_default(:meego_test_sessions, :editor_id,             nil)
    change_column_default(:meego_test_sessions, :release_id,            nil)
  end

  def self.down
    change_column_default(:meego_test_cases,    :meego_test_session_id, 0)
    change_column_default(:features,            :meego_test_session_id, 0)
    change_column_default(:meego_test_sessions, :author_id,             0)
    change_column_default(:meego_test_sessions, :editor_id,             0)
    change_column_default(:meego_test_sessions, :release_id,            1)
  end

end
