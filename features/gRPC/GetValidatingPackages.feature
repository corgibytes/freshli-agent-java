Feature: Invoke GetValidatingPackages via gRPC

  The `GetValidatingPackages` gRPC call is used by the `freshli agent verify` command to get a list of package urls that
  are known to work when provided as inputs to the `RetrieveReleaseHistory` gRPC call.

  Scenario: Get the repository urls
    When I run `freshli-agent-java start-server 8192` interactively
    And I wait for output to contain:
    """
    Listening on 8192...
    """
    And I call GetValidatingPackages on port 8192
    Then the GetValidatingPackages response should contain:
    """
    pkg:maven/org.apache.maven/apache-maven
    pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease
    pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0
