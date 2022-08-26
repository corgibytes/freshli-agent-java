package com.corgibytes.freshli.agent.java

import com.corgibytes.maven.ReleaseHistoryService
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.packageurl.MalformedPackageURLException
import com.github.packageurl.PackageURL
import org.apache.maven.model.io.xpp3.MavenXpp3Reader
import java.io.File
import java.io.FileInputStream
import java.time.format.DateTimeFormatter
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
    override fun run() {
        println("https://github.com/corgibytes/freshli-fixture-java-maven-version-range")
        println("https://github.com/questdb/questdb")
        println("https://github.com/protocolbuffers/protobuf")
        println("https://github.com/serverless/serverless")
    }
}

class DetectManifests: CliktCommand(help="Detects manifest files in the specified directory") {
    private val path by argument()

    override fun run() {
        // start by finding all of the pom.xml files and storing them in a results list
        val submodules = mutableListOf<String>()
        val directory = File(path)
        val results = directory.walkTopDown().filter { it.name == "pom.xml" }.map { it.path }.toMutableList()

        val mavenReader = MavenXpp3Reader()
        // for each pom.xml file in the list
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

class ProcessManifests: CliktCommand(help="Processes manifest files in the specified directory") {
    override fun run() = Unit
}

fun main(args: Array<String>) = FreshliAgentJava()
    .subcommands(ValidatingPackageUrls(), RetrieveReleaseHistory(), ValidatingRepositories(), DetectManifests(), ProcessManifests())
    .main(args)
