Feature: `validating-package-urls` command

  This command is used by the `freshli agent verify` command to get a list of package urls that are known to work when
  provided as inputs to the `freshli-agent-java retrieve-release-history` command.

  Scenario: Output the repository urls
    When I run `freshli-agent-java validating-package-urls`
    Then the output should contain:
    """
    pkg:maven/org.apache.maven/apache-maven
    pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease
    pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease
    """
