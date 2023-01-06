package com.corgibytes.freshli.agent.java.api

import com.corgibytes.maven.ReleaseHistoryService
import com.github.packageurl.MalformedPackageURLException
import com.github.packageurl.PackageURL
import java.time.format.DateTimeFormatter

class ReleaseHistoryRetriever {
    fun retrieve(packageURL: String): List<PackageReleaseData> {
        val purl: PackageURL
        try {
            purl = PackageURL(packageURL)
        } catch (error: MalformedPackageURLException) {
            throw ReleaseHistoryRetrievingFailure("Unable to parse the Package URL: $packageURL.", error)
        }

        val service: ReleaseHistoryService = if (purl.qualifiers != null && purl.qualifiers.containsKey("repository_url")) {
            var repositoryUrl = purl.qualifiers["repository_url"]!!
            if (!repositoryUrl.contains("://")) {
                repositoryUrl = "https://$repositoryUrl"
            }
            ReleaseHistoryService(repositoryUrl)
        } else {
            ReleaseHistoryService()
        }

        val actualResults = service.getVersionHistory(purl.namespace, purl.name)

        return if (actualResults.isEmpty()) {
            emptyList()
        } else {
            actualResults
                .asSequence()
                .sortedBy { it.value.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME) + it.key }
                .map { PackageReleaseData(it.key, it.value) }
                .toList()
        }
    }
}