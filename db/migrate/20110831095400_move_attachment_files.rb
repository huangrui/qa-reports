class MoveAttachmentFiles < ActiveRecord::Migration

  # The previous migration could not be run on all systems successfully.
  # It was updated, and this migration affects those systems where the
  # previous migration had been run before the update. After this migration,
  # both cases have the same setup.

  class OldFileAttachment < ActiveRecord::Base
    set_table_name :file_attachments

    has_attached_file :file, :url => "/files/attachments/:id/:filename"
  end

  def self.up
    # Do nothing if updated version of previous migration was used
    return unless OldFileAttachment.first.try(:file).try(:to_file)

    old_attachments = OldFileAttachment.all

    old_attachments.each do |old_attachment|
      FileAttachment.create! :file            => old_attachment.file,
                             :attachable_id   => old_attachment.attachable_id,
                             :attachable_type => old_attachment.attachable_type,
                             :attachment_type => old_attachment.attachment_type
      old_attachment.destroy
    end
  end

  def self.down
  end
end
