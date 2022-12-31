Feature: `validating-repositories` command

  This command is used by the `freshli agent verify` command to get a list of repository urls that are known to work
  when running against the `detect-manifests` and `process-manifest` command.

  Scenario: Output the repository urls
    When I run `freshli-agent-java validating-repositories`
    Then the output should contain:
    """
    https://github.com/corgibytes/freshli-fixture-java-maven-version-range
    https://github.com/questdb/questdb
    https://github.com/protocolbuffers/protobuf
    https://github.com/serverless/serverless
    """
