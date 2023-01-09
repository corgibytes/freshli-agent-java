package com.corgibytes.freshli.agent.java

import com.corgibytes.freshli.agent.AgentGrpcKt
import com.corgibytes.freshli.agent.FreshliAgent
import com.corgibytes.freshli.agent.java.api.*
import com.google.protobuf.Empty
import com.google.protobuf.Timestamp
import io.grpc.Server
import io.grpc.ServerBuilder
import io.grpc.health.v1.HealthCheckResponse
import io.grpc.protobuf.services.HealthStatusManager
import io.grpc.protobuf.services.ProtoReflectionService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.concurrent.TimeUnit

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
        server.shutdownNow()
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

        override fun getValidatingRepositories(request: Empty): Flow<FreshliAgent.RepositoryLocation> {
            return ValidationData()
                .repositories()
                .map { FreshliAgent.RepositoryLocation.newBuilder().setUrl(it).build() }
                .asFlow()
        }

        private fun ZonedDateTime.toTimestamp(): Timestamp {
            val instant = this.toInstant()
            return Timestamp.newBuilder().setSeconds(instant.epochSecond).setNanos(instant.nano).build()
        }

        override suspend fun processManifest(request: FreshliAgent.ProcessingRequest): FreshliAgent.BomLocation {
            val epochStart = ZonedDateTime.of(1970, 1, 1, 0, 0, 0, 0, ZoneId.of("Z"))
            var moment = epochStart.plusSeconds(request.moment.seconds)
            moment = moment.plusNanos(request.moment.nanos.toLong())
            val bomFilePath = ManifestProcessor().process(request.manifest.path, moment)
            return FreshliAgent.BomLocation.newBuilder().setPath(bomFilePath).build()
        }

        override fun retrieveReleaseHistory(request: FreshliAgent.Package): Flow<FreshliAgent.PackageRelease> {
            return try {
                ReleaseHistoryRetriever()
                    .retrieve(request.purl)
                    .map {
                        FreshliAgent.PackageRelease.newBuilder()
                            .setVersion(it.version)
                            .setReleasedAt(it.releasedAt.toTimestamp())
                            .build()
                    }
                    .asFlow()
            } catch (failure: ReleaseHistoryRetrievingFailure) {
                emptyList<FreshliAgent.PackageRelease>().asFlow()
            }
        }

        override suspend fun shutdown(request: Empty): Empty {
            parent.stop()
            return Empty.getDefaultInstance()
        }
    }
}
