package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.AgentServer
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.ProgramResult
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.types.int
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeoutOrNull
import oshi.SystemInfo
import java.io.IOException
import java.nio.file.Path
import java.nio.file.Paths
import kotlin.io.path.createDirectory
import kotlin.io.path.exists
import kotlin.random.Random
import kotlin.system.exitProcess

class StartServer: CliktCommand(help="Starts a gRPC server running the Freshli Agent service") {
    private val port: Int? by argument(help="port number to run server on").int()

    override fun run() {
        val server = AgentServer(port!!)

        try {
            server.start()
        } catch (e: IOException) {
            println("Unable to start the gRPC service. Port $port is in use.")
            exitProcess(-1)
        }
        println("Listening on $port...")
        server.blockUntilShutdown()
    }
}
