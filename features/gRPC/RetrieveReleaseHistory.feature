Feature: Invoking RetrieveReleaseHistory via gRPC
  The `RetrieveReleaseHistory` gRPC call responds with the full release history for a package. The package is specified
  using a [PURL or Package URL](https://github.com/package-url/purl-spec).

  Results are sorted sorted by date with the oldest date provided first.

  Scenario: Valid Package URL
    Since the `RetrieveReleaseHistory` gRPC call always provides the full release history, it's expected that the
    version component will be omitted from the provided package url.

    Note: This scenario included all of the versions for the `apache-maven` package at the time that it was authored. It
    is expected that this scenario will still pass when newer versions become available and are added to the end of the
    output.

    When I run `freshli-agent-java start-server 8192` interactively
    Then I wait for the freshli_agent.proto gRPC service to be running on port 8192
    And I call RetrieveReleaseHistory with "pkg:maven/org.apache.maven/apache-maven" on port 8192
    Then RetrieveReleaseHistory response should contain the following versions and release dates:
    """
    2.0.9	2008-04-10T00:16:46Z
    2.1.0-M1	2008-09-18T19:58:12Z
    3.0-alpha-2	2009-02-05T06:22:38Z
    2.0.10	2009-02-10T02:57:59Z
    2.1.0	2009-03-18T19:16:55Z
    2.2.0	2009-06-26T13:08:51Z
    2.2.1	2009-08-06T19:18:53Z
    3.0-alpha-3	2009-11-09T16:08:33Z
    3.0-alpha-4	2009-11-13T18:10:27Z
    3.0-alpha-5	2009-11-23T15:58:15Z
    3.0-alpha-6	2010-01-06T11:06:09Z
    2.0.11	2010-02-12T05:57:11Z
    3.0-alpha-7	2010-03-09T22:34:35Z
    3.0-beta-1	2010-04-19T17:03:53Z
    3.0-beta-2	2010-08-07T11:03:55Z
    3.0-beta-3	2010-08-30T12:47:24Z
    3.0	2010-10-04T11:54:21Z
    3.0.1	2010-11-23T11:02:58Z
    3.0.2	2011-01-09T01:01:17Z
    3.0.3	2011-02-28T17:33:57Z
    3.0.4	2012-01-17T08:48:07Z
    3.0.5	2013-02-19T13:54:33Z
    3.1.0-alpha-1	2013-06-01T13:05:46Z
    3.1.0	2013-06-28T02:17:49Z
    3.1.1	2013-09-17T15:24:21Z
    3.2.1	2014-02-14T17:40:18Z
    3.2.2	2014-06-17T13:53:25Z
    3.2.3	2014-08-11T20:59:36Z
    3.2.5	2014-12-14T17:30:51Z
    3.3.1	2015-03-13T20:12:31Z
    3.3.3	2015-04-22T11:59:30Z
    3.3.9	2015-11-10T16:44:21Z
    3.5.0-alpha-1	2017-02-23T15:06:59Z
    3.5.0-beta-1	2017-03-20T17:00:22Z
    3.5.0	2017-04-03T19:41:19Z
    3.5.2	2017-10-18T07:59:58Z
    3.5.3	2018-02-24T19:51:34Z
    3.5.4	2018-06-17T18:35:37Z
    3.6.0	2018-10-24T18:43:51Z
    3.6.1	2019-04-04T19:03:01Z
    3.6.2	2019-08-27T15:10:13Z
    3.6.3	2019-11-19T19:36:44Z
    3.8.1	2021-03-30T17:21:46Z
    3.8.2	2021-08-04T19:07:37Z
    3.8.3	2021-09-27T18:32:54Z
    3.8.4	2021-11-14T09:19:02Z
    3.8.5	2022-03-05T15:41:10Z
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: Valid Package URL from alternative repository
    Some packages are not located in the default repository, such as the `org.springframework.spring-core` package. The
    `repository_url` qualifier is used to specify an alternative location to retrieve release history for these
    packages. If the `repository_url` qualifier omits a URL scheme, then `https` will be used.

    Since the `retrieve-release-history` always outputs the full release history, it's expected that the version
    component will be omitted from the provided package url.

    Note: This scenario included all of the versions for the `spring-core` package at the time that it was authored. It
    is expected that this scenario will still pass when newer versions become available and are added to the end of the
    output.

    When I run `freshli-agent-java start-server 8192` interactively
    Then I wait for the freshli_agent.proto gRPC service to be running on port 8192
    And I call RetrieveReleaseHistory with "pkg:maven/com.cloudera.api.swagger/cloudera-manager-api-swagger?repository_url=repository.cloudera.com%2Fartifactory%2Fcloudera-repos" on port 8192
    Then RetrieveReleaseHistory response should contain the following versions and release dates:
    """
    6.0.0	2018-08-29T19:02:53Z
    6.2.0	2019-03-29T14:58:58Z
    6.x.0	2019-04-24T21:23:18Z
    6.3.0	2019-08-05T14:23:04Z
    7.0.3	2019-12-16T09:51:26Z
    7.1.1	2020-10-05T21:52:04Z
    7.1.2	2020-10-05T21:53:27Z
    7.1.3	2020-10-05T21:54:35Z
    7.1.4	2020-10-12T22:51:30Z
    7.4.1	2021-04-22T09:41:37Z
    7.4.2	2021-07-06T15:24:12Z
    7.3.1	2021-08-03T13:52:21Z
    7.4.4	2021-08-05T11:43:14Z
    7.4.3	2021-09-08T17:52:35Z
    7.5.1	2021-09-29T05:06:28Z
    7.2.6	2021-10-01T10:35:51Z
    7.5.2	2021-10-25T17:43:27Z
    7.5.4	2021-11-08T13:55:33Z
    6.3.4	2022-01-27T15:10:31Z
    6.2.1	2022-01-27T15:51:15Z
    7.6.0	2022-02-25T07:07:54Z
    7.6.1	2022-03-29T13:35:26Z
    7.5.5	2022-04-12T15:40:30Z
    7.6.2	2022-05-12T21:34:11Z
    7.6.5	2022-06-20T11:13:50Z
    7.7.1	2022-08-29T20:39:36Z
    7.8.1	2022-11-17T21:21:40Z
    7.9.0	2023-01-11T11:41:58Z
    7.9.5	2023-01-20T05:31:28Z
    7.6.7	2023-02-01T04:00:20Z
    7.10.1	2023-06-13T10:14:21Z
    7.11.0	2023-06-26T14:39:42Z
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: Valid Package URL from alternative repository that includes url scheme
    Some packages are not located in the default repository, such as the `org.springframework.spring-core` package. The
    `repository_url` qualifier is used to specify an alternative location to retrieve release history for these
    packages. If the `repository_url` qualifier includes a URL scheme, then that scheme will be used.

    Since the `retrieve-release-history` always outputs the full release history, it's expected that the version
    component will be omitted from the provided package url.

    Note: This scenario included all of the versions for the `spring-core` package at the time that it was authored. It
    is expected that this scenario will still pass when newer versions become available and are added to the end of the
    output.

    When I run `freshli-agent-java start-server 8192` interactively
    Then I wait for the freshli_agent.proto gRPC service to be running on port 8192
    And I call RetrieveReleaseHistory with "pkg:maven/com.cloudera.api.swagger/cloudera-manager-api-swagger?repository_url=http%3A%2F%2Frepository.cloudera.com%2Fartifactory%2Fcloudera-repos" on port 8192
    Then RetrieveReleaseHistory response should contain the following versions and release dates:
    """
    6.0.0	2018-08-29T19:02:53Z
    6.2.0	2019-03-29T14:58:58Z
    6.x.0	2019-04-24T21:23:18Z
    6.3.0	2019-08-05T14:23:04Z
    7.0.3	2019-12-16T09:51:26Z
    7.1.1	2020-10-05T21:52:04Z
    7.1.2	2020-10-05T21:53:27Z
    7.1.3	2020-10-05T21:54:35Z
    7.1.4	2020-10-12T22:51:30Z
    7.4.1	2021-04-22T09:41:37Z
    7.4.2	2021-07-06T15:24:12Z
    7.3.1	2021-08-03T13:52:21Z
    7.4.4	2021-08-05T11:43:14Z
    7.4.3	2021-09-08T17:52:35Z
    7.5.1	2021-09-29T05:06:28Z
    7.2.6	2021-10-01T10:35:51Z
    7.5.2	2021-10-25T17:43:27Z
    7.5.4	2021-11-08T13:55:33Z
    6.3.4	2022-01-27T15:10:31Z
    6.2.1	2022-01-27T15:51:15Z
    7.6.0	2022-02-25T07:07:54Z
    7.6.1	2022-03-29T13:35:26Z
    7.5.5	2022-04-12T15:40:30Z
    7.6.2	2022-05-12T21:34:11Z
    7.6.5	2022-06-20T11:13:50Z
    7.7.1	2022-08-29T20:39:36Z
    7.8.1	2022-11-17T21:21:40Z
    7.9.0	2023-01-11T11:41:58Z
    7.9.5	2023-01-20T05:31:28Z
    7.6.7	2023-02-01T04:00:20Z
    7.10.1	2023-06-13T10:14:21Z
    7.11.0	2023-06-26T14:39:42Z
    """
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: Valid Package URL for an unknown package
    If the command is unable to find any release history for the specified package, then it should output a friendly
    error message and use the program's status code to indicate that there's been a failure.

    When I run `freshli-agent-java start-server 8192` interactively
    Then I wait for the freshli_agent.proto gRPC service to be running on port 8192
    And I call RetrieveReleaseHistory with "pkg:maven/com.corgibytes/missing" on port 8192
    Then RetrieveReleaseHistory response should be empty
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0

  Scenario: Invalid Package URL
    If the command is unable parse the package url, then it should output a friendly error message and use the
    program's status code to indicate that there's been a failure.

    When I run `freshli-agent-java start-server 8192` interactively
    Then I wait for the freshli_agent.proto gRPC service to be running on port 8192
    And I call RetrieveReleaseHistory with "invalid" on port 8192
    Then RetrieveReleaseHistory response should be empty
    When the gRPC service on port 8192 is sent the shutdown command
    Then there are no services running on port 8192
    And the exit status should be 0
