class TestCasesController < ApplicationController
  include CacheHelper

  before_filter :authenticate_user!

  def update_case_comment
    case_id  = params[:id]
    comment  = params[:comment]
    attachment = params[:attachment]
    old_attachment = params[:old_attachment]
    testcase = MeegoTestCase.find(case_id)
    testcase.comment = comment
    testcase.attachment = attachment unless attachment.nil? and old_attachment.present?
    testcase.save!

    test_session = testcase.meego_test_session
    test_session.update_attribute(:editor, current_user)
    @editing = true
    expire_caches_for(testcase.meego_test_session)

    render :partial => 'reports/testcase_comment', :locals => {:testcase => testcase}
  end

  def update_case_result
    case_id  = params[:id]
    result   = params[:result]
    testcase = MeegoTestCase.find(case_id)
    testcase.update_attribute(:result, result.to_i)

    test_session = testcase.meego_test_session
    test_session.update_attribute(:editor, current_user)
    expire_caches_for(testcase.meego_test_session, true)

    render :text => "OK"
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