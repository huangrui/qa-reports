class ReportAttachment < ActiveRecord::Base
  belongs_to :meego_test_session

  has_attached_file :attachment, :url => "/files/report_attachments/:id/:filename"

  def pretty_url
    attachment.url.split('?').first
  end

end
