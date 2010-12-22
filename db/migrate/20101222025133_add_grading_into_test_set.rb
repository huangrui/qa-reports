class AddGradingIntoTestSet < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sets, :grading, :integer
  end

  def self.down
  end
end
