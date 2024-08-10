class SpotifyController < ApplicationController
  def index

  end

  private

  def self.encoded_credentials
    Base64.strict_encode64("#{ENV['CLIENT_ID']}:#{ENV['CLIENT_SECRET']}")
  end

  def self.create_access_token
    conn = Faraday.new(
      url: 'https://accounts.spotify.com',
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Authorization' => "Basic #{encoded_credentials}"
      }
    )

    response = conn.post('/api/token', grant_type: 'client_credentials')
    JSON.parse(response.body)
  end


end
