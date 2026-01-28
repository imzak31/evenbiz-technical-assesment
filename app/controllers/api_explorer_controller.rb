# frozen_string_literal: true

class ApiExplorerController < ApplicationController
  before_action :require_authentication

  # POST /api_explorer/execute
  # Executes an API request using the Ruby HTTP client
  def execute
    client = Api::HttpClient.new(
      token: current_user.api_token,
      host: request_host
    )

    result = client.get(
      params[:endpoint],
      params: build_query_params
    )

    render json: result
  end

  private

  def request_host
    "#{request.protocol}#{request.host_with_port}"
  end

  def build_query_params
    query_params = {}

    # Pagination
    query_params[:page] = params[:page] if params[:page].present?
    query_params[:limit] = params[:limit] if params[:limit].present?

    # Filters
    query_params[:past] = params[:past] if params[:past].present?

    # Search
    query_params[:search] = params[:search] if params[:search].present?

    query_params
  end
end
