# frozen_string_literal: true

Rails.application.routes.draw do
  # ==================
  # API Routes (Token Auth, Stateless)
  # ==================
  namespace :api do
    resources :releases, only: [ :index ]
  end

  # ==================
  # Authentication Routes
  # ==================
  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get  "signup", to: "registrations#new",    as: :signup
  post "signup", to: "registrations#create"

  # ==================
  # Monolith CRUD Routes (Session Auth)
  # ==================
  resources :artists
  resources :releases
  resources :albums
  resource :profile, only: [ :show, :edit, :update ]

  # ==================
  # Root / Dashboard
  # ==================
  root "dashboard#show"

  # ==================
  # Health Check
  # ==================
  get "up" => "rails/health#show", as: :rails_health_check
end
