require 'capistrano-unicorn'
require 'bundler/capistrano'

set :application, "naskit"
set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :keep_releases, 5

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, :root
set :app_user, :naskit
set :app_group, :naskit
set :use_sudo, false
server "naskit.thirdside.ca", :app, :web, :db, :primary => true

set :deploy_to, "/home/naskit/sites/naskit.thirdside.ca/"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

 
namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{deploy_to}/current && #{try_sudo} bundle exec foreman export upstart /etc/init -a #{application} -u #{app_user} -l #{deploy_to}/shared/log/upstart.log"
  end
  
  desc "Start the application services"
  task :start, :roles => :app do
    run "#{try_sudo} start #{application}"
  end
 
  desc "Stop the application services"
  task :stop, :roles => :app do
    run "#{try_sudo} stop #{application}"
  end
 
  desc "Restart the application services"
  task :restart, :roles => :app do
    run "#{try_sudo} restart #{application} || #{try_sudo} start #{application}"
  end
end

task :setup_group do
  run "chown -R #{app_user}:#{app_group} #{deploy_to} && chmod -R g+s #{deploy_to}"
end
 
after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"
after "deploy:finalize_update", :setup_group
