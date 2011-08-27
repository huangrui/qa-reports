class IndexController < ApplicationController

  def index
    @products = Product.by_profile_by_test_type(@selected_release_version)
    @profiles = TargetLabel.targets
    @show_rss = true
  end
end
