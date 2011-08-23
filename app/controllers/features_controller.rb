class FeaturesController < ApplicationController
  include CacheHelper
  # cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!
  after_filter  :update_report_editor

  def update_feature_comment
    feature_id = params[:id]
    comments = params[:comment]
    feature = Feature.find(feature_id)
    feature.update_attribute(:comments, comments)

    test_session = feature.meego_test_session
    test_session.update_attribute(:editor, current_user)
    expire_caches_for(test_session)

    render :text => "OK"
  end

  def update_feature_grading
    feature_id = params[:id]
    grading = params[:grading]
    feature = Feature.find(feature_id)
    feature.update_attribute(:grading, grading)

    test_session = feature.meego_test_session
    test_session.update_attribute(:editor, current_user)
    expire_caches_for(test_session)

    render :text => "OK"
  end

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