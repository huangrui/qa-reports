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

  def update
    release, target, testset, new_value = params.values_at :release_version, :target, :testset, :new_value

    unless new_value.blank?
      reports = MeegoTestSession.release(release).profile(target).testset(testset).readonly(false)

      reports.update_all ["testset = ?, updated_at = ?, title = replace(title, ?, ?)",
          new_value, DateTime.now, testset, new_value]
    end

    head :ok
  end

end
