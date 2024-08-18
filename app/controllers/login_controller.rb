class LoginController < ApplicationController

  def login
    if has_auth_token?
      redirect_to "/dashboard/index" and return
    end

    begin
      oauth_flow
    rescue StandardError => e
      e
    end

  end

  def oauth_flow
    # Request for provider authorization page
    request_authorization
  end

  def has_auth_token?
    session['auth_code'].present?
  end

  def get_access_token
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
      redirect_uri: ENV['REDIRECT_URI']
    }

    response = conn.post('/api/token', **req_body)
    response_body = JSON.parse(response.body)
    response_body.each do |key, value|
      session[key] = value
    end
  end

  def callback
    # Set auth_code from Spotify's callback request
    session['auth_code'] = params["code"]

    # Verify state to protect against cross site forgery
    if session['state_code'] != params["state"]
      p "ERROR WITH STATE CODE"
      p params["state"]
    end

    # Fetches Bearer token from Spotify
    get_access_token

    # Redirect request back to login
    redirect_to action: 'login', status: 302
  end

  def request_authorization
    auth_url = build_auth_url
    @redirection_url = get_redirect_url(auth_url)

    redirect_to @redirection_url
  end

  def generate_state_code
    session['state_code'] = SecureRandom.hex(16)
  end

  def build_auth_url
    generate_state_code

    query_options = {
      response_type: 'code',
      client_id: ENV['CLIENT_ID'],
      scope: ENV['SCOPE'],
      redirect_uri: ENV['REDIRECT_URI'],
      state: session['state_code']
    }
    query_string = Rack::Utils.build_nested_query(query_options)

    'https://accounts.spotify.com/authorize?' + query_string
  end

  def get_redirect_url(destination_url)
    conn = Faraday.new do |c|
      c.adapter Faraday.default_adapter
    end

    conn.get(destination_url).to_hash[:response_headers]["location"]
  end

  private

  def encoded_credentials
    Base64.strict_encode64("#{ENV['CLIENT_ID']}:#{ENV['CLIENT_SECRET']}")
  end

end
