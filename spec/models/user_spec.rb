# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe "validations" do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }

    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }

    # api_token is auto-generated, so test uniqueness via DB constraint behavior
    it { is_expected.to validate_uniqueness_of(:api_token) }

    it { is_expected.to have_secure_password }

    describe "email format" do
      it "rejects invalid emails" do
        invalid_emails = %w[invalid @no-local.com no-at-sign.com user@.com]
        invalid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid
        end
      end

      it "accepts valid emails" do
        valid_emails = %w[user@example.com USER@Example.COM user+tag@example.org]
        valid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid
        end
      end
    end
  end

  describe "callbacks" do
    it "generates api_token before creation" do
      user = build(:user, api_token: nil)
      user.valid?
      expect(user.api_token).to be_present
    end

    it "generates unique 64-character hex token" do
      user = create(:user)
      expect(user.api_token).to match(/\A[a-f0-9]{64}\z/)
    end
  end

  describe "normalizations" do
    it "normalizes email to lowercase and strips whitespace" do
      user = create(:user, email: "  USER@EXAMPLE.COM  ")
      expect(user.email).to eq("user@example.com")
    end
  end

  describe "#full_name" do
    it "concatenates first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end

  describe "#regenerate_api_token!" do
    it "generates a new unique token" do
      user = create(:user)
      old_token = user.api_token

      user.regenerate_api_token!

      expect(user.api_token).not_to eq(old_token)
      expect(user.api_token).to match(/\A[a-f0-9]{64}\z/)
    end
  end

  describe ".by_api_token" do
    it "finds user by token" do
      user = create(:user)
      expect(described_class.by_api_token(user.api_token).first).to eq(user)
    end

    it "returns empty when token not found" do
      expect(described_class.by_api_token("nonexistent")).to be_empty
    end
  end

  describe "authentication" do
    let(:user) { create(:user, password: "secure123", password_confirmation: "secure123") }

    it "authenticates with correct password" do
      expect(user.authenticate("secure123")).to eq(user)
    end

    it "rejects incorrect password" do
      expect(user.authenticate("wrong")).to be false
    end
  end
end
