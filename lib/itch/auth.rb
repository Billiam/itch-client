# frozen_string_literal: true

require_relative "simple_inspect"

module Itch
  # Authentication flow handler
  class Auth
    include SimpleInspect

    attr_writer :username, :password, :totp

    def initialize(agent, username: nil, password: nil, cookie_path: nil)
      @agent = agent
      @cookie_path = cookie_path
      @username = username
      @password = password
      @totp = -> {}
    end

    def logged_in?
      @agent.get(Itch::URL::DASHBOARD).uri.to_s == Itch::URL::DASHBOARD
    end

    def login
      page = @agent.get(Itch::URL::LOGIN)
      return unless page.code == "200"
      raise AuthError, "Email and password are required for login" if @username.nil? || @password.nil?

      page = submit_login(page) if page_is_login?(page)
      submit_2fa(page) if page_is_2fa?(page)

      save_cookies
    end

    def page_is_login?(page)
      page.uri.to_s == Itch::URL::LOGIN
    end

    def page_is_2fa?(page)
      page.uri.to_s.start_with?(Itch::URL::TOTP_FRAGMENT)
    end

    protected

    def save_cookies
      @agent.cookie_jar.save(@cookie_path) if @cookie_path
    end

    def submit_2fa(page)
      form = page.form_with(action: page.uri.to_s)
      form.code = totp_code
      page = form.submit

      if page_is_2fa?(page)
        # 2fa failed
        errors = page.css(".form_errors li").map(&:text)
        raise AuthError, "#{errors.size} error#{errors.size == 1 ? "" : "s"} prevented 2fa validation", errors
      end

      page
    end

    def totp_code
      code = @totp.call
      raise AuthError, "TOTP code is required" if code.nil? || code.empty?

      code.chomp
    end

    def password
      return @password.call if @password.respond_to? :call

      @password
    end

    def username
      return @username.call if @username.respond_to? :call

      @username
    end

    def submit_login(page)
      form = page.form_with(action: Itch::URL::LOGIN)

      form.username = username
      form.password = password

      page = form.submit

      if page_is_login?(page)
        # Login failed
        errors = page.css(".form_errors li").map(&:text)
        raise AuthError.new("#{errors.size} error#{errors.size == 1 ? "" : "s"} prevented login", errors: errors)
      end

      page
    end
  end
end
