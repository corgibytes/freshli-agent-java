package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.AgentServer
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.ajalt.clikt.parameters.types.int
import java.io.IOException
import kotlin.random.Random
import kotlin.system.exitProcess

class StartServer: CliktCommand(help="Starts a gRPC server running the Freshli Agent service") {
    private val port: Int? by argument(help="port number to run server on").int()

    override fun run() {
        var effectivePort: Int = port ?: Random.nextInt(1, 65535)

        if (port != null) {
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
}