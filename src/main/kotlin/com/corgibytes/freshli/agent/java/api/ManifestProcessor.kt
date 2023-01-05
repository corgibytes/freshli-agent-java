package com.corgibytes.freshli.agent.java.api

import com.corgibytes.freshli.agent.java.SystemUtils
import com.github.pgreze.process.Redirect
import kotlinx.coroutines.runBlocking
import java.io.File
import java.nio.file.Path
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlin.io.path.exists

class ManifestProcessor {
    fun process(manifestLocation: String, asOfDate: ZonedDateTime): String {
        val manifestFile = File(SystemUtils.normalizeFileSeparators(manifestLocation))

        if (!manifestFile.exists()) {
            throw ManifestProcessingFailure("Unable to access $manifestLocation")
        }

        val manifestDirectory = manifestFile.toPath().parent

        runBlocking {
            resolveVersionRanges(manifestDirectory, asOfDate)
            generateBillOfMaterials(manifestDirectory)
        }
        restoreManifestFromBackup(manifestDirectory, manifestFile)

        val bomFile = manifestDirectory.resolve("target").resolve("bom.json")
        if (!bomFile.exists()) {
            throw ManifestProcessingFailure("Failed to process manifest: $manifestLocation")
        }

        return bomFile.toFile().path
    }

    private fun restoreManifestFromBackup(manifestDirectory: Path, manifestFile: File) {
        val backupManifestFile = manifestDirectory.resolve("pom.xml.versionsBackup")
        if (backupManifestFile.exists()) {
            manifestFile.delete()
            backupManifestFile.toFile().renameTo(manifestFile)
        }
    }

    private suspend fun generateBillOfMaterials(manifestDirectory: Path) {
        val result = com.github.pgreze.process.process(
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
            val messageBuilder = StringBuilder()
            messageBuilder.appendLine("Failed to generate bill of materials. See command output for more information:")
            messageBuilder.append(result.output.joinToString(System.lineSeparator()))
            throw ManifestProcessingFailure(messageBuilder.toString())
        }
    }

    private suspend fun resolveVersionRanges(manifestDirectory: Path, asOfDate: ZonedDateTime) {
        val result = com.github.pgreze.process.process(
            SystemUtils.mavenCommand,
            "com.corgibytes:versions-maven-plugin:resolve-ranges-historical",
            "-DversionsAsOf=${asOfDate.format(DateTimeFormatter.ISO_ZONED_DATE_TIME)}",

            stdout = Redirect.CAPTURE,
            stderr = Redirect.CAPTURE,

            directory = manifestDirectory.toFile()
        )

        if (result.resultCode != 0) {
            val messageBuilder = StringBuilder()
            messageBuilder.appendLine("Failed to resolve version ranges. See command output for more information:")
            messageBuilder.append(result.output.joinToString(System.lineSeparator()))
            throw ManifestProcessingFailure(messageBuilder.toString())
        }
    }
}
