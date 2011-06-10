class IndexController < ApplicationController
  caches_action :filtered_list, :layout => false, :expires_in => 1.hour

  def index
    @hardwares = Hardware.by_profile_by_test_type(@selected_release_version)

    @profiles = TargetLabel.targets
    @target = params[:target]
    @testtype = params[:testtype]
    @hardware = params[:hardware]
    @show_rss = true
  end
end
