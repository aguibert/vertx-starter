plugins {
<#if language == "kotlin">
  id "org.jetbrains.kotlin.jvm" version "1.3.72"
<#else>
  id 'java'
</#if>
  id 'application'
  id 'com.github.johnrengelman.shadow' version '5.2.0'
}

group = '${groupId}'
version = '1.0.0-SNAPSHOT'

repositories {
<#if vertxVersion?ends_with("-SNAPSHOT")>
  maven {
    url 'https://oss.sonatype.org/content/repositories/snapshots'
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

ext {
<#if language == "kotlin">
  kotlinVersion = '1.3.72'
</#if>
  vertxVersion = '${vertxVersion}'
  junitJupiterEngineVersion = '5.6.0'
}

application {
  mainClassName = 'io.vertx.core.Launcher'
}

def mainVerticleName = '${packageName}.MainVerticle'
def watchForChange = 'src/**/*'
def doOnChange = './gradlew classes'

dependencies {
<#if !vertxDependencies?has_content>
  implementation "io.vertx:vertx-core:$vertxVersion"
</#if>
<#list vertxDependencies as dependency>
  implementation "io.vertx:${dependency}:$vertxVersion"
</#list>
<#if language == "kotlin">
  implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
</#if>
  testImplementation "io.vertx:vertx-junit5:$vertxVersion"
  testRuntimeOnly "org.junit.jupiter:junit-jupiter-engine:$junitJupiterEngineVersion"
  testImplementation "org.junit.jupiter:junit-jupiter-api:$junitJupiterEngineVersion"
}

<#if language == "kotlin">
compileKotlin {
  kotlinOptions.jvmTarget = '1.8'
}

compileTestKotlin {
  kotlinOptions.jvmTarget = '1.8'
}
<#else>
java {
  sourceCompatibility = JavaVersion.VERSION_1_8
  targetCompatibility = JavaVersion.VERSION_1_8
}
</#if>

shadowJar {
  classifier = 'fat'
  manifest {
    attributes 'Main-Verticle': mainVerticleName
  }
  mergeServiceFiles {
    include 'META-INF/services/io.vertx.core.spi.VerticleFactory'
  }
}

test {
  useJUnitPlatform()
  testLogging {
    events 'PASSED', 'FAILED', 'SKIPPED'
  }
}

run {
  args = ['run', mainVerticleName, "--redeploy=$watchForChange", "--launcher-class=$mainClassName", "--on-redeploy=$doOnChange"]
}
