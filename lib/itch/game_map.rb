# frozen_string_literal: true

require "csv"

require_relative "simple_inspect"
require_relative "require_auth"

module Itch
  # Map game names to itch ids
  #
  # Could be handled via API, but would require user API keys or oauth
  class GameMap
    include SimpleInspect
    include RequireAuth

    def initialize(agent)
      @agent = agent
    end

    def call(name)
      map[name]
    end

    def map
      @map ||= begin
        page = with_login do
          @agent.get(Itch::URL::DASHBOARD)
        end

        parse_dashboard page
      end
    end

    protected

    def parse_dashboard(page)
      page.css(".game_row").map do |row|
        name = row.at_css(".game_title .game_link").text
        edit_url = row.at_xpath('.//a[text()="Edit"]/@href').value

        id = edit_url.match(%r{/game/edit/(\d+)})[1]
        [name, id] if id && name
      end.compact.to_h
    end
  end
end
