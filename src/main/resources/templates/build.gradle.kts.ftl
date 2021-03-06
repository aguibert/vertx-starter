import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar
import org.gradle.api.tasks.testing.logging.TestLogEvent.*
<#if language == "kotlin">
  import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
</#if>

plugins {
<#if language == "kotlin">
  kotlin ("jvm") version "1.3.72"
<#else>
  java
</#if>
  application
  id("com.github.johnrengelman.shadow") version "5.2.0"
}

group = "${groupId}"
version = "1.0.0-SNAPSHOT"

repositories {
<#if vertxVersion?ends_with("-SNAPSHOT")>
  maven {
    url "https://oss.sonatype.org/content/repositories/snapshots"
    mavenContent {
      snapshotsOnly()
    }
  }
</#if>
  mavenCentral()
<#if language == "kotlin">
  jcenter()
</#if>
}

<#if language == "kotlin">
val kotlinVersion = "1.3.72"
</#if>
val vertxVersion = "${vertxVersion}"
val junitJupiterVersion = "5.6.0"

val mainVerticleName = "${packageName}.MainVerticle"
val watchForChange = "src/**/*"
val doOnChange = "./gradlew classes"
val launcherClassName = "io.vertx.core.Launcher"

application {
  mainClassName = launcherClassName
}

dependencies {
<#if !vertxDependencies?has_content>
  implementation("io.vertx:vertx-core:$vertxVersion")
</#if>
<#list vertxDependencies as dependency>
  implementation("io.vertx:${dependency}:$vertxVersion")
</#list>
<#if language == "kotlin">
  implementation(kotlin("stdlib-jdk8"))
</#if>
<#if hasVertxJUnit5>
  testImplementation("io.vertx:vertx-junit5:$vertxVersion")
  testImplementation("org.junit.jupiter:junit-jupiter:$junitJupiterVersion")
<#elseif hasVertxUnit>
  testImplementation("io.vertx:vertx-unit:$vertxVersion")
  testImplementation("junit:junit:4.13")
</#if>
}

<#if language == "kotlin">
  val compileKotlin: KotlinCompile by tasks
  compileKotlin.kotlinOptions.jvmTarget = "${jdkVersion}"
<#else>
  java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
  }
</#if>

tasks.withType<ShadowJar> {
  archiveClassifier.set("fat")
  manifest {
    attributes(mapOf("Main-Verticle" to mainVerticleName))
  }
  mergeServiceFiles {
    include("META-INF/services/io.vertx.core.spi.VerticleFactory")
  }
}

tasks.withType<Test> {
<#if hasVertxJUnit5>
  useJUnitPlatform()
<#elseif hasVertxUnit>
  useJUnit()
</#if>
  testLogging {
    events = setOf(PASSED, SKIPPED, FAILED)
  }
}

tasks.withType<JavaExec> {
  args = listOf("run", mainVerticleName, "--redeploy=$watchForChange", "--launcher-class=$launcherClassName", "--on-redeploy=$doOnChange")
}
