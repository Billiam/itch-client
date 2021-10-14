# frozen_string_literal: true

require_relative "simple_inspect"

module Itch
  # Data container for single bundle
  class Bundle
    include SimpleInspect

    attr_accessor :id, :title, :games, :purchases, :price, :earnings

    def initialize(id, title, purchases, price, earnings)
      @id = id
      @title = title
      @purchases = purchases
      @price = price
      @earnings = earnings
    end

    def url
      format(Itch::URL::BUNDLE, id: @id)
    end
  end
end
