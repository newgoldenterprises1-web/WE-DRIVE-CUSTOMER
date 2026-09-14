import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val googleMapsApiKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY")
    ?: System.getenv("GOOGLE_MAPS_API_KEY")
    ?: ""

val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = signingPropertiesFile.exists()
if (hasReleaseSigning) {
    FileInputStream(signingPropertiesFile).use { signingProperties.load(it) }
}

android {
    namespace = "com.example.we_drive_v2"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.we_drive_v2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    if (hasReleaseSigning) {
        signingConfigs {
            create("release") {
                keyAlias = signingProperties["keyAlias"] as String
                keyPassword = signingProperties["keyPassword"] as String
                storeFile = file(signingProperties["storeFile"] as String)
                storePassword = signingProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (googleMapsApiKey.isBlank()) {
                throw GradleException(
                    "WE DRIVE Customer Google Maps API key is not configured. " +
                        "Set GOOGLE_MAPS_API_KEY in android/local.properties or the build environment."
                )
            }

            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                throw GradleException(
                    "WE DRIVE Customer release signing is not configured. " +
                        "Create android/key.properties and provide a release keystore before building a production release."
                )
            }
        }
    }
}

flutter {
    source = "../.."
}
