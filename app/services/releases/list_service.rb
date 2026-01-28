# frozen_string_literal: true

module Releases
  # Service to list releases with filtering and pagination
  # Encapsulates all business logic for the releases index
  class ListService < BaseService
    DEFAULT_PER_PAGE = 10
    MAX_PER_PAGE = 100

    def initialize(params:)
      @page = params[:page]&.to_i || 1
      @per_page = normalize_per_page(params[:limit])
      @past_filter = params[:past]
      @search_query = params[:search]&.strip
    end

    def call
      releases = build_query
      paginated_releases, pagination_meta = paginate(releases, page: @page, per_page: @per_page)

      success(data: paginated_releases, meta: pagination_meta)
    end

    private

    def build_query
      scope = Release.for_index

      scope = apply_past_filter(scope)
      scope = apply_search(scope)

      scope
    end

    def apply_past_filter(scope)
      return scope if @past_filter.nil?

      case @past_filter.to_s
      when "1", "true"
        scope.past
      when "0", "false"
        scope.upcoming
      else
        scope
      end
    end

    def normalize_per_page(limit)
      return DEFAULT_PER_PAGE if limit.blank?

      limit_int = limit.to_i
      return DEFAULT_PER_PAGE if limit_int <= 0

      [ limit_int, MAX_PER_PAGE ].min
    end

    def apply_search(scope)
      return scope if @search_query.blank?

      pattern = build_fuzzy_pattern(@search_query)

      # Join with albums and artists for searching across related entities
      scope
        .joins(:album)
        .joins(:artists)
        .where(
          "releases.name ILIKE :pattern OR albums.name ILIKE :pattern OR artists.name ILIKE :pattern",
          pattern: pattern
        )
        .distinct
    end

    def build_fuzzy_pattern(query)
      # Turn "hih" into "%h%i%h%" for flexible matching
      "%#{query.chars.join('%')}%"
    end
  end
end
