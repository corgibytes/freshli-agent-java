package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.api.ValidationData
import com.github.ajalt.clikt.core.CliktCommand

class ValidatingPackageUrls: CliktCommand(help="Lists package urls that can be used to validate this agent") {
    override fun run() {
        ValidationData().packageUrls().forEach {
            println(it)
        }
    }
}
