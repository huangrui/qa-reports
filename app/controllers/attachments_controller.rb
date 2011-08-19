class AttachmentsController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!

  def destroy
    #TODO: Get rid of if-else after the attachments has been refactored to one table
    if params[:type] == 'report_attachment'
      attachment  = ReportAttachment.find(params[:id])
      test_report = attachment.meego_test_session
    else
      attachment  = MeegoTestCaseAttachment.find(params[:id])
      test_report = attachment.meego_test_case.meego_test_session
    end

    test_report.update_attribute(:editor, current_user)
    attachment.destroy

    head :ok
  end
end