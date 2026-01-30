# frozen_string_literal: true

# Concern for JSON:API compliant responses
# Provides helpers for rendering data, errors, and pagination links
# following the JSON:API specification (https://jsonapi.org/)
#
# Usage:
#   class Api::MyController < Api::BaseController
#     def index
#       render_jsonapi(MySerializer, records, include: [:relation], meta: pagination_meta)
#     end
#   end
module JsonApiResponder
  extend ActiveSupport::Concern

  JSONAPI_CONTENT_TYPE = "application/vnd.api+json"

  # Render a JSON:API formatted collection with optional includes, meta, and links
  # @param serializer [Class] The JSONAPI::Serializer class to use
  # @param records [ActiveRecord::Relation, Array] The records to serialize
  # @param options [Hash] Options hash
  # @option options [Array<Symbol>] :include Relationships to include
  # @option options [Object] :meta Pagination meta object (responds to current_page, total_pages, etc.)
  # @option options [Hash] :links Custom links hash (overrides auto-generated pagination links)
  def render_jsonapi(serializer, records, options = {})
    serializer_options = {}

    serializer_options[:include] = options[:include] if options[:include].present?
    serializer_options[:meta] = build_pagination_meta(options[:meta]) if options[:meta].present?
    serializer_options[:links] = options[:links] || build_pagination_links(options[:meta]) if options[:meta].present?

    render json: serializer.new(records, serializer_options).serializable_hash,
           content_type: JSONAPI_CONTENT_TYPE
  end

  # Render a single JSON:API error
  # @param detail [String] Error message
  # @param status [Symbol] HTTP status code
  def render_jsonapi_error(detail, status)
    render_jsonapi_errors([ detail ], status)
  end

  # Render multiple JSON:API errors
  # @param errors [Array<String>] List of error messages
  # @param status [Symbol] HTTP status code
  def render_jsonapi_errors(errors, status)
    status_code = Rack::Utils.status_code(status)
    error_objects = Array(errors).map do |error|
      {
        status: status_code.to_s,
        title: Rack::Utils::HTTP_STATUS_CODES[status_code],
        detail: error,
      }
    end

    render json: { errors: error_objects },
           status: status,
           content_type: JSONAPI_CONTENT_TYPE
  end

  private

  # Build pagination meta hash from a pagination meta object
  # @param meta [Object] Object responding to current_page, total_pages, total_count, per_page
  # @return [Hash]
  def build_pagination_meta(meta)
    return {} unless meta

    {
      current_page: meta.current_page,
      total_pages: meta.total_pages,
      total_count: meta.total_count,
      per_page: meta.per_page,
    }
  end

  # Build pagination links hash from a pagination meta object
  # Generates self, first, last, prev, next links as appropriate
  # @param meta [Object] Object responding to current_page, total_pages
  # @return [Hash]
  def build_pagination_links(meta)
    return {} unless meta

    base_url = request.base_url + request.path
    current_params = request.query_parameters.except("page")

    # Handle empty results: last page should be at least 1
    last_page = [ meta.total_pages, 1 ].max

    links = {
      self: build_page_url(base_url, current_params, meta.current_page),
      first: build_page_url(base_url, current_params, 1),
      last: build_page_url(base_url, current_params, last_page),
    }

    links[:prev] = build_page_url(base_url, current_params, meta.current_page - 1) if meta.current_page > 1
    links[:next] = build_page_url(base_url, current_params, meta.current_page + 1) if meta.current_page < meta.total_pages

    links
  end

  # Build a URL with page parameter
  # @param base_url [String] The base URL without query string
  # @param params [Hash] Query parameters (excluding page)
  # @param page [Integer] Page number to add
  # @return [String]
  def build_page_url(base_url, params, page)
    query = params.merge(page: page).to_query
    query.present? ? "#{base_url}?#{query}" : base_url
  end
end
