class AddLinksToTestCase < ActiveRecord::Migration
  def self.up
    add_column :meego_test_cases, :source_link, :string
    add_column :meego_test_cases, :binary_link, :string
  end

  def self.down
  end
end
