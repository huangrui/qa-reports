class TestTypesController < ApplicationController

  def index
    query_params = {}
    query_params[:version_labels] = {:label => params[:release_version]} if params[:release_version]
    query_params[:target] = params[:target] if params[:target]

    @testtypes = MeegoTestSession.published.joins(:version_label).where(query_params).testtypes

    respond_to do |format|
      format.json {render :json => @testtypes}
    end
  end
end