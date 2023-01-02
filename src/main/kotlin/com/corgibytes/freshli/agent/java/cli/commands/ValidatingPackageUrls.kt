package com.corgibytes.freshli.agent.java.cli.commands

import com.github.ajalt.clikt.core.CliktCommand

class ValidatingPackageUrls: CliktCommand(help="Lists package urls that can be used to validate this agent") {
    override fun run() {
        println("pkg:maven/org.apache.maven/apache-maven")
        println("pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease")
        println("pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease")
    }
}
