# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'user' && password == 'BnuLc1nMDGp0'
  end
  Sidekiq::Web.set :sessions, false
  mount Sidekiq::Web, at: '/sidekiq'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount MailPreview => 'mail_view' if Rails.env.development?

  namespace :webhook do
    namespace :stripe do
      match :account, via: :all
    end
  end

  namespace :admin do
    root to: 'dashboards#index'
    resources :homepage_settings, only: %i[index edit update]
    resources :prewizard_settings, only: %i[index edit update]
    resources :faq_settings, except: :show
    resources :users do
      member do
        get :sign_in_as_user
        get :block
        get :unblock
        get :make_admin
        get :revoke_admin
      end
    end
    resources :trips, only: %i[index show] do
      post :cancel, on: :member
    end
    resources :reviews, only: %i[index edit update destroy] do
      member do
        get :enable
        get :disable
      end
    end
    resources :reports, only: %i[show destroy] do
      collection do
        get :about_review
        get :about_user
      end
    end

    # mailbox
    get 'compose_email'  => 'mailbox#compose'
    post 'compose_email' => 'mailbox#send_composed'
  end
  get '/admin', to: 'admin/dashboards#index'

  namespace :api do
    resources :boats, only: %i[index update], defaults: { format: :json } do
      member do
        get :calculate_price
        get :calculate_subtotal
      end
      resources :images, only: %i[create update destroy], defaults: { format: :json }
      resources :booking_blockings, only: %i[index create destroy], defaults: { format: :json } do
        delete :index, on: :collection, action: :destroy_range
      end
    end
    resources :users, only: %i[], defaults: { format: :json } do
      resources :wishlist, only: %i[create destroy], defaults: { format: :json }
      resources :reviews, only: %i[index], defaults: { format: :json }
    end
    controller :currencies do
      patch :set_current_currency, defaults: { format: :json }
    end
    controller :omniauth_connections do
      patch :disconnect_facebook, defaults: { format: :json }
      patch :disconnect_google, defaults: { format: :json }
    end
    namespace :phone_verification, defaults: { format: :json } do
      post :send_code
      post :verify_code
    end
    namespace :reports, defaults: { format: :json } do
      post :about_review
      post :about_user
    end

    scope :stripe do
      controller :stripe do
        get :payment_methods
        post :setup_intent
      end
    end

    resources :bookings, only: %i[create] do
      member do
        post :confirm
        post :pay_urgent_payment
      end
    end


  end

  get '/:locale' => 'homepages#index'

  # for language scope
  # TODO: Move this code to Constraint class.
  locale_regex_string = Boatinn::AVAILABLE_LOCALES_SHORT_FORMAT.join('|')
  locale_matcher = Regexp.new(locale_regex_string)
  scope '(:locale)', constraints: { locale: locale_matcher } do

    root 'homepages#index'

    devise_for :users, controllers: { registrations: 'users/registrations',
                                      confirmations: 'users/confirmations',
                                      sessions: 'users/sessions',
                                      passwords: 'users/passwords' },
                       skip: :omniauth_callbacks

    # for prewizard index page
    resources :prewizards, only: [:index]

    # for faq index page
    resources :faq, only: [:index]

    controller :static_pages do
      get 'cancellation-policy' => :cancellation_policy
      get 'terms' => :terms
      get 'about-us' => :about_us
      get 'welcome' => :welcome
    end

    # for wizard
    # TODO: Rename resource/controller/views: WizardsController -> ListingsController
    resources :wizards do
      get 'import_facebook_picture'
    end

    get 'search' => 'search#index'
    get 'profile/:id' => 'profile#show', as: :show_profile
    get 'profile/:id/reviews' => 'profile#reviews', as: :show_profile_reviews

    #search locations
    get 'alquiler-barco-malaga' => 'search#index', :lname => "Málaga, España", :lat => 36.721261, :lng => -4.4212655, :check_in_date => '', :check_out_date => '', :passengers_count => '' , :ciudad => "malaga", :page => 1
    get 'experiencias-nauticas-malaga' => 'search#index', :lname => "MÃ¡laga, EspaÃ±a", :lat => 36.721261, :lng => -4.4212655, :check_in_date => '', :check_out_date => '', :passengers_count => '' , :ciudad => "malaga"
    get 'alquiler-barco-ibiza' => 'search#index', :lat => 38.9067339, :lng => 1.4205983, :name => "Ibiza, EspaÃ±a", :ciudad => "ibiza"
    get 'listings' => redirect('%{locale}/search')
    resources :listings, controller: 'users/listings', only: %i[show]

    namespace :dashboard, module: :users do
      root to: 'listings#index'
      resources :listings, only: %i[index edit update destroy] do
        member do
          get :sleepin
          get :sharing
          get :port
          get :settings
          get :setshowboat
        end
      end

      resources :trips, only: %i[index]

      resources :inbox, only: %i[index show] do
        collection do
          get 'travels' => :index_travels, defaults: { trip_type: :travelling }
          get 'reservations' => :index_reservations, defaults: { trip_type: :reservations }
          post :create_conversation
        end
        post :create, on: :member
      end

      resources :reviews, only: %i[show update], controller: 'reviews' do
        patch 'create_reply'
        get 'leave_review'
        collection do
          get '/', action: :index_received_reviews
          get :given, action: :index_given_reviews
          get ':trip_id/:target_user_id/new', action: :new, as: :new
        end

      end

      resources :statistics, only: %i[index] do
        collection do
          get :ratings
          get :views
        end
      end

      resources :trips, only: %i[index] do
        get :invite, on: :collection
      end
      get 'receipt/:id' => 'trips#show_receipt', as: :receipt

      resources :notifications, only: %i[index]

      resources :calendar, only: [:index]

      resources :wishlist, only: [:index]
      resources :account, only: %i[index] do
        collection do
          get :notifications
          patch :cancel_account
          patch :update_notifications
          get :payment
          get :settings
          get :penalization
        end
      end
      resources :payments, only: %i[create destroy]

      resources :profile, only: %i[index update] do
        collection do
          patch :photo_update
          delete :destroy_photo
          patch :update_cv
          get :edit
          get :show, as: :show
          get :photos
          get :verification
          get :reviews
          get :cv
        end
      end

      controller :reservations do
        get :reservations, action: :index_reservations
        get :earnings, action: :index_earnings
        get :calculate_earnings
      end

      scope :invoice do
        get ':booking_id' => 'invoice#show', as: :invoice
      end

      resource :stripe_account, only: %i[show] do
        post :onboarding
        match "callback", via: :all, as: :callback
        match "refresh", via: :all, as: :refresh
      end
    end

    resources :bookings, only: %i[new create] do
      get  :created_success
      post :share_by_email
      collection do
        post :create_message_to_owner
      end
    end

    get '/trips/cancellation/:id' => 'trip_cancellation#new', as: :new_cancellation_trip
    post '/trips/cancellation/:id' => 'trip_cancellation#create'

  end

  devise_for :users, only: :omniauth_callbacks,
                     controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
