class ProductsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] =   {:name  => params[:release_version]} if params[:release_version]
    query_params[:profiles] =   {:name => params[:target]} if params[:target]
    query_params[:profiles] ||= {:name => params[:profile].try(:fetch, :name)} if params[:profile]

    @products = MeegoTestSession.published.joins(:release).joins(:profile).where(query_params).products

    respond_to do |format|
      format.json {render :json => @products}
    end
  end
end
