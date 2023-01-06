package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.api.ReleaseHistoryRetriever
import com.corgibytes.freshli.agent.java.api.ReleaseHistoryRetrievingFailure
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.ProgramResult
import com.github.ajalt.clikt.parameters.arguments.argument
import java.time.format.DateTimeFormatter

class RetrieveReleaseHistory: CliktCommand(help="Retrieves release history for a specific package") {
    private val packageURL by argument()
    override fun run() {
        try {
            val releases = ReleaseHistoryRetriever().retrieve(packageURL)

            if (releases.isEmpty()) {
                println("Unable to find release history for $packageURL.")
                throw ProgramResult(-1)
            }

            releases.forEach {
                println(it.version + "\t" + it.releasedAt.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME))
            }
        } catch (failure: ReleaseHistoryRetrievingFailure) {
            println(failure.message)
            failure.printStackTrace()
            if (failure.cause != null) {
                println("Caused by:")
                failure.cause!!.printStackTrace()
            }
            throw ProgramResult(-1)
        }
    }
}
