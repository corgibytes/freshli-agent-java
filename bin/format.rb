#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'corgibytes/freshli/commons/execute'
# rubocop:disable Style/MixinUsage
include Corgibytes::Freshli::Commons::Execute
# rubocop:enable Style/MixinUsage

status = execute("bundle check > #{null_output_target}")
status = execute('bundle install') unless status.success?

rubocop_status = execute('bundle exec rubocop --autocorrect --color') if status.success?

composite_exitstatus = rubocop_status.exitstatus

exit(composite_exitstatus)
