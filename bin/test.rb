#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'optparse'

require_relative './support/execute'

enable_dotnet_command_colors

perform_build = true

parser = OptionParser.new do |options|
  options.banner = <<~BANNER
    Description:
        Test Runner

    Usage:
        test.rb [options]

    Options:
  BANNER

  options.on('-s', '--skip-build', 'Run tests without first calling build') do
    perform_build = false
  end

  options.on('-h', '--help', 'Show help and usage information') do
    puts options
    exit
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  puts e
  puts parser
  exit(-1)
end

# based on https://stackoverflow.com/a/29743469/243215
def download(url, target_path)
  # rubocop:disable Security/Open
  require 'open-uri'
  download = URI.open(url)
  # rubocop:enable Security/Open
  IO.copy_stream(download, target_path)
end

status = execute("ruby #{File.dirname(__FILE__)}/build.rb") if perform_build

if status.nil? || status.success?
  status = execute("bundle check > #{null_output_target}")
  status = execute('bundle install') unless status.success?

  if status.success?
    status = execute(
      'bundle exec grpc_tools_ruby_protoc -I src/main/proto --ruby_out=features/step_definitions/grpc ' \
      '--grpc_out=features/step_definitions/grpc src/main/proto/freshli_agent.proto'
    )
  end

  if status.success?
    download(
      'https://raw.githubusercontent.com/grpc/grpc-java/3c5c2be7125d57ca48d69ad6aa2682e6d4094487/services/src' \
      '/main/proto/grpc/health/v1/health.proto',
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'health.proto'))
    )
    status = execute(
      'bundle exec grpc_tools_ruby_protoc -I tmp --ruby_out=features/step_definitions/grpc ' \
      '--grpc_out=features/step_definitions/grpc tmp/health.proto'
    )
  end

  status = execute('./gradlew test') if status.success?
  status = execute('bundle exec cucumber --color --backtrace') if status.success?
end

exit(status.exitstatus)
