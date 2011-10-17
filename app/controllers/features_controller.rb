class FeaturesController < ApplicationController
  include CacheHelper
  cache_sweeper :meego_test_session_sweeper

  before_filter :authenticate_user!
  after_filter  :update_report_editor

  def update
    @feature = Feature.find(params[:id])
    @feature.update_attributes(params[:feature]) # Doesn't check for failure
    head :ok
  end

  private

  def update_report_editor
    report = @feature.meego_test_session
    report.update_attribute(:editor, current_user)
  end
end
