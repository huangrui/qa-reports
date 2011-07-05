class RenameFeaturesFeatureName < ActiveRecord::Migration
  def self.up
  	rename_column :features, :feature, :name
  end

  def self.down
  	rename_column :features, :name, :feature
  end
end
