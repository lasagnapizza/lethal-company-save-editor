class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :require_login

  private

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def require_login
    unless Current.user
      redirect_to new_session_path, alert: 'Please sign in to access this page.'
    end
  end
end
