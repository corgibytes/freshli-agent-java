package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.api.ValidationData
import com.github.ajalt.clikt.core.CliktCommand

class ValidatingRepositories: CliktCommand(help="Lists repositories that can be used to validate this agent") {
    override fun run() {
        ValidationData().repositories().forEach {
            println(it)
        }
    }
}
