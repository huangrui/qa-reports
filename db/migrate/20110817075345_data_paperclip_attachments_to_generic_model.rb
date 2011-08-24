class DataPaperclipAttachmentsToGenericModel < ActiveRecord::Migration

  class MeegoTestCaseAttachment < ActiveRecord::Base
    belongs_to :meego_test_case
    has_attached_file :attachment, :url => "/files/attachments/:id/:filename"
  end

  class ReportAttachment < ActiveRecord::Base
    belongs_to :meego_test_session
    has_attached_file :attachment, :url => "/files/report_attachments/:id/:filename"
  end

  class TestResultFile < ActiveRecord::Base
  end

  def self.up
    ReportAttachment.find_each do |attachment|
      FileAttachment.create!(:file => attachment.attachment,
        :attachable => attachment.meego_test_session,
        :attachment_type => :attachment) unless attachment.meego_test_session.nil?
    end

    MeegoTestCaseAttachment.includes(:meego_test_case => :meego_test_session).find_each do |attachment|
      FileAttachment.create!(:file => attachment.attachment,
        :attachable => attachment.meego_test_case,
        :attachment_type => :attachment) unless attachment.meego_test_case.nil?
    end

    TestResultFile.find_each do |file|
      if File.exists? file.path
        clean_filename = file.path.gsub(/\/\d+-/, '/')
        File.rename(file.path, clean_filename)
        FileAttachment.create! :file => File.open(clean_filename),
          :attachable_id => file.meego_test_session_id,
          :attachable_type => 'MeegoTestSession',
          :attachment_type => :result_file
        File.rename(clean_filename, file.path)
      end
    end

    drop_table :report_attachments
    drop_table :meego_test_case_attachments
    # remove_index :test_result_files, :meego_test_session_id
    # drop_table :test_result_files
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

    # create_table :test_result_files, :force => true do |t|
    #   t.integer :meego_test_session_id, :null => false
    #   t.string  :path
    # end

    # add_index :test_result_files, :meego_test_session_id
  end
end
