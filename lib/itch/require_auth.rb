# frozen_string_literal: true

module Itch
  # Mixin to raise exceptions when a request redirects to login page
  module RequireAuth
    def require_auth(page)
      raise AuthError, "User is not logged in" if page.uri.to_s == Itch::URL::LOGIN

      page
    end

    def with_login
      require_auth yield
    end
  end
end
