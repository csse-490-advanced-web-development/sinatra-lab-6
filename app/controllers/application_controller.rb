require './config/environment'
require 'securerandom'

class ApplicationController < Sinatra::Application
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    logger = Logger.new(File.open("#{root}/../log/#{environment}.log", 'a'))
    logger.level = Logger::DEBUG unless production?
    set :logger, logger
    ActiveRecord::Base.logger = logger
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(32) }
    use Rack::Protection
    # `use Rack::Protection` automatically enables all modules except for the
    # following, which have to be enabled explicitly
    use Rack::Protection::AuthenticityToken
    use Rack::Protection::EscapedParams
    use Rack::Protection::FormToken
    use Rack::Protection::RemoteReferrer
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  get '/' do
    redirect "/tasks"
  end
end
