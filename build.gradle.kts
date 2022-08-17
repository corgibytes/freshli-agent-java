import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.6.20"
    application
}

group = "com.corgibytes"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.github.ajalt.clikt:clikt:3.4.0")
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "16"

}

application {
    mainClass.set("com.corgibytes.freshli.agent.java.MainKt")
}

tasks.register<Exec>("publishExe") {
    commandLine("bash", "-c", "mkdir -p exe && ln -sF ../build/install/freshli-agent-java/bin/freshli-agent-java exe/freshli-agent-java")
}
tasks.named("installDist") { finalizedBy("publishExe") }

tasks.register<Delete>("cleanExe") {
    isFollowSymlinks = false
    delete("exe")
}
tasks.named("clean") { finalizedBy("cleanExe") }
