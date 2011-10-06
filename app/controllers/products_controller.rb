class ProductsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] = {:name => params[:release_version]} if params[:release_version]
    query_params[:target] = params[:target] if params[:target]

    @products = MeegoTestSession.published.joins(:release).where(query_params).products

    respond_to do |format|
      format.json {render :json => @products}
    end
  end

  def update
    reports = MeegoTestSession.product_is(params[:product]).readonly(false)
    reports.find_each { |report| report.product = params[:new_value]; report.save }
    # ensure that also invalid reports (that can't be saved properly) get changed
    reports.update_all :product => params[:new_value]
    head :ok
  end
end
