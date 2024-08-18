Rails.application.routes.draw do
  get 'login/login'
  get 'login/callback'
  get 'dashboard/index'
  get 'spotify/index'
  get 'login/index'
end
