class TestSetsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] = {:name => params[:release_version]} if params[:release_version]
    query_params[:target] = params[:target] if params[:target]

    @testsets = MeegoTestSession.published.joins(:release).where(query_params).testsets

    respond_to do |format|
      format.json {render :json => @testsets}
    end
  end
end