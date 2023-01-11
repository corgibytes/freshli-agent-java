#!/usr/bin/env ruby
# frozen_string_literal: true

# This script helps with cleaning up gRPC servers that might be left running when some of the tests fail.
# You can pass it multiple port arguments separated by spaces, and it will attempt to connect to and close each one.

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'features', 'support')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'features', 'step_definitions', 'grpc')))

require 'grpc_client'

ARGV.each do |port|
  GrpcClient.new(port).shutdown!
end
