# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::HttpClient do
  let(:token) { "test_token_123" }
  let(:host) { "http://localhost:3000" }
  let(:client) { described_class.new(token: token, host: host) }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  after do
    WebMock.allow_net_connect!
  end

  describe "#initialize" do
    it "stores the token" do
      expect(client.instance_variable_get(:@token)).to eq(token)
    end

    it "stores the host" do
      expect(client.instance_variable_get(:@host)).to eq(host)
    end
  end

  describe "#get" do
    let(:endpoint) { "/releases" }
    let(:api_url) { "#{host}/api#{endpoint}" }

    context "with successful response" do
      let(:response_body) do
        {
          "data" => [ { "id" => 1, "name" => "Test Release" } ],
          "meta" => { "current_page" => 1, "total_pages" => 1 },
        }
      end

      before do
        stub_request(:get, api_url)
          .with(headers: {
            "Authorization" => "Bearer #{token}",
            "Accept" => "application/json",
          })
          .to_return(
            status: 200,
            body: response_body.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns status code 200" do
        result = client.get(endpoint)

        expect(result[:status]).to eq(200)
      end

      it "parses JSON response body" do
        result = client.get(endpoint)

        expect(result[:body]).to eq(response_body)
      end

      it "includes response headers" do
        result = client.get(endpoint)

        expect(result[:headers]).to be_a(Hash)
      end

      it "includes request duration in milliseconds" do
        result = client.get(endpoint)

        expect(result[:duration]).to be_a(Numeric)
        expect(result[:duration]).to be >= 0
      end

      it "sends Bearer token in Authorization header" do
        client.get(endpoint)

        expect(WebMock).to have_requested(:get, api_url)
          .with(headers: { "Authorization" => "Bearer #{token}" })
      end

      it "sends Accept: application/json header" do
        client.get(endpoint)

        expect(WebMock).to have_requested(:get, api_url)
          .with(headers: { "Accept" => "application/json" })
      end
    end

    context "with query parameters" do
      let(:params) { { page: 2, limit: 25, search: "test" } }

      before do
        stub_request(:get, /#{api_url}/)
          .to_return(status: 200, body: "[]", headers: {})
      end

      it "appends query parameters to URL" do
        client.get(endpoint, params: params)

        expect(WebMock).to have_requested(:get, api_url)
          .with(query: params)
      end

      it "handles empty params" do
        client.get(endpoint, params: {})

        expect(WebMock).to have_requested(:get, api_url)
      end
    end

    context "with error responses" do
      it "handles 401 Unauthorized" do
        stub_request(:get, api_url)
          .to_return(
            status: 401,
            body: { error: "Unauthorized" }.to_json,
            headers: {}
          )

        result = client.get(endpoint)

        expect(result[:status]).to eq(401)
        expect(result[:body]["error"]).to eq("Unauthorized")
      end

      it "handles 404 Not Found" do
        stub_request(:get, api_url)
          .to_return(
            status: 404,
            body: { error: "Not found" }.to_json,
            headers: {}
          )

        result = client.get(endpoint)

        expect(result[:status]).to eq(404)
      end

      it "handles 500 Internal Server Error" do
        stub_request(:get, api_url)
          .to_return(
            status: 500,
            body: { error: "Server error" }.to_json,
            headers: {}
          )

        result = client.get(endpoint)

        expect(result[:status]).to eq(500)
      end
    end

    context "with network errors" do
      it "handles connection refused" do
        stub_request(:get, api_url).to_raise(Errno::ECONNREFUSED)

        result = client.get(endpoint)

        expect(result[:status]).to eq(0)
        expect(result[:body]).to have_key(:error)
        expect(result[:duration]).to eq(0)
      end

      it "handles timeout errors" do
        stub_request(:get, api_url).to_timeout

        result = client.get(endpoint)

        expect(result[:status]).to eq(0)
        expect(result[:body]).to have_key(:error)
      end

      it "handles DNS resolution errors" do
        stub_request(:get, api_url).to_raise(SocketError.new("getaddrinfo: Name or service not known"))

        result = client.get(endpoint)

        expect(result[:status]).to eq(0)
        expect(result[:body][:error]).to include("Name or service not known")
      end
    end

    context "with invalid JSON response" do
      it "returns raw body when JSON parsing fails" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: "Not valid JSON",
            headers: {}
          )

        result = client.get(endpoint)

        expect(result[:body]).to eq({ raw: "Not valid JSON" })
      end

      it "handles empty response body" do
        stub_request(:get, api_url)
          .to_return(status: 204, body: "", headers: {})

        result = client.get(endpoint)

        # Empty body causes an error in the HTTP client
        expect(result[:body]).to have_key(:error)
      end
    end

    context "with HTTPS host" do
      let(:host) { "https://api.example.com" }
      let(:api_url) { "#{host}/api#{endpoint}" }

      before do
        stub_request(:get, api_url)
          .to_return(status: 200, body: "[]", headers: {})
      end

      it "uses SSL for https URLs" do
        client.get(endpoint)

        expect(WebMock).to have_requested(:get, api_url)
      end
    end

    context "with different endpoints" do
      it "constructs correct URL for /releases" do
        stub_request(:get, "#{host}/api/releases")
          .to_return(status: 200, body: "[]", headers: {})

        client.get("/releases")

        expect(WebMock).to have_requested(:get, "#{host}/api/releases")
      end

      it "constructs correct URL for nested endpoints" do
        stub_request(:get, "#{host}/api/artists/1/releases")
          .to_return(status: 200, body: "[]", headers: {})

        client.get("/artists/1/releases")

        expect(WebMock).to have_requested(:get, "#{host}/api/artists/1/releases")
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
