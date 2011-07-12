class RemoveResultCountsAndNftFlagsFromSessionAndFeature < ActiveRecord::Migration
  def self.up
    change_table :meego_test_sessions do |t|
      t.remove :total_cases
      t.remove :total_pass
      t.remove :total_fail
      t.remove :total_na

      t.remove :has_nft
      t.remove :has_ft
    end

    change_table :features do |t|
      t.remove :total_cases
      t.remove :total_pass
      t.remove :total_fail
      t.remove :total_na

      t.remove :has_nft
      t.remove :has_ft
    end
  end

  def self.down
    change_table :meego_test_sessions do |t|
      t.integer  :total_cases, :null => false, :default => 0
      t.integer  :total_pass, :null => false, :default => 0
      t.integer  :total_fail, :null => false, :default => 0
      t.integer  :total_na, :null => false, :default => 0

      t.boolean :has_nft, :default => false, :null => false
      t.boolean :has_ft, :default => true,  :null => false
    end      

    change_table :features do |t|
      t.integer  :total_cases, :null => false, :default => 0
      t.integer  :total_pass, :null => false, :default => 0
      t.integer  :total_fail, :null => false, :default => 0
      t.integer  :total_na, :null => false, :default => 0

      t.boolean :has_nft, :default => false, :null => false
      t.boolean :has_ft, :default => true,  :null => false
    end      
  end
end
