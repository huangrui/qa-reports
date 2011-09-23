class ProductsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] =   {:name  => params[:release_version]} if params[:release_version]
    query_params[:profiles] =   {:label => params[:target]} if params[:target]
    query_params[:profiles] ||= {:label => params[:profile].try(:fetch, :label)} if params[:profile]

    @products = MeegoTestSession.published.joins(:release).where(query_params).products

    respond_to do |format|
      format.json {render :json => @products}
    end
  end
end
