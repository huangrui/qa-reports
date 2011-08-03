require 'report_exporter'

class IndexController < ApplicationController
  caches_action :filtered_list, :layout => false, :expires_in => 1.hour

  before_filter :authenticate_user!, :except => :index

  def index
    @products = Product.by_profile_by_test_type(@selected_release_version)

    @profiles = TargetLabel.targets
    @target = params[:target]
    @testset = params[:testset]
    @product = params[:product]
    @show_rss = true
  end

  def dashboard_export
  end

  def do_dashboard_export
    success_count = 0
    MeegoTestSession.published.each do |session|
      success = ReportExporter::export_test_session(session)
      success_count += 1 if success
    end

    total_count = MeegoTestSession.published.count
    if success_count == total_count
      render :text => "OK"
    else
      render :text => "FAIL, #{success_count}/#{total_count} test reports were exported. Please see the log file to determine the problem."
    end
  end
end
