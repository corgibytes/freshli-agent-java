# frozen_string_literal: true

require 'rubygems'
require 'aruba/cucumber'

Aruba.configure do |config|
  # Timeout after waiting for 5 minutes
  config.exit_timeout = 300
  # Use aruba working directory
  config.home_directory = File.join(config.root_directory, config.working_directory)
  # include the `freshli-agent-java` native image from the build directory in the path
  config.command_search_paths << File.expand_path('../../build/jpackage/freshli-agent-java', __dir__)
end

# Contains helper methods for coping with platform specific differences
module Platform
  def self.null_output_target
    Gem.win_platform? ? 'NUL:' : '/dev/null'
  end

  def self.normalize_file_separators(value)
    value.gsub('/', file_separator)
  end

  def self.file_separator
    File::ALT_SEPARATOR || File::SEPARATOR
  end
end
