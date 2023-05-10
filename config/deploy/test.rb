set :stage, :test
set :rails_env, "production"

set :branch, ENV['BRANCH'] || "test"
set :deploy_to, "/home/deploy/web/boatinn.net"

append :linked_files, "config/database.yml", "config/application.yml", "config/puma.rb"
append :linked_dirs, "public/assets", "public/system", "log", "tmp"

server 'boatinn.tk', port: 9922, user: 'deploy', roles: %w{app web db}
