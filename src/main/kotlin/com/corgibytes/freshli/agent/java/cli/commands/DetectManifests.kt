package com.corgibytes.freshli.agent.java.cli.commands

import com.corgibytes.freshli.agent.java.SystemUtils
import com.corgibytes.freshli.agent.java.api.ManifestDetector
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.arguments.argument
import java.io.File

class DetectManifests: CliktCommand(help="Detects manifest files in the specified directory") {
    private val path by argument()

    override fun run() {
        val normalizedPath = SystemUtils.normalizeFileSeparators(path)
        val results = ManifestDetector().detect(path)
        results.map{ it.removePrefix("$normalizedPath" + File.separator) }.sorted().forEach {
            println(it)
        }
    }
}
