package com.corgibytes.freshli.agent.java.api

import com.corgibytes.freshli.agent.java.SystemUtils
import org.apache.maven.model.io.xpp3.MavenXpp3Reader
import java.io.File
import java.io.FileInputStream

class ManifestDetector() {
    fun detect(path: String): List<String> {
        val normalizedPath = SystemUtils.normalizeFileSeparators(path)
        val submodules = mutableListOf<String>()
        val directory = File(normalizedPath)
        val results = directory.walkTopDown().filter { it.name == "pom.xml" }.map { it.path }.toMutableList()

        val mavenReader = MavenXpp3Reader()
        results.forEach {modelFileName: String ->
            val model = mavenReader.read(FileInputStream(modelFileName))
            model.modules.forEach {moduleName: String ->
                submodules.add(File(modelFileName).toPath().resolveSibling(moduleName).resolve("pom.xml").toString())
            }
        }

        results.removeIf { submodules.contains(it) }
        return results
    }
}