class RenameReleasesLabelNameAndRemoveNormalized < ActiveRecord::Migration

  def self.up
    rename_column :releases, :label, :name
    remove_column :releases, :normalized
  end

  def self.down
    rename_column :releases, :name, :label
    add_column :releases, :normalized, :string
    Release.all.each do | release |
      release.update_attribute(:normalized, release.label.downcase)
    end
  end

end
