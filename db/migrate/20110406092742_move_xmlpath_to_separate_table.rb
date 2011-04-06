class MoveXmlpathToSeparateTable < ActiveRecord::Migration
  def self.up
    # Due to maximum row length restriction in DB we need to move the paths
    # to a separate table.
    
    create_table :test_result_files do |t|
      t.integer :meego_test_session_id, :null => false
      t.string  :path
    end
    
    # Move XML paths from column to new table
    MeegoTestSession.find(:all).each do |session|
      if session.xmlpath
        session.xmlpath.split(',').each do |file|
          TestResultFile.create :path => file, :meego_test_session_id => session.id
        end
      end
    end

    remove_column :meego_test_sessions, :xmlpath

    add_index :test_result_files, :meego_test_session_id
  end

  def self.down
    add_column :meego_test_sessions, :xmlpath, :string, :default => ""

    # Move paths from separate table to new column
    MeegoTestSession.find(:all).each do |session|
      session.update_attribute(:xmlpath, 
                               session.test_result_files.map(&:path).join(','))
    end
    
    # Drop unneeded stuff
    remove_index :test_result_files, :meego_test_session_id
    drop_table :test_result_files
  end
end
