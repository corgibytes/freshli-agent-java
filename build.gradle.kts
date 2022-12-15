import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.7.22"
    application
}

group = "com.corgibytes"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
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
    kotlinOptions.jvmTarget = "1.8"
}

application {
    mainClass.set("com.corgibytes.freshli.agent.java.MainKt")
}
