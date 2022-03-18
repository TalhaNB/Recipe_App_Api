class UsersController < ApplicationController
  before_action :authorized, only: [:auto_login, :edit]

  # REGISTER
  def create
    @user = User.create(user_params)
    if @user.valid?
      render json: {user: @user, dataRecieved: params, dataPermited: user_params}
    else
      render json: {error: @user.errors.full_messages, dataRecieved: params, dataPermited: user_params}
    end
  end

  # LOGGING IN
  def login
    @user = User.find_by(username: params[:username])
    
    remember_me = params[:remember_me].to_i
    
    image = @user.avatar.attached? ? url_for(@user.avatar) : "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1200px-No_image_available.svg.png"
    
    if @user && @user.authenticate(params[:password])
      expiry = Time.now.utc + remember_me.hours
      token = encode_token({user_id: @user.id, iat: Time.now.utc.to_i, exp: expiry.to_i})
      render json: {
        username: @user.username,
        image: image, 
        token: token,
      }
    else
      render json: {error: @user.errors.full_messages}
    end
  end
  #Used for fetching user data for editing purposes
  def auto_login
    render json: @user
  end

  def edit
    @user.password = params[:new_password] unless params[:new_password].nil? || params[:new_password].empty? || params[:new_password] == @user.password
    
    if @user.save
      render json: {Notice: "Updated sucessfully", User: @user}
    else
      render json: {Notice: "Update Failed", Error: @user.erros.full_messages}
    end
  end

  private

  def user_params
    params.permit(:username, :email, :password, :avatar)
  end
end
#'//' + location.host + location.pathname