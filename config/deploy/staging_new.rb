set :stage, :staging
set :rails_env, "staging"

set :branch, ENV['BRANCH'] || "staging_new"
set :deploy_to, "/home/deploy/web/boatinn-new.roobykon.com"

append :linked_files, "config/database.yml", "config/application.yml", "config/puma.rb"
append :linked_dirs, "public/assets", "public/system", "log", "tmp"

server 'boatinn-new.roobykon.com', port: 9937, user: 'deploy', roles: %w{app web db}
