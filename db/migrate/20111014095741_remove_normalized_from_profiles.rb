class RemoveNormalizedFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :normalized
  end

  def self.down
    add_column :profiles, :normalized, :string, :limit => 64, :null => false
    Profile.connection.execute("UPDATE profiles SET normalized=LOWER(name)")
  end
end
