#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

require_relative './support/execute'

enable_dotnet_command_colors

status = execute('./gradlew installDist')

exit(status.exitstatus)
