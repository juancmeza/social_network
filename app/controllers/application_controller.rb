require './config/environment'
require 'down'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :login
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/home"
    else
      redirect "/error/wrong user name or password"
    end
  end

  post '/signup' do
    if User.find_by(username: params[:username]) != nil
      redirect '/error/this user name already exists'
    end
    if User.find_by(email: params[:email]) != nil
      redirect '/error/this email already been used'
    end
    params[:first_name] = params[:first_name].downcase.capitalize
    params[:last_name] = params[:last_name].downcase.capitalize
    params[:email] = params[:email].downcase
    @user = User.new(params)
    if @user.save
      user = User.find_by(:username => params[:username])
      user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/home"
    else
      redirect "/error/we weren't able to register you"
    end
  end

  post '/pic' do
    @user = self.current_user
    directory_name = "public/images/profile/#{@user.id}"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    tempfile = Down.download("#{params[:url]}", destination: "#{directory_name}") 
    Dir["public/images/profile/#{@user.id}/*"].each do |file|
      File.rename(file, "public/images/profile/#{@user.id}/#{@user.id}.png")
    end
    redirect "/home"
  end

  get "/logout" do
    session.clear
    redirect "/"
  end
  
  get '/error/:err' do
    @message = params[:err]
    erb :login_signup_error
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end


