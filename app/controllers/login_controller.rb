class LoginController < ApplicationController

  REDIRECT_URI = 'http://localhost:3000/login/callback'

  def encoded_credentials
    Base64.strict_encode64("#{ENV['CLIENT_ID']}:#{ENV['CLIENT_SECRET']}")
  end

  def retrieve_token
    conn = Faraday.new(
      url: 'https://accounts.spotify.com',
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Authorization' => "Basic #{encoded_credentials}"
      }
    )

    req_body = {
      grant_type: 'authorization_code',
      code: session['auth_code'],
      redirect_uri: REDIRECT_URI
    }

    response = conn.post('/api/token', **req_body)

    response_body = JSON.parse(response.body)

    response_body.each do |key, value|
      session[key] = value
    end

    get_current_users_playlists
  end

  # https://api.spotify.com/v1/me/playlists
  def get_current_users_playlists
    conn = Faraday.new(
      url: 'https://api.spotify.com',
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{session['access_token']}"
      }
    )

    response = conn.get('/v1/me/playlists')
    JSON.parse(response.body)
  end

  def callback
    session['auth_code'] = params["code"]

    if session['state_code'] != params["state"]
      p "ERROR WITH STATE CODE"
      p params["state"]
    end

    retrieve_token

    render :index
  end

  def login
    scope = 'user-read-private user-read-email'

    session['state_code'] = rando_string(16)

    query_options = {
      response_type: 'code',
      client_id: ENV['CLIENT_ID'],
      scope: scope,
      redirect_uri: REDIRECT_URI,
      state: session['state_code']
    }

    query_string = Rack::Utils.build_nested_query(query_options)
    auth_url = 'https://accounts.spotify.com/authorize?' + query_string

    conn = Faraday.new do |c|
      c.adapter Faraday.default_adapter
    end

    response = conn.get(auth_url)
    response_hash = response.to_hash
    redirection_url = response_hash[:response_headers]["location"]

    redirect_to redirection_url
  end

  def rando_string(num)
    upper = Array('A'..'Z')
    lower = Array('a'..'z')

    full_alphabet = upper + lower

    Array.new(num) do
      full_alphabet.sample
    end.join
  end

end
