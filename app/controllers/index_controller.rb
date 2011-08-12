class IndexController < ApplicationController
  caches_action :filtered_list, :layout => false, :expires_in => 1.hour

  def index
    @products = Product.by_profile_by_test_type(@selected_release_version)

    @profiles = TargetLabel.targets
    @target = params[:target]
    @testset = params[:testset]
    @product = params[:product]
    @show_rss = true
  end
end
