package com.corgibytes.freshli.agent.java

import com.corgibytes.maven.ReleaseHistoryService
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.packageurl.PackageURL
import java.time.format.DateTimeFormatter

class FreshliAgentJava: CliktCommand() {
    override fun run() = Unit
}

class RetrieveReleaseHistory: CliktCommand(help="Retrieves release history for a specific package") {
    val packageURL by argument()
    override fun run() {
        val purl = PackageURL(packageURL)

        val service = ReleaseHistoryService("https://" + purl.qualifiers["repository_url"]!!)

        val actualResults = service.getVersionHistory(purl.namespace, purl.name)

        actualResults.asSequence().sortedBy { it.value.toString() + it.key }.forEach {
            println(it.key + "\t" + it.value.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME))
        }
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
    .subcommands(RetrieveReleaseHistory(), ValidatingRepositories(), DetectManifests(), ProcessManifests())
    .main(args)
