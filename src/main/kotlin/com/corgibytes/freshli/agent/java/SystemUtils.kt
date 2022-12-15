package com.corgibytes.freshli.agent.java

import java.io.File

class SystemUtils {
    companion object {
        val mavenCommand: String
            get() {
                val osName = System.getProperty("os.name").lowercase()
                if (osName.contains("win")) {
                    return "mvn.cmd"
                }
                return "mvn"
            }

        fun normalizeFileSeparators(value: String): String {
            return value.replace("/", File.separator)
        }
    }
}