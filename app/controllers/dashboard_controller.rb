class DashboardController < ApplicationController
  include Spotify::Api

  def index
    @playlists = Client.new(session['access_token']).get_current_users_playlists

    render @playlists
  end

  def playlists

  end
end
