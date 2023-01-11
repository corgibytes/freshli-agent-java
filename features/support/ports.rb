# frozen_string_literal: true

# Contains utility methods for working with IP ports, specifically determining which ones are available for use.
module Ports
  # rubocop:disable Metrics/MethodLength
  def self.available?(port)
    max_attempts = 1000
    attempts = 0
    begin
      attempts += 1
      yield(attempts) if block_given?
      attempt_connection(port)
      true
    rescue Errno::EADDRINUSE
      if attempts < max_attempts
        sleep 0.1
        retry
      end
      false
    end
  end
  # rubocop:enable Metrics/MethodLength

  def self.attempt_connection(port)
    # based on https://stackoverflow.com/a/34375147/243215
    require 'socket'
    socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
    socket.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))
    socket.close
  end
end
