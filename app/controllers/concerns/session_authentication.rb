# frozen_string_literal: true

# Concern for session-based authentication (UI/Monolith routes)
# Uses secure cookies with CSRF protection
module SessionAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user, :authenticated?
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticated?
    current_user.present?
  end

  def require_authentication
    return if authenticated?

    respond_to do |format|
      format.html { redirect_to_login }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end

  def authenticate_user(email:, password:)
    user = User.authenticate_by(email: email, password: password)
    return false unless user

    start_session_for(user)
    true
  end

  def start_session_for(user)
    reset_session
    session[:user_id] = user.id
  end

  def end_session
    reset_session
  end

  def redirect_to_login
    store_location
    redirect_to login_path, alert: "Please sign in to continue."
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def redirect_back_or_default(default = root_path)
    redirect_to(session.delete(:return_to) || default)
  end
end
