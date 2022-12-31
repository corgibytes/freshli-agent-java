Feature: Invoke GetValidatingPackages via gRPC

  The `GetValidatingPackages` gRPC call is used by the `freshli agent verify` command to get a list of package urls that
  are known to work when provided as inputs to the `RetrieveReleaseHistory` gRPC call.

  Background: The gRPC server is running on a randomly assigned port that has been captured for later use
    When I run `freshli-agent-java start-server`
    And I wait for the output to contain a port number and capture it
    Then the exit status should be 0

  Scenario: Output the repository urls
    When I call GetValidatingPackages
    Then the GetValidatingPackages response should contain:
    """
    pkg:maven/org.apache.maven/apache-maven
    pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease
    pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease
    """
    When the gRPC service on the captured port is sent the shutdown command
    Then there are no services running on the captured port
