class DataPaperclipAttachmentsToGenericModel < ActiveRecord::Migration
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
      if File.exists? file[:path]
        FileAttachment.create! :file => File.open(file[:path]),
          :attachable_id => file[:meego_test_session_id],
          :attachable_type => 'MeegoTestSession',
          :attachment_type => :result_file
      end
    end

  end

  def self.down
    FileAttachment.delete_all
  end
end
