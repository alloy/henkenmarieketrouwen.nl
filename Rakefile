require 'rubygems'
require 'sinatra'

require 'active_record'
require 'sinatra/activerecord/rake'

$:.unshift File.expand_path('../', __FILE__)

namespace :db do
  namespace :migrate do
    [:test, :development, :production].each do |env|
      task env do
        ENV['RACK_ENV'] = env.to_s
        require 'app'
        Rake::Task['db:migrate'].invoke
      end
    end
  end

  namespace :create do
    [:test, :development, :production].each do |env|
      task env do
        ENV['SKIP_DB'] = '1'
        require 'config'

        ENV['RACK_ENV'] = env.to_s
        sh "createdb -h localhost #{HOSTNAME}_#{env} -E UTF8"
      end
    end
  end

  namespace :recreate do
    [:test, :development, :production].each do |env|
      task env do
        require 'config'
        sh "dropdb #{HOSTNAME}_#{env}"
        Rake::Task["db:create:#{env}"].invoke
        Rake::Task["db:migrate:#{env}"].invoke
      end
    end
  end

  task :seed => 'db:seed:development'

  namespace :seed do
    [:development, :production].each do |env|
      task env do
        require 'app'
        tokens = []
        tokens << Invitation.create(:invitees => 'Ernie', :email => ENV['EMAIL'] || 'ernie@example.org', :all_festivities => true, :has_post_ceremony_plus_one => true).token
        tokens << Invitation.create(:invitees => 'Bassie, Adriaan', :email => ENV['EMAIL'] || 'bassie@example.org', :all_festivities => true).token
        tokens << Invitation.create(:invitees => 'Rini, Sander, Mats, Mila, Nena, Jacky, Yuka', :email => ENV['EMAIL'] || 'rini@example.org', :all_festivities => false).token
        puts
        puts "Start by using either of these URLs:"
        tokens.each do |token|
          puts "  http://localhost:4567/#{token}"
        end
      end
    end
  end

  task :recreate => ['db:recreate:test', 'db:seed']
end

desc 'Run tests'
task :test do
  sh "ruby -I. -r #{FileList['test/*_test.rb'].map { |f| f[0..-4] }.join(' -r ')} -e ''"
end

namespace :send_invitations do
  [:development, :production].each do |env|
    task env do
      set :environment, env
      require 'invitation'
      Invitation.send_invitations!
    end
  end
end

desc 'Serve the application'
task :serve do
  exec 'env PORT=4567 RACK_ENV=development foreman start'
end
