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

    respond_to do |format|
      if @album.save
        format.html { redirect_to albums_path, notice: "Album was successfully created." }
        format.turbo_stream { redirect_to albums_path, notice: "Album was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to albums_path, notice: "Album was successfully updated." }
        format.turbo_stream { redirect_to albums_path, notice: "Album was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @album.destroy!

    respond_to do |format|
      format.html { redirect_to albums_path, notice: "Album was successfully deleted.", status: :see_other }
      format.turbo_stream
    end
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:name, :duration_in_minutes, :artist_id, :cover)
  end
end
