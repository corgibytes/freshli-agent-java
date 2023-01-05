package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.api.ManifestProcessingFailure
import com.corgibytes.freshli.agent.java.api.ManifestProcessor
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.ProgramResult
import com.github.ajalt.clikt.parameters.arguments.argument
import java.time.ZonedDateTime

class ProcessManifest: CliktCommand(help="Processes manifest files in the specified directory") {
    private val manifestLocation by argument(name="MANIFEST_FILE")
    private val asOfDate by argument(name="AS_OF_DATE")

    override fun run() {
        try {
            val bomFilePath = ManifestProcessor().process(manifestLocation, ZonedDateTime.parse(asOfDate))
            println(bomFilePath)
        } catch (failure: ManifestProcessingFailure) {
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
