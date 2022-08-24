package com.corgibytes.freshli.agent.java

import com.corgibytes.maven.ReleaseHistoryService
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.ProgramResult
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.packageurl.MalformedPackageURLException
import com.github.packageurl.PackageURL
import com.github.pgreze.process.Redirect
import com.github.pgreze.process.process
import kotlinx.coroutines.runBlocking
import org.apache.maven.model.io.xpp3.MavenXpp3Reader
import java.io.File
import java.io.FileInputStream
import java.nio.file.Path
import java.time.format.DateTimeFormatter
import kotlin.io.path.exists
import kotlin.system.exitProcess


class FreshliAgentJava: CliktCommand() {
    override fun run() = Unit
}

class ValidatingPackageUrls: CliktCommand(help="Lists package urls that can be used to validate this agent") {
    override fun run() {
        println("pkg:maven/org.apache.maven/apache-maven")
        println("pkg:maven/org.springframework/spring-core?repository_url=repo.spring.io%2Frelease")
        println("pkg:maven/org.springframework/spring-core?repository_url=http%3A%2F%2Frepo.spring.io%2Frelease")
    }
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
    private val path by argument()

    override fun run() {
        val submodules = mutableListOf<String>()
        val directory = File(path)
        val results = directory.walkTopDown().filter { it.name == "pom.xml" }.map { it.path }.toMutableList()

        val mavenReader = MavenXpp3Reader()
        results.forEach {modelFileName: String ->
            val model = mavenReader.read(FileInputStream(modelFileName))
            model.modules.forEach {moduleName: String ->
                submodules.add(File(modelFileName).toPath().resolveSibling(moduleName).resolve("pom.xml").toString())
            }
        }

        results.removeIf { submodules.contains(it) }

        results.map{ it.removePrefix("$path/") }.sorted().forEach {
            println(it)
        }
    }
}

class ProcessManifest: CliktCommand(help="Processes manifest files in the specified directory") {
    private val manifestLocation by argument(name="MANIFEST_FILE")
    private val asOfDate by argument(name="AS_OF_DATE")

    override fun run() {
        val manifestFile = File(manifestLocation)

        if (!manifestFile.exists()) {
            println("Unable to access $manifestLocation")
            throw ProgramResult(-1)
        }

        val manifestDirectory = manifestFile.toPath().parent

        resolveVersionRanges(manifestDirectory)
        generateBillOfMaterials(manifestDirectory)
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

    private fun generateBillOfMaterials(manifestDirectory: Path) {
        // mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom -DincludeLicenseText=true -DincludeTestScope=true -DoutputFormat=json
        var failureDetected = false
        runBlocking {
            val result = process(
                "mvn",
                "org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom",
                "-DincludeLicenseText=true",
                "-DincludeTestScope=true",
                "-DoutputFormat=json",

                stdout = Redirect.CAPTURE,
                stderr = Redirect.CAPTURE,

                directory = manifestDirectory.toFile()
            )

            if (result.resultCode != 0) {
                println("Failed to resolve version ranges:")
                result.output.forEach { println(it) }
                failureDetected = true
            }
        }

        if (failureDetected) {
            throw ProgramResult(-1)
        }
    }

    private fun resolveVersionRanges(manifestDirectory: Path) {
        var failureDetected = false
        // mvn com.corgibytes:versions-maven-plugin:resolve-ranges-historical -DversionsAsOf="2021-01-01T00:00:00Z"
        runBlocking {
            val result = process(
                "mvn",
                "com.corgibytes:versions-maven-plugin:resolve-ranges-historical",
                "-DversionsAsOf=$asOfDate",

                stdout = Redirect.CAPTURE,
                stderr = Redirect.CAPTURE,

                directory = manifestDirectory.toFile()
            )

            if (result.resultCode != 0) {
                println("Failed to resolve version ranges:")
                result.output.forEach { println(it) }
                failureDetected = true
            }
        }

        if (failureDetected) {
            throw ProgramResult(-1)
        }
    }
}

fun main(args: Array<String>) = FreshliAgentJava()
    .subcommands(ValidatingPackageUrls(), RetrieveReleaseHistory(), ValidatingRepositories(), DetectManifests(), ProcessManifest())
    .main(args)
