module Spotify
  module Api
    class Client

      def initialize
        @access_token = nil
      end

      def create_access_token
        conn = Faraday.new(
          url: 'https://accounts.spotify.com',
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Authorization' => "Basic #{encoded_credentials}"
          }
        )

        response = conn.post('/api/token', grant_type: 'client_credentials')
        JSON.parse(response.body)['access_token']
      end

      def get_current_users_playlists
        conn = Faraday.new(
          url: 'https://api.spotify.com/v1',
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{@access_token}"
          }
        )

        response = conn.get('/me/playlists') do |req|
          req.params['limit'] = 100
        end

        JSON.parse(response.body)
      end

    end

  end
end