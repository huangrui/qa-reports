class AddCommentsIntoTestsets < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sets, :comments, :string, :default => ""
  end

  def self.down
  end
end
