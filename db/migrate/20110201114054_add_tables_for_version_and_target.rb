class AddTablesForVersionAndTarget < ActiveRecord::Migration
  def self.up
    create_table :version_labels do |t|
      t.string :label, :limit => 64, :null => false
      t.string :normalized, :limit => 64, :null => false
    end

    create_table :target_labels do |t|
      t.string :label, :limit => 64, :null => false
      t.string :normalized, :limit => 64, :null => false  
    end
  end

  def self.down
    drop_table :version_labels
    drop_table :target_labels
  end
end
