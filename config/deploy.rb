set :application, "wappied.com"
set :user, "app"
set :use_sudo, false

set :repository,  "git@github.com:moorage/playparty-video.git"
set :deploy_to, "/var/www/#{application}"
set :scm, :git

set :port, 33333                      # The port you've setup in the SSH setup section
set :location, "209.20.95.89"
role :app, location
role :web, location
role :db,  location, :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Make symlink for image downloads" 
  task :symlink_downloads do
    run "ln -nfs #{shared_path}/public/images/downloads #{release_path}/public/images/downloads" 
  end
  
  desc "Make symlink for database.yml" 
  task :symlink_dbyaml do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end

  desc "Create empty database.yml in shared path" 
  task :create_dbyaml do
    run "mkdir -p #{shared_path}/config" 
    put '', "#{shared_path}/config/database.yml" 
  end
end

after 'deploy:setup', 'deploy:create_dbyaml'
after 'deploy:update_code', 'deploy:symlink_dbyaml'
after 'deploy:update_code', 'deploy:symlink_downloads'

after "deploy", "deploy:cleanup"