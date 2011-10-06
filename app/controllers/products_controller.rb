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
    product, new_value = params[:product], params[:new_value]
    reports = MeegoTestSession.product_is(product).readonly(false)
    #reports.find_each { |report| report.product = params[:new_value]; report.save }
    # ensure that also invalid reports (that can't be saved properly) get changed
    reports.update_all :title => "replace(title, '#{product}', '#{new_value}'",
      :product => new_value, :updated_at => DateTime.now
    #reports.update_all :product => new_value
    #MeegoTestSession.update_
    head :ok
  end
end
