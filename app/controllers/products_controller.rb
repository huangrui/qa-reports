class ProductsController < ApplicationController

  def index
    query_params = {}
    query_params[:version_labels] = {:label => params[:release_version]} if params[:release_version]
    query_params[:target] = params[:target] if params[:target]

    @products = MeegoTestSession.published.joins(:release).where(query_params).products

    respond_to do |format|
      format.json {render :json => @products}
    end
  end
end