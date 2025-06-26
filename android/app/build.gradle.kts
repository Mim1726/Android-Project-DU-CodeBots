plugins {
    id("com.android.application")
    //add the google service gradle plugin
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.android"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    /*
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        //coreLibraryDesugaringEnabled = true
        isCoreLibraryDesugaringEnabled = true
    }
    */

    kotlinOptions {
        //jvmTarget = JavaVersion.VERSION_11.toString()
        //jvmTarget = "1.8"
        jvmTarget = "11"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.Platr"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        //minSdk = flutter.minSdkVersion
        //minSdk = 22
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    lint {
        baseline = file("lint-baseline.xml") // Use this to track known lint issues
        checkDependencies = false              // Ignore warnings from external packages
        abortOnError = true                    // Stop build on new lint errors (optional)
    }

    /*
    lint {
        baseline = file("lint-baseline.xml")
    }
    */

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    //coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    //import the firebase Bom
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    //TODO:add the dependencies for firebase products you want to use
    //when usingthe Bom, don't specify versions in firebase dependencies
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}