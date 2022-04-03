# frozen_string_literal: true

require "json"

require_relative "require_auth"
require_relative "simple_inspect"
require_relative "review"
require_relative "request"

module Itch
  # Fetch reviews
  class Reviews
    include SimpleInspect
    include RequireAuth
    include Request

    def initialize(agent, game_id)
      @agent = agent
      @game_id = game_id
    end

    def list
      all_reviews = []

      page_number = 1
      loop do
        page = with_login do
          @agent.get(review_url(page_number))
        end

        raise Error, "Could not find game id #{@game_id} rewards" unless page.code == "200"

        page_reviews = page.css(".content_column .rating").map do |row|
          parse_row row
        end

        break if page_reviews.length == 0
        all_reviews += page_reviews
        page_number += 1
        sleep 0.5
      end

      all_reviews
    end

    protected

    def parse_row(row)
      id = row.at_css('button[data-lightbox_url]')['data-lightbox_url'].split('/').last
      stars = row.css('.star_picker .icon-star').length
      header = row.at_css('.row_header')
      date = DateTime.parse header.at_css('abbr')['title'].strip

      user_link = header.at_css('.user_link')
      user_name = user_link.search('./text()').text.strip
      user_id = user_link['href'].split('/').last

      text = row.css('.blurb p').map(&:text)

      Review.new(
        id: id,
        user_name: user_name,
        user_id: user_id,
        stars: stars,
        date: date,
        review: text
      )
    end

    def review_url(page = 1)
      format(Itch::URL::REVIEWS, id: @game_id, page: page)
    end
  end
end
