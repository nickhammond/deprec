# Copyright 2006-2011 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deprec do
    namespace :rack do

      set :rack_env, 'production'

      desc "Install Rack stack on Ubuntu server (8.04, 10.04)"
      task :install_stack do   
        top.deprec.git.install
        top.deprec.ruby.install       # Uses ruby_vm_type
        gem2.install 'bundler'
        # Some things Rails needs
        apt.install( { :base => %w(libmysqlclient15-dev sqlite3 libsqlite3-ruby libsqlite3-dev libpq-dev libxslt-dev libxml2-dev) }, :stable)

        # app.install with passenger runs Passenger's install scripts
        # which calls out to web.install properly
        unless web_server_type.to_s.match(/(nginx|apache)/) && 
          app_server_type == :passenger
            top.deprec.web.install        # Uses web_server_type
        end

        top.deprec.app.install        # Uses app_server_type
        top.deprec.db.install
        top.deprec.logrotate.install
      end

      desc "Generate config files for rack app."
      task :config_gen do
        top.deprec.web.config_gen_project
        top.deprec.app.config_gen_project
      end

      desc "Push out config files for rack app."
      task :config do
        top.deprec.web.config_project
        top.deprec.app.config_project
      end

      desc "Install debs listed in :packages_for_project"
      task :install_packages, :roles => :app do
        if packages_for_project
          apt.install({ :base => packages_for_project }, :stable)
        end
      end

    end
  end
end
