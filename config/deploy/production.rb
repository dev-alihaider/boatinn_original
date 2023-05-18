set :stage, :production
set :rails_env, "production"

set :branch, ENV['BRANCH'] || "master"
set :deploy_to, "/home/deploy/web/boatinn.es"

set :rocket_chat_webhook_url, "https://gazpachodev.rocket.chat/hooks/2r9pSeniYGN3xyXhf/5XZCaEjFFPaXWNjp6eDcaYee9y3pgDYYaKRahwgXFiMKehgs"

append :linked_files, "config/database.yml", "config/application.yml", "config/puma.rb"
append :linked_dirs, "public/assets", "public/system", "log", "tmp"

server 'boatinn.es', port: 9922, user: 'deploy', roles: %w{app web db}
