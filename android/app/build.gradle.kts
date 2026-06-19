plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

android {
    namespace = "app.umma.aokaze"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }



    defaultConfig {
        applicationId = "app.umma.aokaze"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("SIGN_KEY") ?: error("SIGN_KEY env var not set"))
            storePassword = System.getenv("SIGN_STORE_PASS") ?: error("SIGN_STORE_PASS env var not set")
            keyAlias = System.getenv("SIGN_ALIAS") ?: error("SIGN_ALIAS env var not set")
            keyPassword = System.getenv("SIGN_KEY_PASS") ?: error("SIGN_KEY_PASS env var not set")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
implementation("androidx.appcompat:appcompat:1.7.0")
}

flutter {
    source = "../.."
}
