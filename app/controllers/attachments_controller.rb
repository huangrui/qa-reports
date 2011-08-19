class AttachmentsController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!

  def destroy
    attachment  = FileAttachment.find(params[:id])
    attachable  = attachment.attachable
    test_report = attachable.try(:meego_test_session) || attachable

    test_report.update_attribute(:editor, current_user) if test_report.present?
    attachment.destroy

    head :ok
  end
end