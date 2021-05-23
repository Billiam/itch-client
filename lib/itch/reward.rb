# frozen_string_literal: true

require "csv"

require_relative "simple_inspect"

module Itch
  # Data container for single reward
  class Reward
    include SimpleInspect

    attr_accessor :amount, :archived, :claimed, :description, :id, :price, :title

    # rubocop:disable Metrics/ParameterLists
    def initialize(amount:, description:, price:, title:, archived: false, claimed: 0, id: nil)
      @id = id
      @description = description
      @title = title
      @amount = amount
      @price = price
      @claimed = claimed
      @archived = archived
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
