package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.AgentServer
import com.github.ajalt.clikt.core.CliktCommand
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
    private val port: Int? by option(help="port number to run server on").int()

    override fun run() {
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
        } else {
            var serverStarted = false
            var randomPort: Int = nextRandomPort()
            while (randomPort != -1) {
                if (previousPorts.count() > maxRetries) {
                    println("Unable to start service. Gave up after trying $maxRetries times to find an open port within the range ${portRange.first}:${portRange.last}.")
                    exitProcess(-1)
                }

                val tempDir = ensureTempDirExists()

                val stdoutPath = Paths.get(tempDir.toString(), "${randomPort}_stdout.log")
                val stderrPath = Paths.get(tempDir.toString(), "${randomPort}_stderr.log")

                val process = spawnService(randomPort, stderrPath, stdoutPath)

                if (isListeningMessagePresent(process, stdoutPath)) {
                    serverStarted = true
                    break
                } else if (process.isAlive) {
                    process.destroy()
                }

                randomPort = nextRandomPort()
            }

            if (serverStarted) {
                println("$randomPort")
            } else {
                println("Unable to start service. All ports with range ${portRange.first}:${portRange.last} are in use.")
                exitProcess(-1)
            }
        }
    }

    private val maxRetries = 100

    private fun spawnService(
        randomPort: Int,
        stderrPath: Path,
        stdoutPath: Path
    ): Process {
        val systemInfo = SystemInfo()
        val currentProcess = systemInfo.operatingSystem.currentProcess

        val javaExecutable: String = currentProcess.path

        val command: MutableList<String> = mutableListOf(javaExecutable)
        command.addAll(currentProcess.arguments.drop(1))
        command.add("--port")
        command.add("$randomPort")

        val builder = ProcessBuilder(command)

        builder.redirectError(stderrPath.toFile())
        builder.redirectOutput(stdoutPath.toFile())

        return builder.start()
    }

    private fun ensureTempDirExists(): Path {
        val tempDir = Paths.get(System.getProperty("java.io.tmpdir"), "freshli")
        if (!tempDir.exists()) {
            tempDir.createDirectory()
        }
        return tempDir
    }

    private val portNumberMin = 1
    private val portNumberMax = 65535
    private val rangeEnvironmentVar = "FRESHLI_AGENT_SERVER_PORT_RANGE"
    private val rangeSeparator = ':'
    private var _portRange: IntRange? = null
    private val portRange: IntRange
        get() {
            if (_portRange == null) {
                var portRangeStart = portNumberMin
                var portRangeEnd = portNumberMax
                val rawRangeViaEnvironment = System.getenv(rangeEnvironmentVar)
                if (rawRangeViaEnvironment != null) {
                    val splits = rawRangeViaEnvironment.split(rangeSeparator)
                    if (splits.count() == 2) {
                        portRangeStart = splits[0].toInt()
                        portRangeEnd = splits[1].toInt()
                    }
                }
                _portRange = portRangeStart..portRangeEnd
            }
            return _portRange!!
        }

    private val previousPorts = mutableListOf<Int>()

    private fun nextRandomPort(): Int {
        if (previousPorts.count() < portRange.count()) {
            var port = Random.nextInt(portRange.first, portRange.last)
            while (previousPorts.contains(port)) {
                 port = Random.nextInt(portRange.first, portRange.last + 1)
            }
            previousPorts.add(port)
            return port
        }
        return -1
    }

    private val serverListeningTimeout = 1000L
    private val loopDelay = 10L
    fun isListeningMessagePresent(process: Process, stdoutPath: Path): Boolean {
        var result = false
        runBlocking {
            withTimeoutOrNull(serverListeningTimeout) {
                while (!result) {
                    if (!process.isAlive) {
                        break
                    }

                    val file = stdoutPath.toFile()
                    if (file.exists()) {
                        val stream = stdoutPath.toFile().inputStream()
                        val outputLines = stream.reader().readLines()
                        stream.close()

                        if (outputLines.firstOrNull { it.matches(Regex("Listening on \\d+\\.\\.\\.")) } != null) {
                            result = true
                            break
                        }
                    }

                    delay(loopDelay)
                }
            }
        }

        return result
    }
}