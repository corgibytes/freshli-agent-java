package com.corgibytes.freshli.agent.java.api

class ValidationData {
    fun packageUrls(): List<String> {
        return listOf(
            "pkg:maven/org.apache.maven/apache-maven",
            "pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease",
            "pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease"
        )
    }

    fun repositories(): List<String> {
        return listOf(
            "https://github.com/corgibytes/freshli-fixture-java-maven-version-range",
            "https://github.com/questdb/questdb",
            "https://github.com/protocolbuffers/protobuf",
            "https://github.com/serverless/serverless"
        )
    }
}