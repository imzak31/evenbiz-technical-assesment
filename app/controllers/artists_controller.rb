# frozen_string_literal: true

# CRUD controller for Artists
# Follows thin controller pattern with Turbo Stream support
class ArtistsController < ApplicationController
  before_action :set_artist, only: [ :show, :edit, :update, :destroy ]

  def index
    base_scope = Artist.for_index
    results = Search::ArtistsSearch.new(base_scope).call(params[:q])
    # When searching, show all results; otherwise paginate
    @artists = params[:q].present? ? results.page(params[:page]).per(100) : results.page(params[:page]).per(12)
    @search_query = params[:q]
  end

  def show; end

  def new
    @artist = Artist.new
  end

  def edit; end

  def create
    @artist = Artist.new(artist_params)

    if @artist.save
      respond_to do |format|
        format.html { redirect_to @artist, notice: "Artist was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Artist was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @artist.update(artist_params)
      respond_to do |format|
        format.html { redirect_to @artist, notice: "Artist was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Artist was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @artist.destroy
    redirect_to artists_path, notice: "Artist was successfully deleted."
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :logo, :banner)
  end
end
