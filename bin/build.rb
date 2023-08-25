#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'

require 'English'
require 'fileutils'

require 'corgibytes/freshli/commons/execute'
# rubocop:disable Style/MixinUsage
include Corgibytes::Freshli::Commons::Execute
# rubocop:enable Style/MixinUsage

enable_dotnet_command_colors

status = execute('./gradlew installDist')

exit(status.exitstatus)
