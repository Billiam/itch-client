# frozen_string_literal: true

require "csv"
require "json"

require_relative "require_auth"
require_relative "simple_inspect"
require_relative "reward"
require_relative "request"

module Itch
  # Fetch rewards and history
  class Rewards
    include SimpleInspect
    include RequireAuth
    include Request

    REWARD_DATA = /GameEdit\.EditRewards\(.*?(?:"rewards":(\[.*?\]),)?"reward_noun":"(.*?)(?<!\\)"/.freeze

    def initialize(agent, game_id)
      @agent = agent
      @game_id = game_id
    end

    def history
      page = with_login do
        @agent.get(csv_url)
      end

      validate_response(page, action: "fetching reward CSV", content_type: "text/csv")

      CSV.new(page.content, headers: true)
    end

    def list
      rewards, _noun = fetch_rewards_data

      return [] unless rewards

      build_rewards(rewards)
    end

    def save(rewards)
      _rewards, noun = fetch_rewards_data

      post_data = build_post_data(rewards, noun)

      result = @agent.post rewards_url, post_data

      validate_response(result, action: "updating rewards")

      list
    end

    protected

    # rubocop:disable Metrics/MethodLength
    def build_post_data(rewards, noun)
      rewards.map.with_index do |reward, index|
        {
          "rewards[#{index}][title]" => reward.title,
          "rewards[#{index}][description]" => reward.description,
          "rewards[#{index}][price]" => reward.price,
          "rewards[#{index}][amount]" => reward.amount
        }.tap do |data|
          data["rewards[#{index}][archived]"] = "on" if reward.archived

          data["rewards[#{index}][id]"] = reward.id if reward.id
        end
      end.inject({ "reward_noun" => noun }, &:merge)
    end

    def build_rewards(data)
      JSON.parse(data).map do |reward|
        Reward.new(
          id: reward["id"],
          description: reward["description"],
          title: reward["title"],
          amount: reward["amount"],
          price: reward["price"],
          claimed: reward["claimed_count"],
          archived: reward["archived"]
        )
      rescue StandardError
        []
      end
    end
    # rubocop:enable Metrics/MethodLength

    def fetch_rewards_data
      page = with_login do
        @agent.get(rewards_url)
      end

      raise Error, "Could not find game id #{@game_id} rewards" unless page.code == "200"

      script = page.css("script").find do |node|
        node.text =~ REWARD_DATA
      end.text

      REWARD_DATA.match(script)[1..]
    end

    def parse_row(row)
      id = row.css('input[type="hidden"]').find do |input|
        input.name.match(/^rewards\[(\d+)\]\[id\]/)
      end.value

      attributes = %w[title description amount price].to_h do |name|
        [name.to_sym, row.css_at(".reward_#{name}_input").value]
      end
      attributes[:claimed] = row.css_at(".claimed_count").text

      Reward.new(@agent, @game_id, id, attributes)
    end

    def rewards_url
      format(Itch::URL::REWARDS, id: @game_id)
    end

    def csv_url
      format(Itch::URL::REWARD_CSV, id: @game_id)
    end
  end
end
