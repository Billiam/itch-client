# frozen_string_literal: true
require 'bigdecimal'

require_relative "simple_inspect"
require_relative "bundle"
require_relative "request"
require_relative "require_auth"


module Itch
  # Fetch bundles
  class Bundles
    include RequireAuth
    include SimpleInspect
    include Request

    def initialize(agent)
      @agent = agent
    end

    def list
      page = with_login do
        @agent.get(bundles_url)
      end

      page.css('.bundle_list table > tr').map do |row|
        parse_row(row)
      end
    end

    def parse_row(row)
      id = row.at_xpath('td[2]/a/@href').value.match(%r[^/b/(\d+)/])[1]
      vals = row.css('td').map(&:text)
      price = BigDecimal(vals[5].gsub(/[^\d.-]/, ''))
      earnings = BigDecimal(vals[6].gsub(/[\D-]/, ''))

      Bundle.new(id, vals[1], vals[4].to_i, price, earnings)
    end

    def bundles_url
      Itch::URL::BUNDLES
    end
  end
end
