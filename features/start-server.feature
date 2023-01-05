Feature: `start-server` command

  The `start-server` starts a gRPC server as described in `freshli_agent.proto`. The command
  can be used to start a server at a specific port or a randomly chosen port. If a specific port
  number is provided, then the server is started and the process blocks until either the process
  is terminated or the `Shutdown` RPC function is called. Once the gRPC server is ready for
  connections, then a message is written to the console. If the specified port is not available,
  then the process terminates immediately with a non-zero exit code after outputting an error code
  to STDERR. When a port is not provided, then a potential port number is randomly generated and
  the `start-server` command is run in another process. If that process fails to start, presumably
  because the port is not available, then starting the server is attempted again with another
  randomly generated port number. If the server fails to start after 100 attempts then the process
  will stop with a non-zero exit code and an error message will be written to the console. If the
  server started in the spawn process, then the randomly generated port number is written to the
  console, and the process stops with a zero exit code.

  Scenario: Starting the server with a provided port number
    Given there are no services running on port 8124
    When I run `freshli-agent-java start-server 8124` interactively
    And I wait for output to contain:
    """
    Listening on 8124...
    """
    Then the freshli_agent.proto gRPC service is running on port 8124
    When the gRPC service on port 8124 is sent the shutdown command
    Then there are no services running on port 8124
    And the exit status should be 0

  Scenario: Starting the service with a provided port number that is already in use
    Given a test service is started on port 8125
    When I run `freshli-agent-java start-server 8125`
    Then the output should contain:
    """
    Unable to start the gRPC service. Port 8125 is in use.
    """
    And the exit status should not be 0
    When the test service running on port 8125 is stopped
    Then there are no services running on port 8125

  Scenario: Starting the service on a randomly chosen port
    When I run `freshli-agent-java start-server`
    And I wait for the output to contain a port number and capture it
    Then the exit status should be 0
    And the freshli_agent.proto gRPC service is running on the captured port
    When the gRPC service on the captured port is sent the shutdown command
    Then there are no services running on the captured port

  Scenario: Starting the service on a randomly chosen port within a range of allowed values
    Given there are no services running on port 8120
    And there are no services running on port 8121
    And I set the environment variable "FRESHLI_AGENT_SERVER_PORT_RANGE" to "8120:8121"
    When I run `freshli-agent-java start-server`
    And I wait for the output to contain a port number and capture it
    Then the exit status should be 0
    And the captured port should be within the range 8120 to 8121
    And the freshli_agent.proto gRPC service is running on the captured port
    When the gRPC service on the captured port is sent the shutdown command
    Then there are no services running on the captured port

  Scenario: Starting the service on a randomly chosen port within a range of allowed values when only port is available
    Given a test service is started on port 8130
    Given there are no services running on port 8131
    And I set the environment variable "FRESHLI_AGENT_SERVER_PORT_RANGE" to "8130:8131"
    When I run `freshli-agent-java start-server`
    And I wait for the output to contain a port number and capture it
    Then the exit status should be 0
    And the captured port should be within the range 8130 to 8131
    And the freshli_agent.proto gRPC service is running on the captured port
    When the gRPC service on the captured port is sent the shutdown command
    Then there are no services running on the captured port
    When the test service running on port 8130 is stopped
    Then there are no services running on port 8130

  Scenario: Starting the service on a randomly chosen port within a range of allowed values when all ports are in use
    Given a test service is started on port 8140
    And a test service is started on port 8141
    And I set the environment variable "FRESHLI_AGENT_SERVER_PORT_RANGE" to "8140:8141"
    When I run `freshli-agent-java start-server`
    Then the exit status should not be 0
    And the output should contain:
    """
    Unable to start service. All ports with range 8140:8141 are in use.
    """
    When the test service running on port 8140 is stopped
    Then there are no services running on port 8140
    When the test service running on port 8141 is stopped
    Then there are no services running on port 8141

  Scenario: Starting the service on a randomly chosen port should give up after 100 attempts
    Given a test service is started on every port within the range 8150 to 8300
    And I set the environment variable "FRESHLI_AGENT_SERVER_PORT_RANGE" to "8150:8300"
    When I run `freshli-agent-java start-server`
    Then the exit status should not be 0
    And the output should contain:
    """
    Unable to start service. Gave up after trying 100 times to find an open port within the range 8150:8300.
    """
    When each test service running on every port within the range 8150 to 8300 is stopped
    Then there are no services running on every port within the range 8150 to 8300
