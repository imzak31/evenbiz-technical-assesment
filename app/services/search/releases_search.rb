# frozen_string_literal: true

module Search
  # Fuzzy SQL-based search service for Releases
  # Matches characters in sequence for typo-tolerant search
  class ReleasesSearch
    def initialize(scope = Release.all)
      @scope = scope
    end

    def call(query)
      return @scope if query.blank?

      fuzzy_pattern = build_fuzzy_pattern(query)

      @scope
        .left_joins(:artists)
        .where(
          Release.arel_table[:name].matches(fuzzy_pattern)
            .or(Artist.arel_table[:name].matches(fuzzy_pattern))
        )
        .distinct
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
