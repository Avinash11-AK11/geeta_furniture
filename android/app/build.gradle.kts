plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.geeta.furniture"

    // ✅ REQUIRED for Android 12+ Splash API & plugins
    compileSdk = 36

    defaultConfig {
        applicationId = "com.geeta.furniture"

        // ✅ Flutter-safe values
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        // ✅ STABLE for Flutter ecosystem
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // ✅ REQUIRED by some plugins
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ Required for Java 8+ APIs
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.0.4"
    )

    // ✅ Android 12+ SplashScreen API
    implementation("androidx.core:core-splashscreen:1.0.1")
}

flutter {
    source = "../.."
}
