# frozen_string_literal: true

class PlaylistController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_playlist

  def show
    @pagy, @songs = pagy_countless(@playlist.songs)
  end

  def update
    if @playlist.update(playlist_params)
      flash.now[:success] = t('text.update_playlist_success')
    else
      head :bad_request
    end
  end

  def destroy
    @playlist.clear
    @songs = nil
  end

  def play
    return if params[:id] == 'current'
    Current.user.current_playlist.replace(@playlist.song_ids)
  end

  private

    def find_playlist
      case params[:id]
      when 'current'
        @playlist = Current.user.current_playlist
      when 'favorite'
        @playlist = Current.user.favorite_playlist
      else
        @song_collection = SongCollection.find_by(id: params[:id])
        @playlist = @song_collection.playlist
      end
    end

    def playlist_params
      params.permit(:update_action, song_ids: [])
    end
end