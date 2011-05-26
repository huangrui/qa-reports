class AddPaperclipToTestCaseAttachment < ActiveRecord::Migration
  def self.up
    add_column :meego_test_case_attachments, :image_file_name,    :string
    add_column :meego_test_case_attachments, :image_content_type, :string
    add_column :meego_test_case_attachments, :image_file_size,    :integer
    add_column :meego_test_case_attachments, :image_updated_at,   :datetime
  end

  def self.down
    remove_column :meego_test_case_attachments, :image_file_name
    remove_column :meego_test_case_attachments, :image_content_type
    remove_column :meego_test_case_attachments, :image_file_size
    remove_column :meego_test_case_attachments, :image_updated_at
  end
end
