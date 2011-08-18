class FileAttachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  has_attached_file :file, :url => "/files/attachments/:id/:filename"

  delegate :url, :to => :file

  def image?
    (file.url =~ /\.(jpg|jpeg|gif|png|bmp)/) if file.present?
  end

  def filename
    File.basename(pretty_url)
  end

  def pretty_url
    file.url.split('?').first
  end
end
