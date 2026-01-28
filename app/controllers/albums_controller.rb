# frozen_string_literal: true

class AlbumsController < ApplicationController
  before_action :set_album, only: %i[show edit update destroy]

  def index
    @albums = Album.for_index.page(params[:page]).per(12)
  end

  def show; end

  def new
    @album = Album.new
  end

  def edit; end

  def create
    @album = Album.new(album_params)

    if @album.save
      respond_to do |format|
        format.html { redirect_to albums_path, notice: "Album was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Album was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @album.update(album_params)
      respond_to do |format|
        format.html { redirect_to albums_path, notice: "Album was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Album was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album.destroy!
    redirect_to albums_path, notice: "Album was successfully deleted."
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:name, :duration_in_minutes, :artist_id, :cover)
  end
end
