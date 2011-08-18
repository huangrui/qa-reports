class TestCasesController < ApplicationController
  include CacheHelper

  before_filter :authenticate_user!

  def update
    #TODO: Doesn't check if the update fails
    #TODO: AttachmentsController should take care of attachments
    # Ugly hack to maintain current "delete attachment" functionality
    params[:test_case][:attachment] = params[:test_case][:attachment] if params[:test_case][:comment]
    test_case = MeegoTestCase.find(params[:id])
    test_case.update_attributes(params[:test_case])

    test_report = test_case.meego_test_session
    test_report.update_attribute(:editor, current_user)

    expire_caches_for(test_report, true)
    render :partial => 'reports/testcase_comment', :locals => {:testcase => test_case}
  end

  def remove_testcase
    case_id = params[:id].to_i
    tc = MeegoTestCase.find(case_id)
    tc.remove_from_session

    expire_caches_for(tc.meego_test_session)
    render :json => {:ok => '1'}
  end

  def restore_testcase
    case_id         = params[:id].to_i
    tc = MeegoTestCase.deleted.find(case_id)
    tc.restore_to_session

    expire_caches_for(tc.meego_test_session)
    render :json => { :ok => '1' }
  end
end