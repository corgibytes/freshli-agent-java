# frozen_string_literal: true

require 'rspec/expectations'

# Controls running test services on specific ports. Used to force a specific port to be in use.
class TestServices
  include RSpec::Matchers

  def initialize
    @test_services = {}
  end

  def start_on(port)
    expect(@test_services).not_to have_key(port)

    socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
    socket.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))

    @test_services[port] = socket
  end

  def stop_on(port)
    expect(@test_services).to have_key(port)

    @test_services[port].close
  end
end
