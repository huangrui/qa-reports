class MakeReleaseAndProfileNamesUnique < ActiveRecord::Migration
  def self.up
    add_index :releases, :name, :unique => true
    add_index :profiles, :name, :unique => true
  end

  def self.down
    remove_index :releases, :name
    remove_index :profiles, :name
  end
end
