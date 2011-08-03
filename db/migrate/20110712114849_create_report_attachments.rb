class CreateReportAttachments < ActiveRecord::Migration
  def self.up
    create_table :report_attachments do |t|
      t.integer :meego_test_session_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :report_attachments
  end
end
