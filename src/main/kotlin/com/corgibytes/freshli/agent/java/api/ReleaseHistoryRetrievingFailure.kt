package com.corgibytes.freshli.agent.java.api

class ReleaseHistoryRetrievingFailure(message: String?, cause: Throwable?) : Exception(message, cause) {
    constructor(message: String?): this(message, null) {
    }
}