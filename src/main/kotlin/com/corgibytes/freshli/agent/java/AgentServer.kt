package com.corgibytes.freshli.agent.java

import com.corgibytes.freshli.agent.AgentGrpcKt
import com.google.protobuf.Empty
import io.grpc.Server
import io.grpc.ServerBuilder
import io.grpc.health.v1.HealthCheckResponse
import io.grpc.protobuf.services.HealthStatusManager
import io.grpc.protobuf.services.ProtoReflectionService

class AgentServer(val port: Int) {
    var healthStatusManager = HealthStatusManager()
    val server: Server = ServerBuilder
        .forPort(port)
        .addService(AgentService(this))
        .addService(ProtoReflectionService.newInstance())
        .addService(healthStatusManager.healthService)
        .build()

    fun start() {
        server.start()
        healthStatusManager.setStatus(AgentGrpcKt.SERVICE_NAME, HealthCheckResponse.ServingStatus.SERVING)
    }

    fun stop() {
        server.shutdown()
    }

    fun blockUntilShutdown() {
        server.awaitTermination()
    }

    fun isServiceRunning(name: String): Boolean {
        if (name.isNullOrEmpty()) {
            return true
        }

        return server.immutableServices.firstOrNull { it.serviceDescriptor.name == name } != null
    }

    internal class AgentService(private val parent: AgentServer) : AgentGrpcKt.AgentCoroutineImplBase() {

        override suspend fun shutdown(request: Empty): Empty {
            parent.stop()
            return Empty.getDefaultInstance()
        }
    }
}
