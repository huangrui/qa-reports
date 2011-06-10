class RenameTestCaseAttachmentImageToAttachment < ActiveRecord::Migration
  def self.up
    change_table :meego_test_case_attachments do |t|
      t.rename :image_file_name, :attachment_file_name
      t.rename :image_content_type, :attachment_content_type
      t.rename :image_file_size, :attachment_file_size
      t.rename :image_updated_at, :attachment_updated_at
    end
  end

  def self.down
    change_table :meego_test_case_attachments do |t|
      t.rename :attachment_file_name, :image_file_name
      t.rename :attachment_content_type, :image_content_type
      t.rename :attachment_file_size, :image_file_size
      t.rename :attachment_updated_at, :image_updated_at
    end
  end
end
