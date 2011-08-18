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

  end

  def self.down
    FileAttachment.delete_all
  end
end
