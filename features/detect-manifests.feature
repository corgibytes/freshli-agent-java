Feature: `detect-manifests` command
  The `detect-manifests` command is used to detect the manifest files in a directory tree that will be used to generate
  CycloneDX-based bill of materials (bom) files. For Maven projects, this isn't as simple as just returning a list of
  files that are named `pom.xml`. This is because some `pom.xml` files references to other `pom.xml`, known as module
  references. For our purposes, we only want to list `pom.xml` files that are not listed as a module in another
  `pom.xml` file.

  The command accepts one parameter, the path to a directory that should be scanned for manifest files.

  For each manifest file that is listed, the output needs to contain the relative path to the file from the root of the
  directory that was provided as a parameter. Each line of the output should contain a single manifest file.

  Scenario: A multi-module project with a `pom.xml` file in the root directory
    This project contains several `pom.xml` files, but since all but the root file is a sub-module, then only the root
    `pom.xml` file should be included in the output.

    Given I clone the git repository "https://github.com/questdb/questdb" with the sha "3fedfed87ff8ed5d29752472b0f34b1e13c30172"
    When I run `freshli-agent-java detect-manifests tmp/repositories/questdb`
    Then it should pass with exactly:
    """
    pom.xml
    """

  Scenario: A multi-module project located in a sub-directory
    This project contains several `pom.xml` files. All of the files appear within the `java` directory or one of it's
    sub-directories. The file located at `java/pom.xml` references all of the other `pom.xml` files as sub-modules.

    Given I clone the git repository "https://github.com/protocolbuffers/protobuf" with the sha "b39e9b3cff331d84f504699b16ff60d2596d9535"
    When I run `freshli-agent-java detect-manifests tmp/repositories/protobuf`
    Then it should pass with exactly:
    """
    java/pom.xml
    """
    And the exit status should be 0

  Scenario: Unrelated modules located in sub-directories
    This project contains two `pom.xml` files, neither of which has any sub-modules. Therefore, each file should be
    listed.

    Given I clone the git repository "https://github.com/serverless/serverless" with the sha "076661f99503c24204ea5ebca6beaab79f39106d"
    When I run `freshli-agent-java detect-manifests tmp/serverless`
    Then it should pass with exactly:
    """
    docs/providers/openwhisk/examples/hello-world/java/pom.xml
    lib/plugins/aws/invoke-local/runtime-wrappers/java/pom.xml
    """
