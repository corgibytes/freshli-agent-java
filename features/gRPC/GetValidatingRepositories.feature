Feature: Invoke GetValidatingRepositories via gRPC

  The `GetValidatingRepositories` gRPC call is used by the `freshli agent verify` command to get a list of repository
  urls that are known to work when running against the `DetectManifests` and `ProcessManifest` gRPC calls.

  Background: The gRPC server is running on a randomly assigned port that has been captured for later use
    When I run `freshli-agent-java start-server`
    And I wait for the output to contain a port number and capture it
    Then the exit status should be 0

  Scenario: Get the repository urls
    When I call GetValidatingRepositories on the captured port
    Then GetValidatingRepositories response should contain:
    """
    https://github.com/corgibytes/freshli-fixture-java-maven-version-range
    https://github.com/questdb/questdb
    https://github.com/protocolbuffers/protobuf
    https://github.com/serverless/serverless
    """
    When the gRPC service on the captured port is sent the shutdown command
    Then there are no services running on the captured port
