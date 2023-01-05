Then('the freshli_agent.proto gRPC service is running on port {int}') do |port|
  GrpcClient.new(port).is_running!
end

When('the gRPC service on port {int} is sent the shutdown command') do |port|
  GrpcClient.new(port).shutdown!
end

Then('there are no services running on port {int}') do |port|
  expect(Ports.available?(port)).to be_truthy
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
  GrpcClient.new(@captured_port).is_running!
end

When('the gRPC service on the captured port is sent the shutdown command') do
  GrpcClient.new(@captured_port).shutdown!
end

Then('there are no services running on the captured port') do
  expect(Ports.available?(@captured_port)).to be_truthy
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
    expect(Ports.available?(port)).to be_truthy
  end
end

When('I call DetectManifests with the full path to {string} on the captured port') do |project_path|
  expanded_path = Platform.normalize_file_separators(File.expand_path(File.join(aruba.config.home_directory, project_path)))
  @detect_manifests_paths = GrpcClient.new(@captured_port).detect_manifests(expanded_path)
end

Then('the DetectManifests response contains the following file paths expanded beneath {string}:') do |project_path, doc_string|
  expected_paths = []
  doc_string.each_line do |file_path|
    expected_paths << Platform.normalize_file_separators(File.expand_path(File.join(aruba.config.home_directory, project_path, file_path.strip)))
  end

  expect(@detect_manifests_paths).to eq(expected_paths)
end
