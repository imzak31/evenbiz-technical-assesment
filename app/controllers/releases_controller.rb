# frozen_string_literal: true

# CRUD controller for Releases
class ReleasesController < ApplicationController
  before_action :set_release, only: [ :show, :edit, :update, :destroy ]

  def index
    base_scope = Release.for_index
    results = Search::ReleasesSearch.new(base_scope).call(params[:q])
    # When searching, show all results; otherwise paginate
    @releases = params[:q].present? ? results.page(params[:page]).per(100) : results.page(params[:page]).per(12)
    @search_query = params[:q]
  end

  def show; end

  def new
    @release = Release.new
    @release.build_album
  end

  def edit
    @release.build_album unless @release.album
  end

  def create
    @release = Release.new(release_params)

    if @release.save
      respond_to do |format|
        format.html { redirect_to @release, notice: "Release was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Release was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @release.update(release_params)
      respond_to do |format|
        format.html { redirect_to @release, notice: "Release was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Release was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @release.destroy
    redirect_to releases_path, notice: "Release was successfully deleted."
  end

  private

  def set_release
    @release = Release.includes(:album, :artists).find(params[:id])
  end

  def release_params
    params.require(:release).permit(
      :name, :released_at,
      artist_ids: [],
      album_attributes: [ :id, :name, :duration_in_minutes, :artist_id, :cover ]
    )
  end
end
