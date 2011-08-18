class DataPaperclipAttachmentsToGenericModel < ActiveRecord::Migration
  def self.up
    ReportAttachment.all.each do |attachment|
      FileAttachment.create! :file => attachment.attachment,
        :attachable => attachment.meego_test_session,
        :attachment_type => :attachment
    end

    MeegoTestCaseAttachment.includes(:meego_test_case => :meego_test_session).find_each do |attachment|
      FileAttachment.create! :file => attachment.attachment,
        :attachable => attachment.meego_test_case,
        :attachment_type => :attachment
    end

    MeegoTestSession.includes(:test_result_files).find_each do |session|
      session.raw_result_files.each do |file_info|
        file_path = "public/reports/#{file_info[:path]}"
        if File.exists? file_path
          FileAttachment.create! :file => File.open(file_path),
            :attachable => session,
            :attachment_type => :result_file
        end
      end
    end

  end

  def self.down
    FileAttachment.delete_all
  end
end
