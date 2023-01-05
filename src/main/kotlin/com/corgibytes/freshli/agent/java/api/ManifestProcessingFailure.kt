package com.corgibytes.freshli.agent.java.api

class ManifestProcessingFailure(message: String?, cause: Throwable?) : Exception(message, cause) {
    constructor(message: String?): this(message, null) {
    }
}
