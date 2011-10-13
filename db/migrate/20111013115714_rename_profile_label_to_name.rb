class RenameProfileLabelToName < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :label, :name
  end

  def self.down
    rename_column :profiles, :name, :label
  end
end
