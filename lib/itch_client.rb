# frozen_string_literal: true

require_relative "itch/version"
require_relative "itch/client"

# Top level interface class, delegates to Itch::Client
module Itch
  class Error < StandardError; end

  # Authentication errors, includes individual error messages
  # in errors key
  class AuthError < Error
    attr_reader :errors

    def initialize(message, errors: [])
      super(message)
      @errors = errors
    end

    def message
      m = super

      return "#{m}\n\n#{errors.join("\n")}" if errors.any?

      m
    end
  end

  module URL
    DASHBOARD = "https://itch.io/dashboard"
    BUNDLES = "https://itch.io/dashboard/bundles"
    BUNDLE = "https://itch.io/bundle/%<id>d"
    EDIT_GAME = "https://itch.io/game/edit/%<id>d"
    GAME = "https://%<username>s.itch.io/%<slug>s"
    LOGIN = "https://itch.io/login"
    MONTH_PURCHASES_CSV = "https://itch.io/dashboard/export-purchases/by-date/%<month>d-%<year>d"
    PURCHASES_CSV = "https://itch.io/dashboard/export-purchases/all"
    REVIEWS = "https://itch.io/game/ratings/%<id>d?page=%<page>d"
    REWARD_CSV = "https://itch.io/game/rewards/%<id>d/claimed?format=csv"
    REWARDS = "https://itch.io/game/rewards/%<id>d"
    TOTP_FRAGMENT = "https://itch.io/totp/verify/"
    YEAR_PURCHASES_CSV = "https://itch.io/dashboard/export-purchases/by-date/%<year>d"
  end

  def self.new(**kwargs)
    Client.new(**kwargs)
  end
end
