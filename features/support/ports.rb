# frozen_string_literal: true

# Contains utility methods for working with IP ports, specifically determining which ones are available for use.
module Ports
  def self.available?(port)
    # based on https://stackoverflow.com/a/34375147/243215
    require 'socket'
    max_attempts = 100
    attempts = 0
    begin
      attempts += 1
      socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      socket.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))
      socket.close
      true
    rescue Errno::EADDRINUSE
      if attempts < max_attempts
        sleep 0.1
        retry
      end
      false
    end
  end
end
