# frozen_string_literal: true

# Handles user registration (sign up)
class RegistrationsController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]

  layout "auth"

  def new
    redirect_to root_path, notice: "You are already logged in." if authenticated?
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_session_for(@user)
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
