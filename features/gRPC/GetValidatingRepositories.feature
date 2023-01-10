Feature: Invoke GetValidatingRepositories via gRPC

  The `GetValidatingRepositories` gRPC call is used by the `freshli agent verify` command to get a list of repository
  urls that are known to work when running against the `DetectManifests` and `ProcessManifest` gRPC calls.

  Scenario: Get the repository urls
    When I run `freshli-agent-java start-server 8192` interactively
    And I wait for output to contain:
    """
    Listening on 8192...
    """
    And I call GetValidatingRepositories on port 8192
    Then GetValidatingRepositories response should contain:
    """
    https://github.com/corgibytes/freshli-fixture-java-maven-version-range
    https://github.com/questdb/questdb
    https://github.com/protocolbuffers/protobuf
    https://github.com/serverless/serverless
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status code should be 0
