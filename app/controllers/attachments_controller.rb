class AttachmentsController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!

  def destroy
    @attachment = MeegoTestCaseAttachments.find(params[:id])
    test_report = @attachment.meego_test_case.meego_test_session
    test_report.update_attribute(:editor, current_user)
    @attachment.destroy

    head :ok
  end
end