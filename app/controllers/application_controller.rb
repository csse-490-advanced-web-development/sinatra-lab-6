require './config/environment'
require 'open-uri'
require 'rack/csrf'
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
    use Rack::Csrf, raise: true, skip_if: ->(req) { req.env['rack.test'] }
    use Rack::Protection
    use Rack::Protection::EscapedParams
    use Rack::Protection::RemoteReferrer
  end

  def is_json_request?
    request.media_type == "application/json" or request.content_type == "application/json"
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  before '/*' do
    Rack::Csrf.token(env)
    allowed_paths = [
      /^\/$/,
      /^\/users\/new$/,
      /^\/users$/,
      /^\/sessions\/new$/,
      /^\/sessions$/,
      /^\/static\/.*$/,
      /^\/.*.hot-update..*$/
    ]
    return if allowed_paths.any?{ |matcher| matcher.match? request.path }
    return if current_user
    redirect "/sessions/new", 401
  end

  def reverse_proxy_to_react(path)
    # TODO: There is almost certainly a path traversal bug in here...
    if ENV['APP_ENV'] == 'development'
      uri = URI.open("http://lvh.me:3000/#{path}")
      result = uri.read
      [ uri.status.first.to_i, {'Content-Type' => uri.content_type}, result ]
    else
      path = "index.html" if path == ""
      uri = URI.open("build/#{path}")
      result = uri.read
      file_type = File.extname(path)
      mime_types = {
        ".css" => "text/css",
        ".js" => "text/javascript",
        ".html" => "text/html"
      }
      [ 200, {'Content-Type' => mime_types[file_type] || "text/html"}, result ]
    end
  end

  get '/' do
    response.set_cookie("csrf", :value => Rack::Csrf.token(env))
    if current_user
      reverse_proxy_to_react('')
    else
      erb :"index.html"
    end
  end

  get '/static/*' do |path|
    reverse_proxy_to_react('static/' + path)
  end

  get '/*.hot-update.*' do |path, postfix|
    # e.g. http://lvh.me:5000/11646e0feca40a01f978.hot-update.json
    #  or  http://lvh.me:5000/main.1bfdb171386f91fe32fb.hot-update.js
    reverse_proxy_to_react(path + '.hot-update.' + postfix)
  end
end
