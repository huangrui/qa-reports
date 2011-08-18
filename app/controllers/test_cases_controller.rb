class TestCasesController < ApplicationController
  include CacheHelper

  before_filter :authenticate_user!
  after_filter  :update_report_editor
  after_filter  :expire_report_cache

  def update
    #TODO: Doesn't check if the update fails
    #TODO: AttachmentsController should take care of attachments
    #TODO: Ugly hack to maintain current "delete attachment" functionality
    params[:test_case][:attachment] = params[:test_case][:attachment] if params[:test_case][:comment]

    @test_case = MeegoTestCase.unscoped.find(params[:id])
    @test_case.update_attributes(params[:test_case])

    render :partial => 'reports/testcase_comment', :locals => {:testcase => @test_case}
  end

  private

  def update_report_editor
    test_report = @test_case.meego_test_session
    test_report.update_attribute(:editor, current_user)
  end

  #TODO: Cache sweeper should be used
  def expire_report_cache
    expire_caches_for(@test_case.meego_test_session)
  end

end