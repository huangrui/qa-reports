class CreateMeegoTestCaseAttachments < ActiveRecord::Migration
  def self.up
    create_table :meego_test_case_attachments do |t|
      t.integer :meego_test_case_id

      t.timestamps
    end
  end

  def self.down
    drop_table :meego_test_case_attachments
  end
end
