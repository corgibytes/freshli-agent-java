When('I wait for the {channel} to contain:') do |channel, doc_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the freshli_agent.proto gRPC service is running on port {int}') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

When('the gRPC service on port {int} is sent the shutdown command') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

def port_available?(port)
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

Then('there are no services running on port {int}') do |port|
  expect(port_available?(port)).to be_truthy
end

Given('a test service is started on port {int}') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

When('the test service running on port {int} is stopped') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

# based on https://github.com/cucumber/aruba/blob/dab4d104ba178a9921a81ff17b31b80a607f6622/lib/aruba/cucumber/command.rb#L88..L101
When('I wait for the output to contain a port number and capture it') do
  Timeout.timeout(60) do
    loop do
      output = last_command_started.public_send :stdout, wait_for_io: 0

      output   = sanitize_text(output)

      if output.match?(/\d+/)
        @captured_port = output.to_i
        break
      end

      sleep 0.1
    end
  end
end

Then('the freshli_agent.proto gRPC service is running on the captured port') do
  pending # Write code here that turns the phrase above into concrete actions
end

When('the gRPC service on the captured port is sent the shutdown command') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('there are no services running on the captured port') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the captured port should be within the range {int} to {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('a test service is started on every port within the range {int} to {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

When('each test service running on every port within the range {int} to {int} is stopped') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('there are no services running on every port within the range {int} to {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end
