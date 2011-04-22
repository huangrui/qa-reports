require 'graph'

class ReportGroupsController < ApplicationController

  def show
    @target, @testtype, @hwproduct = params[:target], params[:testtype], params[:hwproduct]
    @show_rss = true

    @group_report = ReportGroupViewModel.new(@selected_release_version, @target, @testtype, @hwproduct)
  end

end