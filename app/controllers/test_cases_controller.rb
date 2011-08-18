class TestCasesController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!
  after_filter  :update_report_editor

  def update
    #TODO: AttachmentsController should take care of attachments
    #TODO: Ugly hack to maintain current "delete attachment" functionality
    #params[:test_case][:attachment] = params[:test_case][:attachment] if params[:test_case][:comment]

    @test_case = MeegoTestCase.unscoped.find(params[:id])

    #TODO: Doesn't check if the update fails
    @test_case.update_attributes(params[:test_case])

    #TODO: Canonical way of doing response: head :ok
    render :partial => 'reports/testcase_comment', :locals => {:testcase => @test_case}
  end

  private

  def update_report_editor
    test_report = @test_case.meego_test_session
    test_report.update_attribute(:editor, current_user)
  end
end