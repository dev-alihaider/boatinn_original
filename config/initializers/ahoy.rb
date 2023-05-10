# frozen_string_literal: true

module Ahoy
  class Store < Ahoy::DatabaseStore # :nodoc:
  end
end

# Set to true for JavaScript tracking.
Ahoy.api = false

# Better user agent parsing.
Ahoy.user_agent_parser = :device_detector

# Create server-side visits only when needed by events.
Ahoy.server_side_visits = :when_needed

# Customize Ahoy which uses Safely to rescue exceptions via Rollbar.
Safely.report_exception_method = ->(e) { Rollbar.error(e) }
