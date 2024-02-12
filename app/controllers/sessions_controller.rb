class SessionsController < ApplicationController
  get '/sessions/new' do
    erb :"sessions/new.html"
  end

  get '/sessions/current_user' do
    json current_user
  end

  post '/sessions' do
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/"
    else
      flash.now[:error] = "Invalid email or password"
      erb :"sessions/new.html"
    end
  end

  delete '/session' do
    session.destroy
    flash[:notice] = "You have been logged out."
    if is_json_request?
      200
    else
      redirect "/"
    end
  end
end
