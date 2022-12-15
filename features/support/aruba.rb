# frozen_string_literal: true

require 'aruba/cucumber'

Aruba.configure do |config|
  # Timeout after waiting for 5 minutes
  config.exit_timeout = 300
  # Use aruba working directory
  config.home_directory = File.join(config.root_directory, config.working_directory)
  # include the `freshli-agent-java` run scripts from the build directory in the path
  config.command_search_paths << File.expand_path('../../../build/install/freshli-agent-java/bin', __FILE__)
end

module Platform
  def self.null_output_target
    Gem.win_platform? ? 'NUL:' : '/dev/null'
  end
end
