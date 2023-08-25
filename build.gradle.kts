import com.google.protobuf.gradle.generateProtoTasks
import com.google.protobuf.gradle.id
import com.google.protobuf.gradle.plugins
import com.google.protobuf.gradle.protobuf
import com.google.protobuf.gradle.protoc
import org.gradle.kotlin.dsl.invoke
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.8.10"
    id("com.google.protobuf") version "0.8.18"
    idea

    application
}

group = "com.corgibytes"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

val grpcVersion: String by project
val protobufVersion: String by project
val grpcKotlinVersion: String by project

dependencies {

    implementation("com.github.ajalt.clikt:clikt:3.5.2")
    implementation("com.corgibytes:dependency-history-maven:2.0.34")
    implementation("com.github.package-url:packageurl-java:1.4.1")
    implementation("org.apache.maven:maven-model:3.9.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("com.github.pgreze:kotlin-process:1.4.1")
    implementation("com.github.oshi:oshi-core:6.4.2")
    runtimeOnly("org.slf4j:slf4j-simple:2.0.7")

    api("io.grpc:grpc-stub:$grpcVersion")
    api("io.grpc:grpc-protobuf:$grpcVersion")
    api("io.grpc:grpc-services:$grpcVersion")
    runtimeOnly("io.grpc:grpc-netty:$grpcVersion")
    api("com.google.protobuf:protobuf-java-util:$protobufVersion")
    api("com.google.protobuf:protobuf-kotlin:$protobufVersion")
    api("io.grpc:grpc-kotlin-stub:$grpcKotlinVersion")
    api("com.google.protobuf:protobuf-gradle-plugin:0.9.2")

    testImplementation(kotlin("test"))
}

sourceSets {
    val main by getting { }
    main.java.srcDirs("build/generated/source/proto/main/java")
    main.java.srcDirs("build/generated/source/proto/main/grpc")
    main.java.srcDirs("build/generated/source/proto/main/kotlin")
    main.java.srcDirs("build/generated/source/proto/main/grpckt")
}

tasks.test {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "1.8"
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

// based on https://stackoverflow.com/a/32089746/243215
// If the line that sets the classpath gets too long, then the bat file generates an error message.
// This works around the issue by using lib\* in the classpath.
tasks.withType<CreateStartScripts> {
    doLast {
        val winScriptFile = file(windowsScript)
        var winFileText = winScriptFile.readText()
        winFileText = winFileText.replace(Regex("set CLASSPATH=.*"), "rem original CLASSPATH declaration replaced by:\nset CLASSPATH=%APP_HOME%\\\\lib\\\\\\*")
        winScriptFile.writeText(winFileText)
    }
}

application {
    mainClass.set("com.corgibytes.freshli.agent.java.MainKt")
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:$protobufVersion"
    }
    plugins {
        id("grpc") {
            artifact = "io.grpc:protoc-gen-grpc-java:$grpcVersion"
        }
        id("grpckt") {
            artifact = "io.grpc:protoc-gen-grpc-kotlin:$grpcKotlinVersion:jdk8@jar"
        }
    }
    generateProtoTasks {
        all().forEach {
            it.plugins {
                id("grpc")
                id("grpckt")
            }
            it.builtins {
                id("kotlin")
            }
        }
    }
}
