module Ports
  def self.available?(port)
    # based on https://stackoverflow.com/a/34375147/243215
    require 'socket'
    begin
      socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      socket.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))
      socket.close
      true
    rescue Errno::EADDRINUSE;
      false
    end
  end
end
