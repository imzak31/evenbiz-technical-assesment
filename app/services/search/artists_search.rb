# frozen_string_literal: true

module Search
  # Fuzzy SQL-based search service for Artists
  # Matches characters in sequence for typo-tolerant search
  # e.g., "hih" matches "high", "jhn" matches "John"
  class ArtistsSearch
    def initialize(scope = Artist.all)
      @scope = scope
    end

    def call(query)
      return @scope if query.blank?

      # Build fuzzy pattern: each char with wildcards between
      # "hih" -> "%h%i%h%"
      fuzzy_pattern = build_fuzzy_pattern(query)

      @scope.where(
        Artist.arel_table[:name].matches(fuzzy_pattern)
      )
    end

    private

    def build_fuzzy_pattern(query)
      chars = query.to_s.strip.gsub(/\s+/, "").chars
      return "%" if chars.empty?

      "%" + chars.map { |c| sanitize_sql_like(c) }.join("%") + "%"
    end

    def sanitize_sql_like(string)
      string.to_s.gsub(/[%_\\]/) { |x| "\\#{x}" }
    end
  end
end
