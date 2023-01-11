Feature: Invoking DetectManifests via gRPC
  The `DetectManifests` gRPC call is used to detect the manifest files in a directory tree that will be used to generate
  CycloneDX-based bill of materials (bom) files. For Maven projects, this isn't as simple as just returning a list of
  files that are named `pom.xml`. This is because some `pom.xml` files references to other `pom.xml`, known as module
  references. For our purposes, we only want to list `pom.xml` files that are not listed as a module in another
  `pom.xml` file.

  The call is provided with the full path to a directory that should be scanned for manifest files.

  For each manifest file that is listed, the response needs to contain the full path to the file.

  Scenario: A multi-module project with a `pom.xml` file in the root directory
  This project contains several `pom.xml` files, but since all but the root file is a sub-module, then only the root
  `pom.xml` file should be included in the output.

    Given I clone the git repository "https://github.com/questdb/questdb" with the sha "0b465538639e24850e3471bdb0a234c20d8af58b"
    When I run `freshli-agent-java start-server 8192` interactively
    And I wait for output to contain:
    """
    Listening on 8192...
    """
    And I call DetectManifests with the full path to "tmp/repositories/questdb" on port 8192
    Then the DetectManifests response contains the following file paths expanded beneath "tmp/repositories/questdb":
    """
    pom.xml
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: A multi-module project located in a sub-directory along with `pom.xml` files in other directories
  This project contains several `pom.xml` files. Many of the files appear within the `java` directory or one of it's
  sub-directories. The file located at `java/pom.xml` references all but one of the `pom.xml` files in the `java`
  directory as sub-modules. The rest of the `pom.xml` files contain no modules.

    Given I clone the git repository "https://github.com/protocolbuffers/protobuf" with the sha "d8421bd49c1328dc5bcaea2e60dd6577ac235336"
    When I run `freshli-agent-java start-server 8192` interactively
    And I wait for output to contain:
    """
    Listening on 8192...
    """
    And I call DetectManifests with the full path to "tmp/repositories/protobuf" on port 8192
    Then the DetectManifests response contains the following file paths expanded beneath "tmp/repositories/protobuf":
    """
    java/pom.xml
    java/protoc/pom.xml
    protoc-artifacts/pom.xml
    ruby/pom.xml
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: Unrelated modules located in sub-directories
  This project contains two `pom.xml` files, neither of which has any sub-modules. Therefore, each file should be
  listed.

    Given I clone the git repository "https://github.com/serverless/serverless" with the sha "9c2ebb78d8db30acde24bd31efa1d6516d177b0e"
    When I run `freshli-agent-java start-server 8192` interactively
    And I wait for output to contain:
    """
    Listening on 8192...
    """
    And I call DetectManifests with the full path to "tmp/repositories/serverless" on port 8192
    Then the DetectManifests response contains the following file paths expanded beneath "tmp/repositories/serverless":
    """
    docs/providers/openwhisk/examples/hello-world/java/pom.xml
    lib/plugins/aws/invoke-local/runtime-wrappers/java/pom.xml
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0
