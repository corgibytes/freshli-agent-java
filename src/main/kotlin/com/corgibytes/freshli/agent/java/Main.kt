package com.corgibytes.freshli.agent.java

import com.corgibytes.freshli.agent.java.cli.FreshliAgentJava
import com.corgibytes.freshli.agent.java.cli.commands.*
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

fun main(args: Array<String>) = FreshliAgentJava()
    .subcommands(
        StartServer()
    )
    .main(args)
