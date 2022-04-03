# frozen_string_literal: true

require_relative "simple_inspect"

module Itch
  # Data container for single review
  class Review
    include SimpleInspect

    attr_reader :id, :user_name, :user_id, :stars, :date, :review

    # rubocop:disable Metrics/ParameterLists
    def initialize(user_name:, user_id:, stars:, date:, review:, id: nil)
      @id = id
      @user_name = user_name
      @user_id = user_id
      @stars = stars
      @date = date
      @review = review
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
