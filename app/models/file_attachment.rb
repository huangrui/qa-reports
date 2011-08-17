class FileAttachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  has_attached_file :file, :url => "/files/attachments/:id/:filename"
end
