class AttachmentsController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper
  before_filter :authenticate_user!

  def destroy
    attachment  = FileAttachment.find(params[:id])
    test_report = attachment.attachable.meego_test_session

    test_report.update_attribute(:editor, current_user)
    attachment.destroy

    head :ok
  end
end