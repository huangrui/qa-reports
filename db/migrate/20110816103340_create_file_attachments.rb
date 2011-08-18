class CreateFileAttachments < ActiveRecord::Migration
  def self.up
    create_table :file_attachments do |t|
      t.references :attachable, :polymorphic => true
      t.string :attachment_type, :null => false

      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
    end

    add_index :file_attachments, :attachable_id
  end

  def self.down
    remove_index :file_attachments, :attachable_id

    drop_table :file_attachments
  end
end
