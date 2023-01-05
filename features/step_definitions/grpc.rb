def verify_grpc_is_running_on(port)
  client = Grpc::Health::V1::Health::Stub.new("localhost:#{port}", :this_channel_is_insecure)
  response = client.check(Grpc::Health::V1::HealthCheckRequest.new(service: Com::Corgibytes::Freshli::Agent::Agent::Service.service_name))
  expect(response.status).to eq(:SERVING)
end

Then('the freshli_agent.proto gRPC service is running on port {int}') do |port|
  verify_grpc_is_running_on(port)
end

def send_shutdown_to_grpc_on(port)
  client = Com::Corgibytes::Freshli::Agent::Agent::Stub.new("localhost:#{port}", :this_channel_is_insecure)
  response = client.shutdown(::Google::Protobuf::Empty.new)
  expect(response).to be_a(::Google::Protobuf::Empty)
end

When('the gRPC service on port {int} is sent the shutdown command') do |port|
  send_shutdown_to_grpc_on(port)
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
test_services = TestServices.new

Given('a test service is started on port {int}') do |port|
  test_services.start_on(port)
end

When('the test service running on port {int} is stopped') do |port|
  test_services.stop_on(port)
end

# based on https://github.com/cucumber/aruba/blob/dab4d104ba178a9921a81ff17b31b80a607f6622/lib/aruba/cucumber/command.rb#L88..L101
When('I wait for the output to contain a port number and capture it') do
  Timeout.timeout(60) do
    loop do
      output = last_command_started.public_send :stdout, wait_for_io: 0

      output = sanitize_text(output)
      if output.match?(/\d+/)
        @captured_port = output.to_i
        break
      end

      sleep 0.1
    end
  end
end

Then('the freshli_agent.proto gRPC service is running on the captured port') do
  verify_grpc_is_running_on(@captured_port)
end

When('the gRPC service on the captured port is sent the shutdown command') do
  send_shutdown_to_grpc_on(@captured_port)
end

Then('there are no services running on the captured port') do
  expect(port_available?(@captured_port)).to be_truthy
end

Then('the captured port should be within the range {int} to {int}') do |range_start, range_end|
  expect(range_start..range_end).to cover(@captured_port)
end

Given('a test service is started on every port within the range {int} to {int}') do |range_start, range_end|
  (range_start..range_end).each do |port|
    test_services.start_on(port)
  end
end

When('each test service running on every port within the range {int} to {int} is stopped') do |range_start, range_end|
  (range_start..range_end).each do |port|
    test_services.stop_on(port)
  end
end

Then('there are no services running on every port within the range {int} to {int}') do |range_start, range_end|
  (range_start..range_end).each do |port|
    expect(port_available?(port)).to be_truthy
  end
end
