#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'optparse'

require_relative './support/execute'

perform_rubocop = true

parser = OptionParser.new do |options|
  options.banner = <<~BANNER
    Description:
        Linter Runner

    Usage:
        lint.rb [options]

    Options:
  BANNER

  options.on('--skip-rubocop', 'Does not run the Rubocop linter') do
    perform_rubocop = false
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

linter_failed = false

if perform_rubocop
  status = execute("bundle check > #{null_output_target}")
  status = execute('bundle install') unless status.success?

  status = execute('bundle exec rubocop --color') if status.success?

  linter_failed = !status.success?
end

if linter_failed
  puts 'At least one linter encountered errors'
  exit(-1)
end
exit(0)
