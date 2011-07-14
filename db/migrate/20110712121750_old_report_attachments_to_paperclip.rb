class OldReportAttachmentsToPaperclip < ActiveRecord::Migration
  def self.up
    fs = FileStorage.new
    MeegoTestSession.find_each do |session|
      files = fs.list_files(session)
      
      files.each do |file_hash|
        file = File.open('public/' + file_hash[:url])
        session.report_attachments.create(:attachment => file) unless file.nil?
      end
    end
  end

  def self.down
  end
end
