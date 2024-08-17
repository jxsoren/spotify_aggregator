Rails.application.routes.draw do
  get 'spotify/index'
  get 'login/index'
  get 'login/login'
  get 'login/callback'
end
