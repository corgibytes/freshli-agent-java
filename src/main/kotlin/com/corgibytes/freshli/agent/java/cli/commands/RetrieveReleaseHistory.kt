package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.maven.ReleaseHistoryService
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.packageurl.MalformedPackageURLException
import com.github.packageurl.PackageURL
import java.time.format.DateTimeFormatter
import kotlin.system.exitProcess

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
