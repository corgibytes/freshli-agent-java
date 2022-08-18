package com.corgibytes.freshli.agent.java

import com.corgibytes.maven.ReleaseHistoryService
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.packageurl.MalformedPackageURLException
import com.github.packageurl.PackageURL
import java.time.format.DateTimeFormatter
import kotlin.system.exitProcess

class FreshliAgentJava: CliktCommand() {
    override fun run() = Unit
}

class RetrieveReleaseHistory: CliktCommand(help="Retrieves release history for a specific package") {
    private val packageURL by argument()
    override fun run() {
        val purl: PackageURL
        try {
            purl = PackageURL(packageURL)
        } catch (error: MalformedPackageURLException) {
            println("Unable to parse the Package URL: $packageURL.")
            exitProcess(-1)
        }

        val service: ReleaseHistoryService = if (purl.qualifiers != null && purl.qualifiers.containsKey("repository_url")) {
            var repositoryUrl = purl.qualifiers["repository_url"]!!
            if (!repositoryUrl.contains("://")) {
                repositoryUrl = "https://$repositoryUrl"
            }
            ReleaseHistoryService(repositoryUrl)
        } else {
            ReleaseHistoryService()
        }

        val actualResults = service.getVersionHistory(purl.namespace, purl.name)

        if (actualResults.isEmpty()) {
            println("Unable to find release history for $packageURL.")
            exitProcess(-1)
        }
        else {
            actualResults.asSequence().sortedBy { it.value.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME) + it.key }
                .forEach {
                    println(it.key + "\t" + it.value.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME))
                }
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
