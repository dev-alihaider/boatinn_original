source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.3.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.6'
# Use postgre as the database for Active Record
gem 'pg'
# Use mysql as the database for Active Record
# gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '~> 3.7'
gem 'daemons'
#
gem 'bootstrap-sass'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  # web letter opener
  gem 'letter_opener_web'
    gem 'pry-rails'
    gem 'pry-doc'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'rubocop'
  gem 'awesome_print'
  gem 'annotate'
  gem 'meta_request'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'slim'
gem 'jquery-rails'

gem 'devise'
gem 'devise-i18n'
# gem 'devise-async'

# Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file
gem 'figaro'

# Easy and powerful exception tracking for Ruby
gem 'rollbar'

# Facebook OAuth2 Strategy for OmniAuth
gem 'omniauth-facebook'
# A Google OAuth2 strategy for OmniAuth 1.x
gem 'omniauth-google-oauth2'

# A simple library for communicating with Twilio REST API, building TwiML, generating Twilio Client Capability Tokens
gem 'twilio-ruby'

# Kaminari is a Scope & Engine based, clean, powerful, agnostic, customizable and sophisticated paginator for Rails 3+
gem 'kaminari'

# Official Geokit plugin for Rails/ActiveRecord. Provides location-based goodness for your Rails app.
gem 'geokit-rails'

# Simple, powerful visit tracking for Rails
gem 'ahoy_matey'

gem 'activerecord-session_store'
gem 'sidekiq'
gem 'sidekiq-status'
gem 'slim-rails'
gem 'coffee-rails'
gem 'mimemagic', git: 'https://github.com/mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'globalize', '~> 5.1.0.beta2'
gem 'activemodel-serializers-xml'
gem 'summernote-rails', '~> 0.8.10.0'
gem 'cocoon'
gem 'ledermann-rails-settings'
gem 'rest-client'
gem 'whenever', require: false
gem 'braintree'
gem 'draper'
gem 'remotipart', '~> 1.2'
gem 'countries'
gem 'stripe-rails'
gem 'money-rails'
gem 'state_machine'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

gem "trailblazer-rails"
gem "reform", ">= 2.2.0"
gem "reform-rails"
gem "trailblazer-cells"
gem "cells-rails"
gem "cells-slim"

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rvm' 
  gem 'capistrano-bundler', '~> 1.3'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-npm'
  gem 'whenever'
end

gem "mail_view"
gem 'capistrano-rocket-chat'
gem 'country_select'
gem 'redcarpet' #markdown

gem "invisible_captcha", "~> 2.0"

gem 'globalid'
gem 'spring'
gem 'spring-watcher-listen', '~> 2.0.0'
