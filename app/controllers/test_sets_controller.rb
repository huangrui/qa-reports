class TestSetsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] =   {:name  => params[:release_version]} if params[:release_version]
    query_params[:profiles] =   {:name => params[:target]} if params[:target]
    query_params[:profiles] ||= {:name => params[:profile].try(:fetch, :name)} if params[:profile]

    @testsets = MeegoTestSession.published.joins(:release).joins(:profile).where(query_params).testsets

    respond_to do |format|
      format.json {render :json => @testsets}
    end
  end
end
