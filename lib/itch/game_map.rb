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

    def map
      @map ||= begin
        page = with_login do
          @agent.get(Itch::URL::DASHBOARD)
        end

        parse_dashboard page
      end
    end

    def find_by_name(name)
      map[name]
    end

    def find_by_name!(name)
      result = find_by_name(name)
      raise Error, "Cannot find game with name #{name}" unless result

      result
    end

    def find!(id)
      result = find(id)
      raise Error, "Cannot find game with id #{id}" unless result

      result
    end

    def find(id)
      id = id.to_s
      map.values.find do |value|
        value[:id] == id
      end
    end

    protected

    def parse_dashboard(page)
      page.css(".game_row").map do |row|
        title = row.at_css(".game_title .game_link")
        name = title.text
        url = title["href"]
        edit_url = row.at_xpath('.//a[text()="Edit"]/@href').value

        id = edit_url.match(%r{/game/edit/(\d+)})[1]
        [name, { id: id, url: url, name: name }] if id && name
      end.compact.to_h
    end
  end
end
