# frozen_string_literal: true

module Itch
  # Mix in for request validation and response parsing
  module Request
    # rubocop:disable all
    def validate_response(page, action: "making request", content_type: "text/html")
      response_type = page.response["content-type"]
      return if page.code == "200" && response_type == content_type

      unless response_type == "application/json"
        raise Error, "Unexpected error occurred while #{action}: Response code #{page.code}"
      end

      error_data = nil
      begin
        data = JSON.parse(page.content)
        if data["errors"]
          error_data = data["errors"].respond_to?(:join) ? "\n#{data["errors"].join("\n")}" : data["errors"]
        end
      rescue StandardError
        raise Error, "Error parsing response while #{action}"
      end

      raise Error, "Unexpected error occurred while #{action}: #{error_data}"
    end
    # rubocop:enable all
  end
end
