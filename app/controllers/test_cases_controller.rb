class TestCasesController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!
  after_filter  :update_report_editor

  def update
    @test_case = MeegoTestCase.unscoped.find(params[:id])
    @test_case.update_attributes(params[:test_case]) # Doesn't check for failure

    #TODO: Canonical way of doing response: head :ok
    render :partial => 'reports/testcase_comment', :locals => {:testcase => @test_case}
  end

  private

  def update_report_editor
    report = @test_case.meego_test_session
    report.update_attribute(:editor, current_user)
  end
end