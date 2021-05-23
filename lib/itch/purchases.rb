# frozen_string_literal: true

require "csv"
require_relative "require_auth"
require_relative "simple_inspect"

module Itch
  # Return purchase history and history by date
  class Purchases
    include RequireAuth
    include SimpleInspect

    def initialize(agent)
      @agent = agent
    end

    def history_by_month(month, year)
      fetch_csv format(Itch::URL::MONTH_PURCHASES_CSV, month: month, year: year)
    end

    def history_by_year(year)
      fetch_csv format(Itch::URL::YEAR_PURCHASES_CSV, year: year)
    end

    def history
      fetch_csv Itch::URL::PURCHASES_CSV
    end

    protected

    def fetch_csv(url)
      page = with_login do
        @agent.get(url)
      end

      validate_response(page)

      CSV.new(page.content, headers: true)
    end

    def validate_response(page)
      content_type = page.response["content-type"]
      return if page.code == "200" && content_type == "text/csv"

      if content_type == "application/json"
        raise Error, "Unexpected error occurred while fetching purchase CSV: #{page.content}"
      end

      raise Error, "Unexpected error occurred while fetching purchase CSV: Response code #{page.code}"
    end
  end
end
