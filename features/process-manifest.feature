Feature: `process-manifest` command
  This command is used to by the `freshli` CLI to instruct the agent to generate a CycloneDX bill of materials (BOM)
  file for a dependency manifest file. In the case of `freshli-agent-java`, these dependency manifest files will be
  `pom.xml` files. In addition to requiring the path to the manifest file that should be processed, this command needs
  to know the date that should be used when resolving dependency version ranges. The range will be resolved to the
  latest version that satisfies the range as of the provided date.

  Scenario: Simple project with version range
    This project uses a range expression to reference the `commons-io` library. On January 1st, 2021, the latest version
    of that package was `2.8.0`. That is the date that the version range should be resolved to, and the appropriate
    package url for that version should show up in the generated CycloneDX BOM file.

    Given I clone the git repository "https://github.com/corgibytes/freshli-fixture-java-maven-version-range" with the sha "2260b7cc3b7ae2b0ff80c818a8ec70ae82cd14ec"
    When I run `freshli-agent-java process-manifest tmp/repositories/freshli-fixture-java-maven-version-range/pom.xml 2021-01-01T00:00:00Z`
    Then it should pass with exact output containing file paths:
    """
    tmp/repositories/freshli-fixture-java-maven-version-range/target/bom.json
    """
    And the CycloneDX file "tmp/repositories/freshli-fixture-java-maven-version-range/target/bom.json" should be valid
    And the CycloneDX file "tmp/repositories/freshli-fixture-java-maven-version-range/target/bom.json" should contain "pkg:maven/commons-io/commons-io@2.8.0?type=jar"
    And running git status should not report any modifications for "tmp/repositories/freshli-fixture-java-maven-version-range"

  Scenario: Multi-module project without any version ranges
    This project contains sub-modules and the dependencies for the sub-modules need to be included in the resulting
    CycloneDX BOM file. This project does not use any date ranges, so the date parameter essentially has no effect, but
    it is still required.

    Given I clone the git repository "https://github.com/questdb/questdb" with the sha "0b465538639e24850e3471bdb0a234c20d8af58b"
    When I run `freshli-agent-java process-manifest tmp/repositories/questdb/pom.xml 2022-08-23T19:45:55Z`
    Then it should pass with exact output containing file paths:
    """
    tmp/repositories/questdb/target/bom.json
    """
    And the CycloneDX file "tmp/repositories/questdb/target/bom.json" should be valid
    And the CycloneDX file "tmp/repositories/questdb/target/bom.json" should contain "pkg:maven/org.slf4j/slf4j-api@1.7.7?type=jar"
    And the CycloneDX file "tmp/repositories/questdb/target/bom.json" should contain "pkg:maven/com.chrisnewland/jitwatch@1.0.0?type=jar"
    And the CycloneDX file "tmp/repositories/questdb/target/bom.json" should contain "pkg:maven/com.google.code.gson/gson@2.9.0?type=jar"
    And running git status should not report any modifications for "tmp/repositories/questdb"

  Scenario: A multi-module project located in a sub-directory
    Given I clone the git repository "https://github.com/protocolbuffers/protobuf" with the sha "d8421bd49c1328dc5bcaea2e60dd6577ac235336"
    When I run `freshli-agent-java process-manifest tmp/repositories/protobuf/java/pom.xml 2022-08-23T19:45:55Z`
    Then it should pass with exact output containing file paths:
    """
    tmp/repositories/protobuf/java/target/bom.json
    """
    And the CycloneDX file "tmp/repositories/protobuf/java/target/bom.json" should be valid
    And running git status should not report any modifications for "tmp/repositories/protobuf"
