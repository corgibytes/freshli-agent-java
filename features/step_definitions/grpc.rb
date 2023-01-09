# frozen_string_literal: true

require 'time'
require 'google/protobuf/well_known_types'

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
  expect(Ports.available?(@captured_port) { |attempts| log(attempts) }).to be_truthy
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
  expanded_path = Platform.normalize_file_separators(
    File.expand_path(File.join(aruba.config.home_directory, project_path))
  )

  @detect_manifests_paths = GrpcClient.new(@captured_port).detect_manifests(expanded_path)
end

def expanded_paths_from(doc_string, project_path)
  result = []
  doc_string.each_line do |file_path|
    result << Platform.normalize_file_separators(
      File.expand_path(File.join(aruba.config.home_directory, project_path, file_path.strip))
    )
  end
  result
end

Then('the DetectManifests response contains the following file paths expanded beneath {string}:') do
  |project_path, doc_string|

  expected_paths = expanded_paths_from(doc_string, project_path)
  expect(@detect_manifests_paths).to eq(expected_paths)
end

When('I call GetValidatingPackages on the captured port') do
  @get_validating_packages_results = GrpcClient.new(@captured_port).get_validating_packages
end

Then('the GetValidatingPackages response should contain:') do |doc_string|
  expected_packages = []
  doc_string.each_line do |package_url|
    expected_packages << package_url.strip
  end

  expect(@get_validating_packages_results).to eq(expected_packages)
end

When('I call GetValidatingRepositories on the captured port') do
  @get_validating_repositories_results = GrpcClient.new(@captured_port).get_validating_repositories
end

Then('GetValidatingRepositories response should contain:') do |doc_string|
  expected_repositories = []
  doc_string.each_line do |repository|
    expected_repositories << repository.strip
  end

  expect(@get_validating_repositories_results).to eq(expected_repositories)
end

When('I call ProcessManifest with the expanded path {string} and the moment {string} on the captured port') do
  |manifest_path, moment_in_time|

  expanded_path = Platform.normalize_file_separators(
    File.expand_path(File.join(aruba.config.home_directory, manifest_path))
  )
  @process_manifest_result = GrpcClient.new(@captured_port).process_manifest(
    expanded_path, DateTime.parse(moment_in_time)
  )
end

Then('the ProcessManifest response contains the following file paths expanded beneath {string}:') do
  |project_path, doc_string|

  expected_paths = expanded_paths_from(doc_string, project_path)

  expect([@process_manifest_result]).to eq(expected_paths)
end

When('I call RetrieveReleaseHistory with {string} on the captured port') do |package_url|
  @retrieve_release_history_results = GrpcClient.new(@captured_port).retrieve_release_history(package_url)
end

Then('RetrieveReleaseHistory response should contain the following versions and release dates:') do |doc_string|
  expected_package_releases = []
  doc_string.each_line do |line|
    splits = line.strip.split("\t")
    expected_package_releases << { version: splits[0], released_at: DateTime.parse(splits[1]).new_offset('0:00') }
  end

  filtered_results = @retrieve_release_history_results.take(expected_package_releases.length)

  expect(filtered_results).to eq(expected_package_releases)
end

Then('RetrieveReleaseHistory response should be empty') do
  expect(@retrieve_release_history_results).to be_empty
end
