import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.apache.tools.ant.taskdefs.condition.Os

group = "com.corgibytes"

buildscript {
    repositories {
        mavenLocal() // for local testing of shipkit
        gradlePluginPortal()
        mavenCentral()
    }
    dependencies {
        classpath("org.shipkit:shipkit-auto-version:1.+")
        classpath("org.shipkit:shipkit-changelog:1.+")
    }
}

repositories {
    mavenLocal()
    mavenCentral()
}

extensions.findByName("buildScan")?.withGroovyBuilder {
    setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
    setProperty("termsOfServiceAgree", "yes")
}

apply("gradle/release.gradle")
apply("gradle/ide.gradle")

plugins {
    kotlin("jvm") version "1.7.22"
    id("org.beryx.runtime") version "1.12.7"
    application
}

dependencies {
    implementation("com.github.ajalt.clikt:clikt:3.5.0")
    implementation("com.corgibytes:dependency-history-maven:2.0.17")
    implementation("com.github.package-url:packageurl-java:1.4.1")
    implementation("org.apache.maven:maven-model:3.8.6")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("com.github.pgreze:kotlin-process:1.4")

    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "17"
}

application {
    mainClass.set("com.corgibytes.freshli.agent.java.MainKt")
}

runtime {
    options.set(listOf("--strip-debug", "--compress", "2", "--no-header-files", "--no-man-pages"))
    modules.set(listOf(
        "java.base",
        "java.xml",
        "jdk.crypto.ec"
    ))

    jpackage {
        if (!Os.isFamily(Os.FAMILY_WINDOWS)) {
            imageOptions = listOf("--win-console")
        }
    }
}
