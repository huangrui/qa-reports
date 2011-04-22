class IndexController < ApplicationController

  caches_action :filtered_list, :layout => false, :expires_in => 1.hour

  def index
    @types = {}
    MeegoTestSession::targets.each{|target|
      @types[target] = MeegoTestSession.list_types_for @selected_release_version, target
    }
    @hardware = MeegoTestSession.list_hardware @selected_release_version
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]
    @show_rss = true
  end
end
