module Spotify
  module Api
    class Client

      def initialize(access_token)
        @access_token = access_token
      end

      def get_current_users_playlists
        conn = Faraday.new(
          url: 'https://api.spotify.com',
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{@access_token}}"
          }
        )

        response = conn.get('/v1/me/playlists')
        JSON.parse(response.body)
      end

    end

  end
end