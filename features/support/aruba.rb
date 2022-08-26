# frozen_string_literal: true

require 'aruba/cucumber'

Aruba.configure do |config|
  # Timeout after waiting for 5 minutes
  config.exit_timeout = 300
  # Use aruba working directory
  config.home_directory = File.join(config.root_directory, config.working_directory)
end
