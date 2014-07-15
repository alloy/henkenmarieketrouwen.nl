require 'config'
require 'invitation'
require 'helpers'
require 'mailer'

require "sinatra/reloader" if development?

helpers do
  include Helpers
end

not_found do
  erb(:not_found)
end

before do
  @start = Time.now
  LOGGER.info "#{request.request_method} #{request.path}: #{params.inspect}"
end

after do
  if (e = env['sinatra.error']) && !e.is_a?(Sinatra::NotFound)
    LOGGER.info "An exception occurred: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
  end
  LOGGER.info "Finished: #{response.status} (in #{Time.now - @start} seconds)\n"
end

get '/' do
  erb :index
end

get '/accommodations' do
  erb :accommodations
end

get '/contact' do
  erb :contact
end

get '/present' do
  erb :present
end

get '/:invitation_token' do |token|
  redirect to("/invitations/#{token}")
end

get '/invitations/:token' do |token|
  if @invitation = Invitation.find_by_token(token)
    erb(@invitation.confirmed? ? :confirmation : :invitation)
  else
    404
  end
end

get '/invitations/:token/confirm' do |token|
  if @invitation = Invitation.find_by_token(token)
    erb :confirmation
  else
    404
  end
end

post '/invitations/:token' do |token|
  if @invitation = Invitation.find_by_token(token)
    attrs = params[:invitation].dup
    # TODO test this
    attendees = attrs['attendees'].select { |_, attend| attend == '1' }.map(&:first).join(',')
    attrs['attendees'] = attendees
    LOGGER.info attrs.inspect
    if @invitation.update_attributes(attrs)
      if @invitation.confirmed?
        Mailer.send_confirmation(@invitation) if @invitation.email
        redirect to("/invitations/#{token}")
      else
        redirect to("/invitations/#{token}/confirm")
      end
    else
      erb :invitation
    end
  else
    404
  end
end
