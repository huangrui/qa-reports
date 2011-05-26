require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @target, @testtype, @hardware = params[:target], params[:testtype], params[:hardware]
    @show_rss = true

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testtype, @hardware)
  end

end