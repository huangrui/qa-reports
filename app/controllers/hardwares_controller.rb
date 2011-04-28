class HardwaresController < ApplicationController

  def index
    query_params = {}
    query_params[:version_labels] = {:label => params[:release_version]} if params[:release_version]
    query_params[:target] = params[:target] if params[:target]

    @hardwares = MeegoTestSession.published.joins(:version_label).where(query_params).hardwares

    respond_to do |format|
      format.json {render :json => @hardwares}
    end
  end
end