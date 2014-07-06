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
set :database, ENV['DATABASE_URL'] || "postgres://localhost/eloyendionnetrouwen_#{app.environment}"
set :root, File.expand_path('../', __FILE__)

require 'logger'
LOGGER = Logger.new(File.join(app.root, 'log', "#{app.environment}.log"))
ActiveRecord::Base.logger = LOGGER unless app.environment == :production

FROM_EMAIL = 'info@eloyendionnetrouwen.nl'
SMTP_HELO = 'eloyendionnetrouwen.nl'
SMTP_HOST = 'mail.authsmtp.com'
SMTP_PORT = 2525
SMTP_USER = 'bob'
SMTP_PASS = 'secret'

