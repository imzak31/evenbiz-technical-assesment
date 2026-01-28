# frozen_string_literal: true

# Handles user login/logout via sessions
# Inherits from ApplicationController for CSRF protection
class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]

  layout "auth"

  def new
    redirect_to root_path, notice: "You are already logged in." if authenticated?
  end

  def create
    if authenticate_user(email: params[:email], password: params[:password])
      redirect_back_or_default(root_path)
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    end_session
    redirect_to login_path, notice: "You have been logged out."
  end
end
