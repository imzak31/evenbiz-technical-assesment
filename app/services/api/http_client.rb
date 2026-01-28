# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Api
  # Ruby HTTP Client for making internal API requests
  # Used by the API Explorer to demonstrate the API functionality
  class HttpClient
    BASE_PATH = "/api"

    def initialize(token:, host:)
      @token = token
      @host = host
    end

    # Make a GET request to the API
    # @param endpoint [String] The API endpoint (e.g., "/releases")
    # @param params [Hash] Query parameters
    # @return [Hash] Response with :status, :body, :headers, :duration
    def get(endpoint, params: {})
      uri = build_uri(endpoint, params)
      request = Net::HTTP::Get.new(uri)
      execute_request(uri, request)
    end

    private

    def build_uri(endpoint, params)
      full_path = "#{BASE_PATH}#{endpoint}"
      uri = URI.parse("#{@host}#{full_path}")
      uri.query = URI.encode_www_form(params) if params.any?
      uri
    end

    def execute_request(uri, request)
      request["Authorization"] = "Bearer #{@token}"
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.request(request)
      end

      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round(2)

      {
        status: response.code.to_i,
        body: parse_body(response.body),
        headers: response.to_hash,
        duration: duration,
      }
    rescue StandardError => e
      {
        status: 0,
        body: { error: e.message },
        headers: {},
        duration: 0,
      }
    end

    def parse_body(body)
      JSON.parse(body)
    rescue JSON::ParserError
      { raw: body }
    end
  end
end
