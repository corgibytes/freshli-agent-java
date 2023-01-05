package com.corgibytes.freshli.agent.java

import com.corgibytes.freshli.agent.AgentGrpcKt
import com.corgibytes.freshli.agent.FreshliAgent
import com.corgibytes.freshli.agent.java.api.ManifestDetector
import com.corgibytes.freshli.agent.java.api.ValidationData
import com.google.protobuf.Empty
import io.grpc.Server
import io.grpc.ServerBuilder
import io.grpc.health.v1.HealthCheckResponse
import io.grpc.protobuf.services.HealthStatusManager
import io.grpc.protobuf.services.ProtoReflectionService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow

class AgentServer(val port: Int) {
    private val healthStatusManager = HealthStatusManager()
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

    internal class AgentService(private val parent: AgentServer) : AgentGrpcKt.AgentCoroutineImplBase() {

        override fun detectManifests(request: FreshliAgent.ProjectLocation): Flow<FreshliAgent.ManifestLocation> {
            return ManifestDetector()
                .detect(request.path)
                .map { FreshliAgent.ManifestLocation.newBuilder().setPath(it).build() }
                .asFlow()
        }

        override fun getValidatingPackages(request: Empty): Flow<FreshliAgent.Package> {
            return ValidationData()
                .packageUrls()
                .map { FreshliAgent.Package.newBuilder().setPurl(it).build() }
                .asFlow()
        }

        override suspend fun shutdown(request: Empty): Empty {
            parent.stop()
            return Empty.getDefaultInstance()
        }
    }
}
