class TestSetsController < ApplicationController

  def index
    query_params = {}
    query_params[:releases] =   {:name  => params[:release_version]} if params[:release_version]
    query_params[:profiles] =   {:label => params[:target]} if params[:target]
    query_params[:profiles] ||= {:label => params[:profile].try(:fetch, :label)} if params[:profile]

    @testsets = MeegoTestSession.published.joins(:release).joins(:profile).where(query_params).testsets

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
