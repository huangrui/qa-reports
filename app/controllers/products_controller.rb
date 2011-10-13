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

  def update
    product, new_value = params.values_at :product, :new_value

    unless new_value.blank?
      reports = MeegoTestSession.product_is(product).readonly(false)

      reports.update_all ["product = ?, updated_at = ?, title = replace(title, ?, ?)",
          new_value, DateTime.now, product, new_value]
    end

    head :ok
  end
end
