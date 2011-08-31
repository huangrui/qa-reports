class RenameReleasesLabelNameAndRemoveNormalized < ActiveRecord::Migration
  def self.up
    rename_column :releases, :label, :name
  end

  def self.down
    rename_column :releases, :name, :label
  end
end
