plugins {
    id("com.android.application") version "8.2.1"

    id("kotlin-android")
    id("kotlin-kapt") // Required for Firebase
    id("com.google.gms.google-services") // Firebase Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.proto" // Replace with your package name
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.proto" // Replace with your actual app ID
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    android {
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_21
            targetCompatibility = JavaVersion.VERSION_21
        }

        kotlinOptions {
            jvmTarget = "21"
        }
    }





}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.21") // Corrected Kotlin version
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("com.google.firebase:firebase-bom:32.7.0") // Firebase BOM (automatically selects versions)
    implementation("com.google.firebase:firebase-auth-ktx") // Firebase Auth
    implementation("com.google.firebase:firebase-firestore-ktx") // Firestore (if needed)
}
