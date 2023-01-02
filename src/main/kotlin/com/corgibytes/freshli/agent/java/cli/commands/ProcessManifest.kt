package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.SystemUtils
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.ProgramResult
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.pgreze.process.Redirect
import com.github.pgreze.process.process
import kotlinx.coroutines.runBlocking
import java.io.File
import java.nio.file.Path
import kotlin.io.path.exists

class ProcessManifest: CliktCommand(help="Processes manifest files in the specified directory") {
    private val manifestLocation by argument(name="MANIFEST_FILE")
    private val asOfDate by argument(name="AS_OF_DATE")

    override fun run() {
        val manifestFile = File(SystemUtils.normalizeFileSeparators(manifestLocation))

        if (!manifestFile.exists()) {
            println("Unable to access $manifestLocation")
            throw ProgramResult(-1)
        }

        val manifestDirectory = manifestFile.toPath().parent

        runBlocking {
            resolveVersionRanges(manifestDirectory)
            generateBillOfMaterials(manifestDirectory)
        }
        restoreManifestFromBackup(manifestDirectory, manifestFile)

        val bomFile = manifestDirectory.resolve("target").resolve("bom.json")
        if (bomFile.exists()) {
            println(bomFile.toFile().path)
        } else {
            println("Failed to process manifest: $manifestLocation")
            throw ProgramResult(-1)
        }
    }

    private fun restoreManifestFromBackup(manifestDirectory: Path, manifestFile: File) {
        val backupManifestFile = manifestDirectory.resolve("pom.xml.versionsBackup")
        if (backupManifestFile.exists()) {
            manifestFile.delete()
            backupManifestFile.toFile().renameTo(manifestFile)
        }
    }

    private suspend fun generateBillOfMaterials(manifestDirectory: Path) {
        val result = process(
            SystemUtils.mavenCommand,
            "org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom",
            "-DincludeLicenseText=true",
            "-DincludeTestScope=true",
            "-DoutputFormat=json",

            stdout = Redirect.CAPTURE,
            stderr = Redirect.CAPTURE,

            directory = manifestDirectory.toFile()
        )

        if (result.resultCode != 0) {
            println("Failed to resolve version ranges. See command output for more information:")
            println(result.output.joinToString("\n"))
            throw ProgramResult(-1)
        }
    }

    private suspend fun resolveVersionRanges(manifestDirectory: Path) {
        val result = process(
            SystemUtils.mavenCommand,
            "com.corgibytes:versions-maven-plugin:resolve-ranges-historical",
            "-DversionsAsOf=$asOfDate",

            stdout = Redirect.CAPTURE,
            stderr = Redirect.CAPTURE,

            directory = manifestDirectory.toFile()
        )

        if (result.resultCode != 0) {
            println("Failed to resolve version ranges. See command output for more information:")
            println(result.output.joinToString("\n"))
            throw ProgramResult(-1)
        }
    }
}
