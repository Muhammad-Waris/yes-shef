plugins {
    id("com.android.application")
    // Firebase
    id("com.google.gms.google-services")
    // Kotlin
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "wd.com.yes_chef"
    compileSdk = 36 // Required by ML Kit
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "wd.com.yes_chef"
        minSdk = maxOf(21, flutter.minSdkVersion) // ML Kit needs 21+
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

   buildTypes {
    getByName("release") {
        isMinifyEnabled = false
        isShrinkResources = false
        signingConfig = signingConfigs.getByName("debug")
    }
    getByName("debug") {
        isMinifyEnabled = false
        isShrinkResources = false
    }
}




    packaging {
        resources {
            excludes += setOf(
                "META-INF/LICENSE.md",
                "META-INF/LICENSE-notice.md"
            )
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Kotlin standard library (use explicit version)
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")

    // ✅ Google ML Kit Text Recognition (Latin default)
    implementation("com.google.mlkit:text-recognition:16.0.0")

    // ✅ Optional language-specific recognizers
    // implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
    // implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
    // implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
    // implementation("com.google.mlkit:text-recognition-korean:16.0.0")

    // ✅ Firebase (from FlutterFire)
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-auth")

    // ✅ CameraX (if used for scanning)
    implementation("androidx.camera:camera-core:1.3.4")
    implementation("androidx.camera:camera-camera2:1.3.4")
    implementation("androidx.camera:camera-lifecycle:1.3.4")
    implementation("androidx.camera:camera-view:1.3.4")

    // ✅ Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}
