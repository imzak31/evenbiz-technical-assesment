# frozen_string_literal: true

module AuthenticationHelpers
  # Sign in a user for request specs by posting to the login path
  def sign_in(user, password: "password123")
    post login_path, params: { email: user.email, password: password }
  end

  # Sign out the current user
  def sign_out(_user = nil)
    delete logout_path
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
