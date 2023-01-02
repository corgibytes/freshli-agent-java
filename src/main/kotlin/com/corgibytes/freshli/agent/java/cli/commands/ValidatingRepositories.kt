package com.corgibytes.freshli.agent.java.cli.commands

import com.github.ajalt.clikt.core.CliktCommand

class ValidatingRepositories: CliktCommand(help="Lists repositories that can be used to validate this agent") {
    override fun run() {
        println("https://github.com/corgibytes/freshli-fixture-java-maven-version-range")
        println("https://github.com/questdb/questdb")
        println("https://github.com/protocolbuffers/protobuf")
        println("https://github.com/serverless/serverless")
    }
}
