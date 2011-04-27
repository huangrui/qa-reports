# re-create one index that is missing from production db

class RecreateMissingIndex < ActiveRecord::Migration   
  def self.up   
    add_index :meego_test_sessions, [:release_version, :target, :testtype, :hwproduct], :name => 'index_meego_test_sessions_key'
  rescue
    raise unless $!.message =~ /^Index name 'index_meego_test_sessions_key' on table 'meego_test_sessions' already exists/i
  end

  def self.down
  end
end
