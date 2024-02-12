require './config/environment'
require 'open-uri'
require 'securerandom'
require 'sinatra/json'

class ApplicationController < Sinatra::Application
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    logger = Logger.new(File.open("#{root}/../log/#{environment}.log", 'a'))
    logger.level = Logger::DEBUG unless production?
    set :logger, logger
    use Rack::CommonLogger, logger
    ActiveRecord::Base.logger = logger
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(32) }
    use Rack::JSONBodyParser

    use Rack::Protection
    # `use Rack::Protection` automatically enables all modules except for the
    # following, which have to be enabled explicitly
    use Rack::Protection::EscapedParams
    # NOTE: Temporarily removing Rack::Protection::FormToken,
    # as we will be replacing it shortly
    # use Rack::Protection::FormToken # inherits from use Rack::Protection::AuthenticityToken
    use Rack::Protection::RemoteReferrer
  end

  def is_json_request?
    request.media_type == "application/json" or request.content_type == "application/json"
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  before '/*' do
    allowed_paths = [
      /^\/$/,
      /^\/users\/new$/,
      /^\/users$/,
      /^\/sessions\/new$/,
      /^\/sessions$/,
    ]
    return if allowed_paths.any?{ |matcher| matcher.match? request.path }
    return if current_user
    redirect "/sessions/new", 401
  end

  get '/' do
    if current_user
      redirect "/tasks"
    else
      erb :"index.html"
    end
  end
end
