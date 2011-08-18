class DataPaperclipAttachmentsToGenericModel < ActiveRecord::Migration

  class MeegoTestCaseAttachment < ActiveRecord::Base
    belongs_to :meego_test_case
    has_attached_file :attachment
  end

  class ReportAttachment < ActiveRecord::Base
    belongs_to :meego_test_session
    has_attached_file :attachment
  end

  class TestResultFile < ActiveRecord::Base
  end

  def self.up
    ReportAttachment.find_each do |attachment|
      FileAttachment.create! :file => attachment.attachment,
        :attachable => attachment.meego_test_session,
        :attachment_type => :attachment
    end

    MeegoTestCaseAttachment.includes(:meego_test_case => :meego_test_session).find_each do |attachment|
      FileAttachment.create! :file => attachment.attachment,
        :attachable => attachment.meego_test_case,
        :attachment_type => :attachment
    end

    TestResultFile.find_each do |file|
      if File.exists? file.path
        FileAttachment.create! :file => File.open(file.path),
          :attachable_id => file.meego_test_session_id,
          :attachable_type => 'MeegoTestSession',
          :attachment_type => :result_file
      end
    end

    drop_table :report_attachments
    drop_table :meego_test_case_attachments
  end

  def self.down
    create_table :report_attachments do |t|
      t.integer :meego_test_session_id, :null => false
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.timestamps
    end

    FileAttachment.where(:attachment_type => 'attachment', :attachable_type => 'MeegoTestSession').each do |attachment|
      ReportAttachment.create! :attachment => attachment.file, :meego_test_session_id => attachment.attachable_id
    end

    create_table :meego_test_case_attachments do |t|
      t.integer :meego_test_case_id
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.timestamps
    end

    FileAttachment.where(:attachment_type => 'attachment', :attachable_type => 'MeegoTestCase').each do |attachment|
      MeegoTestCaseAttachment.create! :attachment => attachment.file, :meego_test_case_id => attachment.attachable_id
    end

    FileAttachment.delete_all
  end
end
