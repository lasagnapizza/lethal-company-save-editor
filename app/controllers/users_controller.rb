class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_signup_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Account created successfully!'
    else
      render :new
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(user_update_params)
      redirect_to root_path, notice: 'Profile updated successfully!'
    else
      render :edit
    end
  end

  private

  def user_signup_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:username, :password, :password_confirmation, :email)
  end


  def clean_password_params
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  end
end
