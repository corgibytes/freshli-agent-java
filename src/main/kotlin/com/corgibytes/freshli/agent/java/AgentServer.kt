package com.corgibytes.freshli.agent.java

import io.grpc.Server
import io.grpc.ServerBuilder
import com.corgibytes.freshli.agent.AgentGrpcKt
import com.google.protobuf.Empty
import grpc.health.v1.HealthGrpcKt
import grpc.health.v1.HealthOuterClass

class AgentServer(val port: Int) {
    val server: Server = ServerBuilder
        .forPort(port)
        .addService(AgentService(this))
        .addService(HealthService(this))
        .build()

    fun start() {
        server.start()
    }

    fun stop() {
        server.shutdown()
    }

    fun blockUntilShutdown() {
        server.awaitTermination()
    }

    fun isServiceRunning(name: String): Boolean {
        return server.immutableServices.firstOrNull { it.serviceDescriptor.name == name } == null
    }

    internal class AgentService(private val parent: AgentServer) : AgentGrpcKt.AgentCoroutineImplBase() {
        override suspend fun shutdown(request: Empty): Empty {
            parent.stop()
            return Empty.getDefaultInstance()
        }
    }

    internal class HealthService(private val parent: AgentServer) : HealthGrpcKt.HealthCoroutineImplBase() {
        override suspend fun check(request: HealthOuterClass.HealthCheckRequest): HealthOuterClass.HealthCheckResponse {
            return if (parent.isServiceRunning(request.service)) {
                healthCheckResponse(HealthOuterClass.HealthCheckResponse.ServingStatus.SERVING)
            } else {
                healthCheckResponse(HealthOuterClass.HealthCheckResponse.ServingStatus.UNKNOWN)
            }
        }

        private fun healthCheckResponse(servingStatus: HealthOuterClass.HealthCheckResponse.ServingStatus): HealthOuterClass.HealthCheckResponse =
            HealthOuterClass.HealthCheckResponse.newBuilder().setStatus(servingStatus).build()
    }
}
