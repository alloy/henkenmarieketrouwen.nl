require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'pg'

require 'i18n'
I18n.enforce_available_locales = false

case ENV['RACK_ENV']
when 'test'
  set :environment, :test
when 'production'
  set :environment, :production
else
  set :environment, :development
end

app = Sinatra::Application
set :root, File.expand_path('../', __FILE__)

unless app.environment == :production
  ENV['MANAGE_SECRET'] = 'secret'
end

HOSTNAME = 'henkenmarieketrouwen'
DOMAIN = "#{HOSTNAME}.nl"

unless ENV['SKIP_DB']
  set :database, ENV['DATABASE_URL'] || "postgres://localhost/#{HOSTNAME}_#{app.environment}"
end

require 'logger'
if app.environment == :production
  LOGGER = Logger.new(STDOUT)
else
  LOGGER = Logger.new(File.join(app.root, 'log', "#{app.environment}.log"))
end
ActiveRecord::Base.logger = LOGGER

FROM_EMAIL = "info@#{DOMAIN}"
SMTP_HELO = 'heroku.com'
SMTP_HOST = 'smtp.sendgrid.net'
SMTP_PORT = 587
SMTP_USER = ENV['SENDGRID_USERNAME']
SMTP_PASS = ENV['SENDGRID_PASSWORD']
SMTP_AUTH = :plain
