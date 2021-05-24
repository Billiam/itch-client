# frozen_string_literal: true

require "forwardable"
require "mechanize"

require_relative "auth"
require_relative "game"
require_relative "game_map"
require_relative "purchases"
require_relative "simple_inspect"

module Itch
  # The primary client interface
  #
  # The top level client delegates to child modules for specific app areas
  # like game and purchases pages
  class Client
    extend Forwardable
    include SimpleInspect

    def_delegators :@auth, :logged_in?, :login, :totp=, :username=, :password=

    def initialize(username: nil, password: nil, cookie_path: nil)
      @agent = Mechanize.new
      @auth = Auth.new(@agent, username: username, password: password, cookie_path: cookie_path)

      @agent.cookie_jar.load(cookie_path) if cookie_path && File.readable?(cookie_path)
    end

    def game(id = nil, name: nil)
      Game.new(@agent, game_map, id, name: name)
    end

    def purchases
      @purchases ||= Purchases.new(@agent)
    end

    def game_map
      @game_map ||= GameMap.new(@agent)
    end
  end
end
