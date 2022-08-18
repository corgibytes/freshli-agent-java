package com.corgibytes.freshli.agent.java

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands

class FreshliAgentJava: CliktCommand() {
    override fun run() = Unit
}

class ValidatingPackageUrls: CliktCommand(help="Lists package urls that can be used to validate this agent") {
    override fun run() {
        println("pkg:maven/org.apache.maven/apache-maven")
        println("pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease")
        println("pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease")
    }
}

class ValidatingRepositories: CliktCommand(help="Lists repositories that can be used to validate this agent") {
    override fun run() = Unit
}

class DetectManifests: CliktCommand(help="Detects manifest files in the specified directory") {
    override fun run() = Unit
}

class ProcessManifests: CliktCommand(help="Processes manifest files in the specified directory") {
    override fun run() = Unit
}

fun main(args: Array<String>) = FreshliAgentJava()
    .subcommands(ValidatingPackageUrls(), ValidatingRepositories(), DetectManifests(), ProcessManifests())
    .main(args)
