# frozen_string_literal: true

require_relative "rewards"
require_relative "reward"
require_relative "require_auth"
require_relative "simple_inspect"

module Itch
  # Represents a single game and sub-resources
  class Game
    include RequireAuth
    include SimpleInspect

    attr_reader :id

    def initialize(agent, map, id = nil, name: nil)
      @agent = agent

      raise Error, "Game ID or name is required" if id.nil? && name.nil?

      if id
        @id = id
      elsif name
        @id = map.call(name)
        raise Error, %(Cannot find game: "#{name}") unless @id
      end
    end

    def rewards
      Rewards.new(@agent, @id)
    end

    def reward(id)
      rewards.find { |reward| reward.id == id }
    end

    protected

    def edit_url
      format(Itch::URL::EDIT_GAME, id: @id)
    end

    def page_url
      format(Itch::URL::GAME, username: @username, slug: @slug)
    end

    def form
      edit_page.form_with(action: edit_url)
    end

    def game_page
      @agent.get page_url
    end

    def edit_page
      with_login do
        @agent.get edit_url
      end
    end
  end
end
