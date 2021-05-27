# frozen_string_literal: true

require "csv"
require_relative "require_auth"
require_relative "simple_inspect"
require_relative "request"

module Itch
  # Return purchase history and history by date
  class Purchases
    include RequireAuth
    include SimpleInspect
    include Request

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

      validate_response(page, action: "fetching purchase CSV", content_type: "text/csv")

      CSV.new(page.content, headers: true)
    end
  end
end
