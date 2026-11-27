plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.codeair.dharm_guru_shrinkhala"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // resValue is used for the per flavor launcher name, see below.
    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.codeair.dharm_guru_shrinkhala"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Launcher name. The admin flavor overrides this below so the
        // two apps are easy to tell apart on one phone.
        resValue("string", "app_name", "Dharm Guru Shrinkhala")
    }

    // User and admin are separate apps on one phone, so they need
    // separate applicationIds. Build with --flavor user or --flavor
    // admin. The user flavor keeps the original id.
    flavorDimensions += "app"
    productFlavors {
        create("user") {
            dimension = "app"
        }
        create("admin") {
            dimension = "app"
            applicationIdSuffix = ".admin"
            resValue("string", "app_name", "Dharm Guru Admin")
        }
    }

    // Permanent release signing key. CI restores
    // android/app/release.keystore from the
    // DHARM_GURU_KEYSTORE_BASE64 repo secret and passes the
    // passwords as environment variables. The key never changes,
    // so the SHA-1 fingerprint registered in the Firebase
    // console stays valid for every build. Without it each CI
    // run signs with a fresh debug key whose fingerprint
    // changes every time, and Google sign in on Android can
    // never be registered. When the keystore is absent (local
    // builds) the release build falls back to the debug key.
    val releaseKeystoreFile = file("release.keystore")
    val releaseKeystorePassword =
        System.getenv("DHARM_GURU_KEYSTORE_PASSWORD")
    val releaseKeyPassword = System.getenv("DHARM_GURU_KEY_PASSWORD")
    val releaseKeyAlias =
        System.getenv("DHARM_GURU_KEY_ALIAS") ?: "dharmguru"
    val hasReleaseKey = releaseKeystoreFile.exists() &&
        releaseKeystorePassword != null &&
        releaseKeyPassword != null

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = releaseKeystoreFile
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // No release key present: local builds sign with
                // the debug key, so `flutter run --release` works.
                signingConfigs.getByName("debug")
            }
            // Release shrinking (R8) is on. The keep rules in
            // proguard-rules.pro protect the Firebase and
            // FlutterFire implementation classes: without them R8
            // removed FirebaseApp, FirebaseInstallations,
            // FirebaseRemoteConfig and the FlutterFire plugin
            // classes from the dex and Firebase init failed on the
            // phone. Resource shrinking stays off so the Firebase
            // config string resources are never stripped.
            isMinifyEnabled = true
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
