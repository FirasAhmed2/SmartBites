buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.13")
        classpath("com.android.tools.build:gradle:8.2.1") // Use a stable version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.21")

    }
}

// Define Kotlin version properly
val kotlinVersion = "1.8.22"


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix root project build directory assignment
rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Correct task registration in Kotlin DSL
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
