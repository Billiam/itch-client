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

    attr_reader :id, :name, :page_url

    THEME_DATA = /GameEdit\.ThemeEditor\((.*)\),\$\('#game_appearance_editor_widget_/.freeze

    def initialize(agent, map, id = nil, name: nil)
      raise Error, "Game ID or name is required" if id.nil? && name.nil?

      @agent = agent
      @map = map

      load_game_info(id, name)
    end

    def theme
      JSON.parse(theme_data)["theme"]
    rescue StandardError
      {}
    end

    def css
      theme["css"]
    end

    def theme=(theme_data)
      @agent.post edit_theme_url, theme_post_data(theme_data)
    end

    def css=(css_data)
      new_theme = theme
      new_theme["css"] = css_data
      self.theme = new_theme
    end

    def rewards
      Rewards.new(@agent, @id)
    end

    def reward(id)
      rewards.find { |reward| reward.id == id }
    end

    protected

    def load_game_info(id, name)
      if id
        data = @map.find!(id)
      elsif name
        data = @map.find_by_name!(name)
      else
        raise Error, "Name or ID is required when initializing Itch::Game"
      end

      @id = data[:id]
      @page_url = data[:url]
      @name = data[:name]
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def theme_post_data(new_theme)
      filtered_theme = new_theme.reject do |k, _v|
        %w[background_image background_repeat background_position banner_image banner_position].include?(k)
      end

      post_data = filtered_theme.transform_keys do |k|
        "layout[#{k}]"
      end.merge({ "csrf_token" => theme_csrf_token })

      if new_theme["background_image"]
        post_data["layout[background_image][image_id]"] = new_theme["background_image"]["id"]
        post_data["layout[background_image][repeat]"] = new_theme["background_repeat"]
        post_data["layout[background_image][position]"] = new_theme["background_position"]
      end

      if new_theme["banner_image"]
        post_data["layout[banner_image][id]"] = new_theme["banner_image"]["id"]
        post_data["layout[banner_image][position]"] = new_theme["banner_position"]
      end

      post_data["header_font_family"] ||= "_default"

      post_data
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def theme_csrf_token
      page = with_login { game_page }

      page.at_css("meta[name='csrf_token']")["value"]
    end

    def theme_data
      page = with_login { game_page }

      script = page.css("script").find do |node|
        node.text =~ THEME_DATA
      end.text

      THEME_DATA.match(script)[1]
    end

    def edit_url
      format(Itch::URL::EDIT_GAME, id: @id)
    end

    def edit_theme_url
      "#{@page_url}/edit"
    end

    def form
      edit_page.form_with(action: edit_url)
    end

    def game_page
      @agent.get @page_url
    end

    def edit_page
      with_login do
        @agent.get edit_url
      end
    end
  end
end
